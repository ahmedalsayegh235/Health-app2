import 'package:flutter/material.dart';
import 'package:health/controllers/device_controller.dart';
import 'package:health/helpers/Device_Tab_helpers.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/patient_views/tabs/widgets/activity/widgets/device/device_card.dart';
import 'package:health/patient_views/tabs/widgets/activity/widgets/device/quick_actions.dart';
import 'package:health/patient_views/tabs/widgets/activity/widgets/device/stats_card.dart';

class DevicesTab extends StatefulWidget {
  final bool isDark;

  const DevicesTab({super.key, required this.isDark});

  @override
  State<DevicesTab> createState() => _DevicesTabState();
}

class _DevicesTabState extends State<DevicesTab> {
  late DeviceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DeviceController();
    _controller.initDevices();
  }

  @override
  Widget build(BuildContext context) {
    final devices = _controller.devices;
    final connectedDevices =
        devices.where((d) => d.status == ConnectionStatus.connected).length;
    final totalDevices = devices.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Card
        StatsCard(
          isDark: widget.isDark,
          connectedDevices: connectedDevices,
          totalDevices: totalDevices
          ),

          const SizedBox(height: 24),

          // Quick Actions
          QuickActions(controller: _controller),

          const SizedBox(height: 24),

          // Device List Header

              Text(
                'My Devices',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor(widget.isDark),
                ),
              ),


          const SizedBox(height: 16),

          // Devices List
          ...devices.map(
            (device) => DeviceCard(
              device: device,
              isDark: widget.isDark,
              onConnect: () {
                _controller.connectDevice(context, device);
                setState(() {});
              },
              onDisconnect: () {
                _controller.disconnectDevice(context, device);
                setState(() {});
              },
              onSync: () {
                _controller.syncDevice(context, device);
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
