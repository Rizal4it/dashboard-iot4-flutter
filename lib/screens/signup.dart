import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  File? _selectedImage; // Untuk Mobile
  Uint8List? _selectedImageBytes; // Untuk Web
  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  // 🔹 Fungsi untuk memilih gambar (Web & Mobile)
  Future<void> _pickImage() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null &&
          result.files.isNotEmpty &&
          result.files.first.bytes != null) {
        setState(() {
          _selectedImageBytes = result.files.first.bytes!;
        });
        debugPrint(
          "Gambar berhasil dipilih di Web (size: ${_selectedImageBytes!.length})",
        );
      } else {
        debugPrint("Tidak ada gambar yang dipilih di Web");
      }
    } else {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        debugPrint("Tidak ada gambar yang dipilih");
        return;
      }

      final File tempImage = File(image.path);
      if (!await tempImage.exists()) {
        debugPrint("File tidak ditemukan: ${image.path}");
        return;
      }

      setState(() {
        _selectedImage = tempImage;
      });

      debugPrint("Gambar berhasil dipilih di Mobile: ${_selectedImage!.path}");
    }
  }

  // 🔹 Fungsi untuk mengubah gambar menjadi Base64 (Web & Mobile)
  Future<String?> _convertImageToBase64() async {
    if (kIsWeb) {
      if (_selectedImageBytes == null) {
        debugPrint("⚠️ Base64 Web: Tidak ada gambar yang dipilih!");
        return null;
      }
      String base64String = base64Encode(_selectedImageBytes!);
      debugPrint("✅ Base64 Web: ${base64String.substring(0, 20)}...");
      return base64String;
    } else {
      if (_selectedImage == null) {
        debugPrint("⚠️ Base64 Mobile: Tidak ada gambar yang dipilih!");
        return null;
      }
      List<int> imageBytes = await _selectedImage!.readAsBytes();
      String base64String = base64Encode(imageBytes);
      debugPrint("✅ Base64 Mobile: ${base64String.substring(0, 20)}...");
      return base64String;
    }
  }

  // 🔹 Fungsi untuk mengirim data signup ke FastAPI
  Future<void> _handleSignUp() async {
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String address = _addressController.text;
    String username = _usernameController.text;
    String password = _passwordController.text;

    String? base64Image = await _convertImageToBase64();

    debugPrint(
      "📤 Mengirim data: username=$username, photo_length=${base64Image?.length ?? 0}",
    );

    try {
      Map<String, dynamic> requestBody = {
        "username": username,
        "password": password,
        "first_name": firstName,
        "last_name": lastName,
        "address": address,
        "photo": base64Image ?? "",
      };

      var response = await _dio.post(
        "https://mgr-core.geryx.space:8443/data/signup",
        data: requestBody,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Sign up berhasil: ${response.data}");
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Sign up berhasil!")));
        }
      } else {
        debugPrint("❌ Gagal sign up: ${response.data}");
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Gagal sign up!")));
        }
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Terjadi kesalahan")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Tambahkan build()
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    kIsWeb
                        ? _selectedImageBytes != null
                            ? MemoryImage(_selectedImageBytes!)
                            : null
                        : _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : null,
                child:
                    (_selectedImage == null && _selectedImageBytes == null)
                        ? const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.white,
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Pilih Gambar"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(hintText: "First Name"),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(hintText: "Last Name"),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(hintText: "Address"),
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(hintText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: "Password"),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _handleSignUp,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
