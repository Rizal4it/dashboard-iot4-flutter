import 'dart:async';
import 'package:fl_chart/fl_chart.dart';

class DistanceData {
  static List<FlSpot> distanceSpots = [];
  static List<String> timestamps = []; // ✅ Menyimpan timestamp untuk grafik

  static late Function updateUI;
  static Timer? _timer;

  static void startUpdating(Function setStateCallback) {
    updateUI = setStateCallback;

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (distanceSpots.length >= 10) {
        distanceSpots.removeAt(0);
        timestamps.removeAt(0);
      }

      double lastX = distanceSpots.isNotEmpty ? distanceSpots.last.x : 0;
      double newY = 74 + (5 * (0.5 - (DateTime.now().second % 2)));

      distanceSpots.add(FlSpot(lastX + 1, newY));

      // ✅ Simpan timestamp untuk label sumbu X
      timestamps.add(
        "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}",
      );

      updateUI();
    });
  }

  static void stopUpdating() {
    _timer?.cancel(); // ✅ Hentikan timer saat widget dihapus
  }
}
