import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:manlogen/services/dio_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'widgets/roomcard.dart';
import 'room/livingroomscreen.dart';
import 'room/garagescreen.dart';
import 'room/bathroomscreen.dart';
import 'room/bedroomscreen.dart';
import 'led_control_screen.dart';

final Logger logger = Logger();

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  /// ✅ **Fungsi Decode JWT untuk Ambil Username**
  Map<String, dynamic> decodeJWT(String token) {
    try {
      final jwt = JWT.decode(token);
      return jwt.payload as Map<String, dynamic>;
    } catch (e) {
      logger.e("❌ Gagal decode token: $e");
      return {};
    }
  }

  /// ✅ **Fungsi Fetch Data User Sesuai Token**
  Future<void> fetchUserData() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "jwt_token");

    if (token == null) {
      logger.w("🚨 Tidak ada token, user dianggap Guest.");
      setState(() => isLoading = false);
      return;
    }

    try {
      // 🔍 Fetch Semua User dari /user
      final response = await DioClient().dio.get("/user");

      logger.i("✅ Response Data dari Backend: ${response.data}");

      if (response.statusCode == 200 && response.data is List<dynamic>) {
        // 🔍 Decode Token JWT → Ambil `username`
        final jwtPayload = decodeJWT(token);
        String? loggedInUsername = jwtPayload["username"];

        // 🔍 Cari user yang `username`-nya cocok dengan token
        final matchedUser = response.data.firstWhere(
          (user) => user["username"] == loggedInUsername,
          orElse: () => null,
        );

        if (matchedUser != null) {
          setState(() {
            userData = matchedUser;
            isLoading = false;
          });
          logger.i("✅ User yang Login: ${userData?['username']}");
        } else {
          logger.e("❌ User tidak ditemukan dalam data");
          setState(() => isLoading = false);
        }
      } else {
        logger.e("❌ Response bukan 200 atau data kosong");
        setState(() => isLoading = false);
      }
    } catch (e) {
      logger.e("🔥 Error fetchUserData: $e");
      setState(() => isLoading = false);
    }
  }

  List<Widget> pages(BuildContext context) {
    return [
      DashboardHome(userData: userData),
      LEDControlScreen(userData: userData),
    ];
  }

  void onItemTapped(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : pages(context)[selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Status'),
        ],
      ),
    );
  }
}

/// ✅ **Komponen DashboardHome untuk Menampilkan Data User**
class DashboardHome extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const DashboardHome({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    logger.d("📌 User Data di DashboardHome: $userData");

    String userName = userData?["last_name"] ?? "Guest";
    String userAddress = userData?["address"] ?? "No Address";
    String? base64Photo = userData?["photo"];

    ImageProvider<Object> profileImage;

    if (base64Photo != null && base64Photo.isNotEmpty) {
      try {
        profileImage = MemoryImage(base64Decode(base64Photo));

        // ✅ Potong Base64 agar tidak kepanjangan di debug console
        String shortenedBase64 =
            base64Photo.length > 50
                ? "${base64Photo.substring(0, 50)}..."
                : base64Photo;

        logger.i("✅ Foto berhasil di-decode dari Base64: $shortenedBase64");
      } catch (e) {
        logger.e("❌ Error decoding photo: $e");
        profileImage = const AssetImage("assets/images/geryxfp.jpeg");
      }
    } else {
      logger.w("📌 Foto user kosong, gunakan default avatar");
      profileImage = const AssetImage("assets/images/geryxfp.jpeg");
    }

    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                CircleAvatar(radius: 30, backgroundImage: profileImage),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat Datang,',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userAddress,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                children: [
                  roomCard(
                    'Living Room',
                    Icons.weekend,
                    context,
                    const LivingRoomScreen(),
                  ),
                  roomCard(
                    'Garage',
                    Icons.garage,
                    context,
                    const GarageScreen(),
                  ),
                  roomCard(
                    'Bathroom',
                    Icons.bathtub,
                    context,
                    const BathroomScreen(),
                  ),
                  roomCard(
                    'Bedroom',
                    Icons.bed,
                    context,
                    const BedroomScreen(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
