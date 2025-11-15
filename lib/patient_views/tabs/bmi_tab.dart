import 'package:flutter/material.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/components/custom_graph.dart';
import 'package:health/controllers/activities_provider.dart';
import 'package:health/controllers/BMI_controller.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/helpers/tab_helper.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/models/Reading.dart';
import 'package:health/patient_views/tabs/widgets/bmi/bmi_header.dart';
import 'package:provider/provider.dart';

class BmiTab extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const BmiTab({super.key, this.scaffoldKey});

  @override
  State<BmiTab> createState() => _BmiTabState();
}

class _BmiTabState extends State<BmiTab>
    with SingleTickerProviderStateMixin {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showAllReadings = false;
  bool _isSubmitting = false;
  
  late AnimationController _animationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<double> _graphFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Header slides down from top
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
    ));

    // Current BMI card fades in
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
    ));

    // Form fades in
    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
    ));

    // Graph fades in
    _graphFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
    ));

    // Reading cards fade in
    _cardFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
    ));
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _calculateAndSaveBmi() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final weight = double.parse(_weightController.text);
    final height = double.parse(_heightController.text);

    final bmiController = context.read<BmiController>();
    final success = await bmiController.addBmiReading(
      weight: weight,
      height: height,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      final bmi = BmiController.calculateBmi(weight, height);
      final category = BmiController.getBmiCategory(bmi);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'BMI recorded: ${bmi.toStringAsFixed(1)} - $category',
          ),
          backgroundColor: AppTheme.lightgreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Save to activity log
      final activityProvider = context.read<ActivityProvider>();
      await activityProvider.addActivity({
        'title': 'BMI recorded: ${bmi.toStringAsFixed(1)} - $category',
        'icon': 'scale',
        'iconColor': BmiController.getBmiCategoryColor(bmi).value,
        'timestamp': DateTime.now().toIso8601String(),
      });

      _weightController.clear();
      _heightController.clear();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save BMI reading'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showReadingDetail(HealthReading reading) {
    final bmi = reading.value;
    final category = BmiController.getBmiCategory(bmi);
    final advice = BmiController.getBmiAdvice(bmi);

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppTheme.cardGradient(isDark),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BmiController.getBmiCategoryColor(bmi)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.monitor_weight,
                    size: 48,
                    color: BmiController.getBmiCategoryColor(bmi),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'BMI Reading',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${bmi.toStringAsFixed(1)} kg/m²',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: BmiController.getBmiCategoryColor(bmi),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: BmiController.getBmiCategoryColor(bmi)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: BmiController.getBmiCategoryColor(bmi),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Weight',
                        '${reading.metadata?['weight'] ?? '--'} kg',
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Height',
                        '${reading.metadata?['height'] ?? '--'} cm',
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Date',
                        formatTime(reading.timestamp),
                        isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightgreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightgreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.lightgreen,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          advice,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textColor(isDark),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  onPressed: () => Navigator.pop(context),
                  text: 'Close',
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                  height: 45,
                  gradientColors: [AppTheme.lightgreen, AppTheme.lightgreen],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor(isDark),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor(isDark),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final bmiController = context.watch<BmiController>();
    final userId = bmiController.userId;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(isDark),
      body: Column(
        children: [
          // Animated Header
          SlideTransition(
            position: _headerSlideAnimation,
            child: BmiHeader(isDark: isDark, scaffoldKey: widget.scaffoldKey),
          ),
          Expanded(
            child: StreamBuilder<List<HealthReading>>(
              stream: bmiController.bmiStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading readings: ${snapshot.error}',
                      style: TextStyle(color: AppTheme.textColor(isDark)),
                    ),
                  );
                }
            
                final readings = snapshot.data ?? [];
                final currentReading = readings.isNotEmpty ? readings.first : null;
            
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animated Current BMI Display
                      FadeTransition(
                        opacity: _contentFadeAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(_contentFadeAnimation),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: currentReading != null
                                    ? [
                                        BmiController.getBmiCategoryColor(
                                                currentReading.value)
                                            .withValues(alpha: 0.1),
                                        BmiController.getBmiCategoryColor(
                                                currentReading.value)
                                            .withValues(alpha: 0.05),
                                      ]
                                    : [
                                        AppTheme.lightgreen.withValues(alpha: 0.1),
                                        AppTheme.lightgreen.withValues(alpha: 0.05),
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: currentReading != null
                                    ? BmiController.getBmiCategoryColor(
                                            currentReading.value)
                                        .withValues(alpha: 0.2)
                                    : AppTheme.lightgreen.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: currentReading != null
                                          ? [
                                              BmiController.getBmiCategoryColor(
                                                      currentReading.value)
                                                  .withValues(alpha: 0.2),
                                              BmiController.getBmiCategoryColor(
                                                      currentReading.value)
                                                  .withValues(alpha: 0.1),
                                            ]
                                          : [
                                              AppTheme.lightgreen
                                                  .withValues(alpha: 0.2),
                                              AppTheme.lightgreen
                                                  .withValues(alpha: 0.1),
                                            ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.monitor_weight,
                                    size: 48,
                                    color: currentReading != null
                                        ? BmiController.getBmiCategoryColor(
                                            currentReading.value)
                                        : AppTheme.lightgreen,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (currentReading != null) ...[
                                  Text(
                                    currentReading.value.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textColor(isDark),
                                    ),
                                  ),
                                  Text(
                                    'kg/m²',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: AppTheme.textSecondaryColor(isDark),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: BmiController.getBmiCategoryColor(
                                              currentReading.value)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      BmiController.getBmiCategory(
                                          currentReading.value),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: BmiController.getBmiCategoryColor(
                                            currentReading.value),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    '--',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textSecondaryColor(isDark),
                                    ),
                                  ),
                                  Text(
                                    'kg/m²',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: AppTheme.textSecondaryColor(isDark),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
            
                      const SizedBox(height: 24),
            
                      // Animated Input Form
                      FadeTransition(
                        opacity: _formFadeAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(_formFadeAnimation),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppTheme.cardGradient(isDark),
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Calculate Your BMI',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textColor(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _weightController,
                                    keyboardType: TextInputType.number,
                                    style:
                                        TextStyle(color: AppTheme.textColor(isDark)),
                                    decoration: InputDecoration(
                                      labelText: 'Weight (kg)',
                                      labelStyle: TextStyle(
                                          color:
                                              AppTheme.textSecondaryColor(isDark)),
                                      hintText: 'Enter your weight',
                                      hintStyle: TextStyle(
                                          color:
                                              AppTheme.textSecondaryColor(isDark)),
                                      prefixIcon: Icon(Icons.fitness_center,
                                          color: AppTheme.lightgreen),
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.black.withValues(alpha: 0.03),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your weight';
                                      }
                                      final weight = double.tryParse(value);
                                      if (weight == null || weight <= 0) {
                                        return 'Please enter a valid weight';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _heightController,
                                    keyboardType: TextInputType.number,
                                    style:
                                        TextStyle(color: AppTheme.textColor(isDark)),
                                    decoration: InputDecoration(
                                      labelText: 'Height (cm)',
                                      labelStyle: TextStyle(
                                          color:
                                              AppTheme.textSecondaryColor(isDark)),
                                      hintText: 'Enter your height',
                                      hintStyle: TextStyle(
                                          color:
                                              AppTheme.textSecondaryColor(isDark)),
                                      prefixIcon: Icon(Icons.height,
                                          color: AppTheme.lightgreen),
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.black.withValues(alpha: 0.03),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your height';
                                      }
                                      final height = double.tryParse(value);
                                      if (height == null || height <= 0) {
                                        return 'Please enter a valid height';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  CustomButton(
                                    onPressed: userId != null ? _calculateAndSaveBmi : null,
                                    text: 'Calculate BMI',
                                    isLoading: _isSubmitting,
                                    height: 50,
                                    gradientColors: [
                                      AppTheme.lightgreen,
                                      AppTheme.lightgreen.withValues(alpha: 0.8),
                                    ],
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (userId == null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Login required to save BMI',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondaryColor(isDark),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
            
                      const SizedBox(height: 24),
            
                      // Animated Graph
                      if (readings.isNotEmpty)
                        FadeTransition(
                          opacity: _graphFadeAnimation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(_graphFadeAnimation),
                            child: CustomHealthGraph(
                              readings: readings,
                              unit: 'kg/m²',
                              isDark: isDark,
                              lineColor: currentReading != null
                                  ? BmiController.getBmiCategoryColor(
                                      currentReading.value)
                                  : AppTheme.lightgreen,
                              title: 'BMI History',
                            ),
                          ),
                        ),
            
                      const SizedBox(height: 24),
            
                      // Animated Readings History Header
                      FadeTransition(
                        opacity: _cardFadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Previous Readings (${readings.length})',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor(isDark),
                              ),
                            ),
                            if (readings.length > 5)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showAllReadings = !_showAllReadings;
                                  });
                                },
                                child: Text(
                                  _showAllReadings ? 'View Less' : 'View All',
                                  style: TextStyle(
                                    color: AppTheme.lightgreen,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
            
                      const SizedBox(height: 16),
            
                      // Empty State
                      if (readings.isEmpty)
                        FadeTransition(
                          opacity: _cardFadeAnimation,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppTheme.cardGradient(isDark),
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.monitor_weight_outlined,
                                  size: 48,
                                  color: AppTheme.textSecondaryColor(isDark),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  userId == null
                                      ? 'Login to view readings'
                                      : 'No readings yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textSecondaryColor(isDark),
                                  ),
                                ),
                                if (userId != null)
                                  Text(
                                    'Add your first BMI reading above',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondaryColor(isDark),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
            
                      // Animated Reading Cards with staggered delays
                      ...(_showAllReadings ? readings : readings.take(5))
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final reading = entry.value;
                        
                        return FadeTransition(
                          opacity: Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              0.5 + (index * 0.05).clamp(0.0, 0.8),
                              0.8 + (index * 0.05).clamp(0.0, 1.0),
                              curve: Curves.easeOut,
                            ),
                          )),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                0.5 + (index * 0.05).clamp(0.0, 0.8),
                                0.8 + (index * 0.05).clamp(0.0, 1.0),
                                curve: Curves.easeOut,
                              ),
                            )),
                            child: _buildReadingCard(reading, isDark),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingCard(HealthReading reading, bool isDark) {
    final bmi = reading.value;
    final category = BmiController.getBmiCategory(bmi);
    final color = BmiController.getBmiCategoryColor(bmi);

    return GestureDetector(
      onTap: () => _showReadingDetail(reading),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppTheme.cardGradient(isDark),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.monitor_weight,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${bmi.toStringAsFixed(1)} kg/m²',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor(isDark),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reading.metadata?['weight'] ?? '--'} kg • ${reading.metadata?['height'] ?? '--'} cm',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondaryColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatTime(reading.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondaryColor(isDark),
            ),
          ],
        ),
      ),
    );
  }
}