import 'dart:async';

class DhtData {
  static double temperature = 25.0;
  static double humidity = 60.0;

  static List<double> temperatureHistory = []; // ✅ Simpan riwayat suhu
  static List<double> humidityHistory = []; // ✅ Simpan riwayat kelembaban
  static List<String> timestamps = []; // ✅ Simpan timestamp untuk sumbu X

  static late Function updateUI;
  static Timer? _timer;

  static void startUpdating(Function setStateCallback) {
    updateUI = setStateCallback;

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // ✅ Generate data acak untuk simulasi sensor
      temperature += (1 - (DateTime.now().second % 3)) * 0.5;
      humidity += (1 - (DateTime.now().second % 4)) * 1.0;

      // ✅ Batasi nilai suhu dan kelembaban dalam range tertentu
      if (temperature > 30) temperature = 30;
      if (temperature < 20) temperature = 20;
      if (humidity > 70) humidity = 70;
      if (humidity < 50) humidity = 50;

      // ✅ Simpan riwayat suhu dan kelembaban
      if (temperatureHistory.length >= 10) {
        temperatureHistory.removeAt(0); // Hapus data lama
      }
      temperatureHistory.add(temperature); // Tambah data baru

      if (humidityHistory.length >= 10) {
        humidityHistory.removeAt(0);
      }
      humidityHistory.add(humidity);

      // ✅ Simpan timestamp untuk sumbu X
      if (timestamps.length >= 10) {
        timestamps.removeAt(0);
      }
      timestamps.add(
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} "
        "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}",
      );

      updateUI();
    });
  }

  static void stopUpdating() {
    _timer?.cancel(); // ✅ Hentikan timer saat widget dihapus
  }
}
