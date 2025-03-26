import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:convert';
import 'package:manlogen/widgets/sensorwidget.dart';

class GarageScreen extends StatefulWidget {
  const GarageScreen({super.key});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  bool isLedOn = false; // ✅ Status LED default
  Timer? ledStatusTimer; // ✅ Timer untuk memantau perubahan LED

  double distance = 0.0; // ✅ Nilai jarak terkini
  List<double> distanceHistory = []; // ✅ Riwayat data jarak untuk grafik
  List<String> timestamps = []; // ✅ Timestamp untuk sumbu X grafik
  Map<String, dynamic>? latestData; // ✅ Buffer data jarak terbaru
  Timer? updateTimer; // ✅ Timer untuk update data secara berkala
  late WebSocketChannel channel; // ✅ Channel WebSocket

  @override
  void initState() {
    super.initState();
    _getLEDStatus();
    _startLEDStatusWatcher();
    _connectWebSocket();
    _startDataUpdater();
  }

  void _getLEDStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLedOn = prefs.getBool("Garage (LED 3)") ?? false;
    });
  }

  void _startLEDStatusWatcher() {
    ledStatusTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool currentStatus = prefs.getBool("Garage (LED 3)") ?? false;
      if (currentStatus != isLedOn) {
        setState(() {
          isLedOn = currentStatus;
        });
      }
    });
  }

  void _connectWebSocket() {
    final uri = Uri.parse(
      'wss://mgr-core.geryx.space:8443/sensor/distance/realtime',
    );
    channel = WebSocketChannel.connect(uri);

    channel.stream.listen(
      (message) => _handleIncoming(message),
      onError: (error) => debugPrint("❌ WS error: $error"),
      onDone: () => debugPrint("🔌 WS disconnected"),
    );
  }

  void _handleIncoming(String message) {
    try {
      final decoded = jsonDecode(message);
      if (decoded is List) {
        final lastData = decoded.lastWhere(
          (d) => d["sensor_id"] == 3,
          orElse: () => null,
        );
        if (lastData != null) {
          latestData = Map<String, dynamic>.from(lastData);
        }
      } else if (decoded is Map && decoded["sensor_id"] == 3) {
        latestData = Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      debugPrint("❌ Error parsing WS data: $e");
    }
  }

  void _startDataUpdater() {
    updateTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (latestData == null) return;

      try {
        double newDistance = latestData!["distance"];
        String? ts = latestData!["timestamp"];
        if (ts == null || ts.length < 19) return;
        String formattedTs = ts.substring(11, 19);

        setState(() {
          distance = newDistance;
          if (newDistance.isFinite) distanceHistory.add(newDistance);
          timestamps.add(formattedTs);

          if (distanceHistory.length > 10) {
            distanceHistory.removeAt(0);
            timestamps.removeAt(0);
          }
        });
      } catch (e) {
        debugPrint("❌ Distance parse error: $e");
      }
    });
  }

  @override
  void dispose() {
    ledStatusTimer?.cancel();
    updateTimer?.cancel();
    channel.sink.close();
    super.dispose();
  }

  Widget _buildLineChart() {
    if (distanceHistory.length < 2) {
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
                interval: 20,
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
                distanceHistory.length,
                (index) => FlSpot(index.toDouble(), distanceHistory[index]),
              ),
              isCurved: true,
              color: Colors.green,
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
      appBar: AppBar(title: const Text('Garage')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Garage Sensors',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              sensorwidget(
                'distance',
                '${distance.toStringAsFixed(1)} cm',
                Icons.speed,
              ),
              sensorwidget('led', isLedOn ? 'ON' : 'OFF', Icons.lightbulb),
              const SizedBox(height: 20),
              const Text(
                'Distance (cm)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildLineChart(),
            ],
          ),
        ),
      ),
    );
  }
}
