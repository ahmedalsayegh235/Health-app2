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
    with TickerProviderStateMixin { 
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeIn,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _headerAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ActivityHeader(
              isDark: isDark,
              tabController: _tabController,
              scaffoldKey: widget.scaffoldKey,
            ),
          ),
        ),
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
