import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LEDControlScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const LEDControlScreen({super.key, this.userData});

  @override
  LEDControlScreenState createState() => LEDControlScreenState();
}

class LEDControlScreenState extends State<LEDControlScreen> {
  Map<String, bool> ledStatus = {
    "Living Room (LED 1)": false,
    "Living Room (LED 2)": false,
    "Garage (LED 3)": false,
    "Bathroom (LED 4)": false,
    "Bedroom (LED 5)": false,
  };

  @override
  void initState() {
    super.initState();
    loadLEDStatus();
  }

  Future<void> loadLEDStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var room in ledStatus.keys) {
        ledStatus[room] = prefs.getBool(room) ?? false;
      }
    });
  }

  Future<void> toggleLED(String room, bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(room, status);
    setState(() {
      ledStatus[room] = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    String userName = widget.userData?["last_name"] ?? "Guest";
    String userAddress = widget.userData?["address"] ?? "No Address";
    String? base64Photo = widget.userData?["photo"];

    ImageProvider<Object> profileImage;

    if (base64Photo != null && base64Photo.isNotEmpty) {
      try {
        profileImage = MemoryImage(base64Decode(base64Photo));
      } catch (e) {
        profileImage = const AssetImage("assets/images/default_avatar.png");
      }
    } else {
      profileImage = const AssetImage("assets/images/default_avatar.png");
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(color: Colors.blue),
            child: Row(
              children: [
                CircleAvatar(radius: 30, backgroundImage: profileImage),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children:
                  ledStatus.keys.map((room) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          room,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ledStatus[room]! ? "ON" : "OFF",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    ledStatus[room]!
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Switch(
                              value: ledStatus[room] ?? false,
                              onChanged: (bool value) {
                                toggleLED(room, value);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
