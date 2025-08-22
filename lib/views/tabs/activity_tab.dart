import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:convert';

class ActivityTab extends StatefulWidget {
  const ActivityTab({super.key});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  List<WiFiAccessPoint> devices = [];
  bool scanning = false;
  bool connecting = false;
  bool isConnectedToDevice = false;
  bool isReadingData = false;
  String? espIp;
  
  // Real-time data
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _dataTimer;
  
  // Sensor data
  double heartRate = 0.0;
  double spo2 = 0.0;
  List<FlSpot> ecgData = [];
  List<FlSpot> heartRateHistory = [];
  int dataPointIndex = 0;
  
  // Controllers
  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  @override
  void dispose() {
    _disconnectFromDevice();
    ssidController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Request necessary permissions for WiFi scanning
  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.location,
      Permission.nearbyWifiDevices,
    ];
    
    for (final permission in permissions) {
      if (await permission.isDenied) {
        await permission.request();
      }
    }
  }

  /// Check if WiFi scanning is available and permissions are granted
  Future<bool> _canScan() async {
    final can = await WiFiScan.instance.canGetScannedResults();
    if (can != CanGetScannedResults.yes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("WiFi scanning not available: $can"))
        );
      }
      return false;
    }

    if (await Permission.location.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission required for WiFi scanning"))
        );
      }
      return false;
    }

    return true;
  }

  /// Scan for nearby ESP32 devices
  Future<void> scanDevices() async {
    if (!(await _canScan())) return;

    setState(() => scanning = true);
    
    try {
      final can = await WiFiScan.instance.canStartScan();
      if (can == CanStartScan.yes) {
        final result = await WiFiScan.instance.startScan();
        if (!result) {
          throw Exception("Failed to start WiFi scan");
        }
        
        await Future.delayed(const Duration(seconds: 3));
      }

      final accessPoints = await WiFiScan.instance.getScannedResults();
      final espDevices = accessPoints
          .where((ap) => ap.ssid.startsWith("ECG_Device"))
          .toList();
          
      setState(() => devices = espDevices);
      
      if (espDevices.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No ECG devices found"))
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error scanning WiFi: $e"))
        );
      }
    }
    
    setState(() => scanning = false);
  }

  /// Connect to ESP32 device
  Future<void> connectToDevice(WiFiAccessPoint device) async {
    setState(() => connecting = true);
    
    try {
      // Show connection dialog with WiFi setup
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Setup ${device.ssid}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Step 1: Connect to device WiFi"),
              const Text("• Go to WiFi settings"),
              Text("• Connect to: ${device.ssid}"),
              const Text("• Password: 12345678"),
              const SizedBox(height: 15),
              const Text("Step 2: Configure internet access"),
              const Text("Enter your home WiFi details:"),
              const SizedBox(height: 10),
              TextField(
                controller: ssidController,
                decoration: const InputDecoration(
                  labelText: "WiFi Network Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: "WiFi Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("Connect & Setup"),
            ),
          ],
        ),
      );
      
      if (result == true) {
        await _connectAndSetupDevice();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connection error: $e"))
        );
      }
    }
    
    setState(() => connecting = false);
  }

  /// Connect to device and configure WiFi
  Future<void> _connectAndSetupDevice() async {
    try {
      // Test connection to device
      espIp = "192.168.4.1"; // Default ESP32 AP IP
      final testUrl = Uri.parse("http://$espIp/");
      final testResponse = await http
          .get(testUrl)
          .timeout(const Duration(seconds: 10));
          
      if (testResponse.statusCode != 200) {
        throw Exception("Cannot connect to device. Make sure you're connected to the device WiFi.");
      }

      // Configure device to connect to home WiFi
      if (ssidController.text.isNotEmpty && passwordController.text.isNotEmpty) {
        final configUrl = Uri.parse("http://$espIp/connect");
        final configResponse = await http.post(
          configUrl,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'ssid': ssidController.text,
            'password': passwordController.text,
          },
        ).timeout(const Duration(seconds: 10));
        
        if (configResponse.statusCode == 200) {
          // Wait for device to connect to home WiFi
          await Future.delayed(const Duration(seconds: 5));
          
          // Try to find device on local network
          await _findDeviceOnNetwork();
        }
      }

      setState(() => isConnectedToDevice = true);
      _startRealTimeDataFeed();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully connected to ECG device!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Setup failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Find device IP on local network
  Future<void> _findDeviceOnNetwork() async {
    // Try common local IP ranges
    final baseIPs = ['192.168.1.', '192.168.0.', '10.0.0.', '172.16.0.'];
    
    for (final baseIP in baseIPs) {
      for (int i = 100; i < 200; i++) {
        try {
          final testIP = '$baseIP$i';
          final testUrl = Uri.parse("http://$testIP/");
          final response = await http
              .get(testUrl)
              .timeout(const Duration(seconds: 2));
              
          if (response.statusCode == 200 && response.body.contains("ECG Device")) {
            espIp = testIP;
            return;
          }
        } catch (e) {
          // Continue searching
        }
      }
    }
  }

  /// Start real-time data feed using HTTP polling
  void _startRealTimeDataFeed() {
    _dataTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (!isConnectedToDevice || espIp == null) return;
      
      try {
        final url = Uri.parse("http://$espIp/reading");
        final response = await http
            .get(url)
            .timeout(const Duration(seconds: 3));
            
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _updateSensorData(data);
        }
      } catch (e) {
        // Handle connection errors silently or show occasional warnings
      }
    });
  }

  /// Update sensor data and charts
  void _updateSensorData(Map<String, dynamic> data) {
    setState(() {
      heartRate = (data['heartRate'] ?? 0).toDouble();
      spo2 = (data['spo2'] ?? 0).toDouble();
      
      // Update heart rate history
      heartRateHistory.add(FlSpot(dataPointIndex.toDouble(), heartRate));
      if (heartRateHistory.length > 50) {
        heartRateHistory.removeAt(0);
      }
      
      // Update ECG data
      if (data['ecg'] != null) {
        ecgData.clear();
        final List<dynamic> ecgList = data['ecg'];
        for (int i = 0; i < ecgList.length && i < 100; i++) {
          ecgData.add(FlSpot(i.toDouble(), ecgList[i].toDouble()));
        }
      }
      
      dataPointIndex++;
      isReadingData = heartRate > 0 && spo2 > 0;
    });
  }

  /// Disconnect from device
  void _disconnectFromDevice() {
    _dataTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    setState(() {
      isConnectedToDevice = false;
      isReadingData = false;
      heartRate = 0;
      spo2 = 0;
      ecgData.clear();
      heartRateHistory.clear();
      espIp = null;
    });
  }

  /// Start/Stop readings
  Future<void> _toggleReadings(bool start) async {
    if (espIp == null) return;
    
    try {
      final endpoint = start ? 'start' : 'stop';
      final url = Uri.parse("http://$espIp/$endpoint");
      await http.get(url).timeout(const Duration(seconds: 5));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Readings ${start ? 'started' : 'stopped'}")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header
          const Text(
            "ECG Device Monitor",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Connection Status
          if (isConnectedToDevice)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text("Connected to device at $espIp"),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _disconnectFromDevice,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Disconnect", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: scanning ? null : scanDevices,
              icon: scanning 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(scanning ? "Scanning..." : "Scan for Devices"),
            ),
          
          const SizedBox(height: 20),
          
          // Real-time data display
          if (isConnectedToDevice) ...[
            // Vital signs
            Row(
              children: [
                Expanded(
                  child: _buildVitalSignCard("Heart Rate", "$heartRate", "BPM", Colors.red),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVitalSignCard("SpO2", "$spo2", "%", Colors.blue),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _toggleReadings(true),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Start"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton.icon(
                  onPressed: () => _toggleReadings(false),
                  icon: const Icon(Icons.stop),
                  label: const Text("Stop"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Charts
            Expanded(
              child: Column(
                children: [
                  // Heart Rate Trend
                  Expanded(
                    child: _buildChart("Heart Rate Trend", heartRateHistory, Colors.red),
                  ),
                  const SizedBox(height: 12),
                  // ECG Waveform
                  Expanded(
                    child: _buildChart("ECG Waveform", ecgData, Colors.green),
                  ),
                ],
              ),
            ),
          ]
          else
            // Device list
            Expanded(
              child: devices.isEmpty && !scanning
                  ? const Center(
                      child: Text(
                        "No ECG devices found.\nTap 'Scan for Devices' to search.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              Icons.wifi,
                              color: _getSignalColor(device.level),
                            ),
                            title: Text(
                              device.ssid,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              "Signal: ${device.level} dBm",
                            ),
                            trailing: ElevatedButton(
                              onPressed: connecting ? null : () => connectToDevice(device),
                              child: connecting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text("Setup"),
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildVitalSignCard(String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart(String title, List<FlSpot> data, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: data.isNotEmpty
                ? LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data,
                          color: color,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                      "No data available",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getSignalColor(int level) {
    if (level > -50) return Colors.green;
    if (level > -70) return Colors.orange;
    return Colors.red;
  }
}