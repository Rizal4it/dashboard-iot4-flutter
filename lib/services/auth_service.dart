import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:manlogen/services/dio_client.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';

class AuthService {
  final DioClient _dioClient = DioClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  Future<String?> login(String username, String password) async {
    try {
      // Cek apakah token masih valid sebelum login
      if (!await isTokenExpired()) {
        return "You are already logged in.";
      }

      final response = await _dioClient.dio.post(
        "/login",
        data: {"username": username, "password": password},
      );
      _logger.i("Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final token = response.data["access_token"];
        await _storage.write(key: "jwt_token", value: token);
        _logger.i("Login successful, token stored.");
        return null; // Login berhasil, tidak ada error
      } else {
        return response.data is Map
            ? response.data["detail"] ?? "Unknown error"
            : "Unexpected response format";
      }
    } on DioException catch (e) {
      if (e.response != null &&
          e.response?.data is Map &&
          e.response?.data["detail"] != null) {
        return e.response?.data["detail"]; // Ambil pesan error dari backend
      } else {
        return "Network error, please try again.";
      }
    }
  }

  /// ✅ **Fungsi untuk mengecek apakah token sudah expired**
  Future<bool> isTokenExpired() async {
    String? token = await _storage.read(key: "jwt_token");
    if (token == null) return true; // Jika tidak ada token, anggap expired

    try {
      final jwt = JWT.decode(token);
      final expiry = DateTime.fromMillisecondsSinceEpoch(
        jwt.payload['exp'] * 1000,
      );
      return expiry.isBefore(DateTime.now()); // True jika token sudah expired
    } catch (e) {
      _logger.e("Invalid token: $e");
      return true; // Jika gagal decode, anggap expired
    }
  }

  Future<void> logout(BuildContext context) async {
    await _storage.delete(key: "jwt_token");
    _logger.i("Token removed, user logged out.");

    if (!context.mounted) {
      return; // ✅ Pastikan context masih valid sebelum navigasi
    }
    Navigator.pushReplacementNamed(context, "/welcome");
  }
}
