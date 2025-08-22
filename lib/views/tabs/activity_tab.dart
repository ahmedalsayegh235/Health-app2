import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;

class ActivityTab extends StatefulWidget {
  const ActivityTab({super.key});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  List<String?> devices = [];
  bool scanning = false;

  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    ssidController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> scanDevices() async {
    setState(() => scanning = true);
    final networks = await WiFiForIoTPlugin.loadWifiList();
    final foundDevices = networks
        .where((n) => n.ssid!.startsWith('ECG_Device'))
        .map((n) => n.ssid)
        .toList();
    setState(() {
      devices = foundDevices;
      scanning = false;
    });
  }

  Future<void> connectDeviceToWiFi(String deviceSSID) async {
    // Connect phone to the device AP
    await WiFiForIoTPlugin.connect(
      deviceSSID,
      password: "12345678",
      security: NetworkSecurity.WPA,
    );

    // Show dialog for user to enter Wi-Fi credentials
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Home Wi-Fi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ssidController,
              decoration: const InputDecoration(labelText: "Wi-Fi SSID"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Wi-Fi Password"),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final ssid = ssidController.text;
              final pass = passwordController.text;
              // Send to device AP HTTP endpoint
              try {
                final url = Uri.parse(
                    'http://192.168.4.1/connect?ssid=$ssid&password=$pass');
                final res = await http.get(url);
                if (res.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Device connecting...")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to send credentials")));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")));
              }
              Navigator.of(context).pop();
            },
            child: const Text("Connect"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: scanning ? null : scanDevices,
            child: scanning
                ? const CircularProgressIndicator()
                : const Text("Scan for Devices"),
          ),
          const SizedBox(height: 20),
          ...devices.map((device) => ListTile(
                title: Text(device!),
                trailing: ElevatedButton(
                  onPressed: () => connectDeviceToWiFi(device),
                  child: const Text("Connect"),
                ),
              ))
        ],
      ),
    );
  }
}
