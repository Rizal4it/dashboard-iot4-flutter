import 'package:flutter/material.dart';

Widget roomCard(
  String title,
  IconData icon,
  BuildContext context,
  Widget targetScreen,
) {
  return GestureDetector(
    onTap:
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        ),
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.blue),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
