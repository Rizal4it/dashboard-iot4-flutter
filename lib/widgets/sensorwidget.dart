import 'package:flutter/material.dart';

Widget sensorwidget(String title, String value, IconData icon) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: ListTile(
      leading: Icon(icon, color: Colors.blue, size: 40),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
    ),
  );
}
