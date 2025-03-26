import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:convert';
import 'package:manlogen/widgets/sensorwidget.dart';

class LivingRoomScreen extends StatefulWidget {
  const LivingRoomScreen({super.key});

  @override
  LivingRoomScreenState createState() => LivingRoomScreenState();
}

class LivingRoomScreenState extends State<LivingRoomScreen> {
  bool isLedOn = false;
  Timer? ledStatusTimer;

  double temperature = 0.0;
  List<double> temperatureHistory = [];
  List<String> tempTimestamps = [];
  Map<String, dynamic>? latestTempData;
  Timer? tempUpdateTimer;
  late WebSocketChannel tempChannel;

  double humidity = 0.0;
  List<double> humidityHistory = [];
  List<String> humTimestamps = [];
  Map<String, dynamic>? latestHumData;
  Timer? humUpdateTimer;
  late WebSocketChannel humChannel;

  @override
  void initState() {
    super.initState();
    _getLEDStatus();
    _startLEDStatusWatcher();
    _connectWebSocketTemperature();
    _startTempDataUpdater();
    _connectWebSocketHumidity();
    _startHumDataUpdater();
  }

  void _getLEDStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLedOn = prefs.getBool("Living Room (LED 1)") ?? false;
    });
  }

  void _startLEDStatusWatcher() {
    ledStatusTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool currentStatus = prefs.getBool("Living Room (LED 1)") ?? false;
      if (currentStatus != isLedOn) {
        setState(() {
          isLedOn = currentStatus;
        });
      }
    });
  }

  void _connectWebSocketTemperature() {
    final uri = Uri.parse(
      'wss://mgr-core.geryx.space:8443/sensor/temperature/realtime',
    );
    tempChannel = WebSocketChannel.connect(uri);

    tempChannel.stream.listen(
      (message) => _handleIncoming(message, isTemperature: true),
      onError: (error) => debugPrint("❌ Temp WS error: $error"),
      onDone: () => debugPrint("🔌 Temp WS disconnected"),
    );
  }

  void _connectWebSocketHumidity() {
    final uri = Uri.parse(
      'wss://mgr-core.geryx.space:8443/sensor/humidity/realtime',
    );
    humChannel = WebSocketChannel.connect(uri);

    humChannel.stream.listen(
      (message) => _handleIncoming(message, isTemperature: false),
      onError: (error) => debugPrint("❌ Hum WS error: $error"),
      onDone: () => debugPrint("🔌 Hum WS disconnected"),
    );
  }

  void _handleIncoming(String message, {required bool isTemperature}) {
    try {
      final decoded = jsonDecode(message);
      int expectedId = isTemperature ? 2 : 8;

      if (decoded is List) {
        final lastData = decoded.lastWhere(
          (d) => d["sensor_id"] == expectedId,
          orElse: () => null,
        );
        if (lastData != null) {
          if (isTemperature) {
            latestTempData = Map<String, dynamic>.from(lastData);
          } else {
            latestHumData = Map<String, dynamic>.from(lastData);
          }
        }
      } else if (decoded is Map && decoded["sensor_id"] == expectedId) {
        if (isTemperature) {
          latestTempData = Map<String, dynamic>.from(decoded);
        } else {
          latestHumData = Map<String, dynamic>.from(decoded);
        }
      }
    } catch (e) {
      debugPrint("❌ Error parsing WS data: $e");
    }
  }

  void _startTempDataUpdater() {
    tempUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (latestTempData == null) return;

      try {
        double newTemp = latestTempData!["temperature"];
        String? ts = latestTempData!["timestamp"];
        if (ts == null || ts.length < 19) return;
        String formattedTs = ts.substring(11, 19);

        setState(() {
          temperature = newTemp;
          if (newTemp.isFinite) temperatureHistory.add(newTemp);
          tempTimestamps.add(formattedTs);

          if (temperatureHistory.length > 10) {
            temperatureHistory.removeAt(0);
            tempTimestamps.removeAt(0);
          }
        });
      } catch (e) {
        debugPrint("❌ Temp parse error: $e");
      }
    });
  }

  void _startHumDataUpdater() {
    humUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (latestHumData == null) return;

      try {
        double newHum = latestHumData!["humidity"];
        String? ts = latestHumData!["timestamp"];
        if (ts == null || ts.length < 19) return;
        String formattedTs = ts.substring(11, 19);

        setState(() {
          humidity = newHum;
          if (newHum.isFinite) humidityHistory.add(newHum);
          humTimestamps.add(formattedTs);

          if (humidityHistory.length > 10) {
            humidityHistory.removeAt(0);
            humTimestamps.removeAt(0);
          }
        });
      } catch (e) {
        debugPrint("❌ Humidity parse error: $e");
      }
    });
  }

  @override
  void dispose() {
    ledStatusTimer?.cancel();
    tempUpdateTimer?.cancel();
    humUpdateTimer?.cancel();
    tempChannel.sink.close();
    humChannel.sink.close();
    super.dispose();
  }

  Widget _buildLineChart(
    List<double> data,
    List<String> timestamps,
    Color color,
  ) {
    if (data.length < 2) {
      return const Center(
        child: Text("Menunggu data...", style: TextStyle(fontSize: 16)),
      );
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20, // ✅ Ganti ini ke 20 biar muncul 0, 20, 40, ...
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()} cm',
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < timestamps.length) {
                    return Transform.rotate(
                      angle: -0.5,
                      child: Text(
                        timestamps[index],
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black, width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                data.length,
                (index) => FlSpot(index.toDouble(), data[index]),
              ),
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
          minY: 0,
          maxY: 99,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Living Room')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Living Room Sensors',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              sensorwidget(
                'temperature',
                '${temperature.toStringAsFixed(1)} °C',
                Icons.thermostat,
              ),
              sensorwidget(
                'humidity',
                '${humidity.toStringAsFixed(1)} %',
                Icons.water_drop,
              ),
              sensorwidget('led', isLedOn ? 'ON' : 'OFF', Icons.lightbulb),
              const SizedBox(height: 20),
              const Text(
                'Temperature (°C)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildLineChart(temperatureHistory, tempTimestamps, Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Humidity (%)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildLineChart(humidityHistory, humTimestamps, Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
