import 'package:flutter/material.dart';
import 'package:health/patient_views/tabs/widgets/activity/device_tab.dart';
import 'package:health/patient_views/tabs/widgets/activity/ecg_tab.dart';
import 'package:health/patient_views/tabs/widgets/activity/heartrate_tab.dart';
import 'package:health/patient_views/tabs/widgets/activity/spo2_tab.dart';
import 'package:health/patient_views/tabs/widgets/activity/widgets/activity_header.dart';

class ActivityTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey; 
  const ActivityTab({super.key, required this.scaffoldKey});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Modern Header with Integrated Tabs
        ActivityHeader(
          isDark: isDark,
          tabController: _tabController,
          scaffoldKey: widget.scaffoldKey, // pass it here
        ),

        // Tab Views
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TabBarView(
              controller: _tabController,
              children: [
                HeartRateTab(isDark: isDark),
                SpO2Tab(isDark: isDark),
                ECGTab(isDark: isDark),
                DevicesTab(isDark: isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
