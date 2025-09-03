import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:health/helpers/app_theme.dart';

class CreateAppointmentDialog extends StatefulWidget {
  final String doctorId;
  final bool isDarkMode;

  const CreateAppointmentDialog({
    super.key,
    required this.doctorId,
    required this.isDarkMode,
  });

  @override
  State<CreateAppointmentDialog> createState() => _CreateAppointmentDialogState();
}

class _CreateAppointmentDialogState extends State<CreateAppointmentDialog>
    with TickerProviderStateMixin {
  final dateFormat = DateFormat('MMM dd, yyyy');
  final timeFormat = DateFormat('HH:mm');
  final _notesController = TextEditingController();
  
  DateTime? startTime;
  DateTime? endTime;
  String? selectedPatientId;
  bool isSaving = false;
  
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final now = DateTime.now();
    final initialDate = now.add(const Duration(days: 1));
    
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppTheme.lightgreen,
              brightness: widget.isDarkMode ? Brightness.dark : Brightness.light,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppTheme.cardColor(widget.isDarkMode),
              headerBackgroundColor: AppTheme.lightgreen,
              headerForegroundColor: Colors.white,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return AppTheme.textColor(widget.isDarkMode);
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.lightgreen;
                }
                return null;
              }),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppTheme.lightgreen,
                brightness: widget.isDarkMode ? Brightness.dark : Brightness.light,
              ),
              timePickerTheme: TimePickerThemeData(
                backgroundColor: AppTheme.cardColor(widget.isDarkMode),
                dialBackgroundColor: AppTheme.backgroundColor(widget.isDarkMode),
                dialHandColor: AppTheme.lightgreen,
                dialTextColor: AppTheme.textColor(widget.isDarkMode),
                entryModeIconColor: AppTheme.lightgreen,
                hourMinuteTextColor: AppTheme.textColor(widget.isDarkMode),
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (time != null) {
        final chosen = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        setState(() {
          startTime = chosen;
          endTime = chosen.add(const Duration(hours: 1));
        });
      }
    }
  }

  Future<void> _pickEndTime() async {
    if (startTime == null) return;
    
    final date = await showDatePicker(
      context: context,
      initialDate: startTime!,
      firstDate: startTime!,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppTheme.lightgreen,
              brightness: widget.isDarkMode ? Brightness.dark : Brightness.light,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppTheme.cardColor(widget.isDarkMode),
              headerBackgroundColor: AppTheme.lightgreen,
              headerForegroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null && mounted) {
      final initialTime = TimeOfDay.fromDateTime(startTime!.add(const Duration(hours: 1)));
      final time = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppTheme.lightgreen,
                brightness: widget.isDarkMode ? Brightness.dark : Brightness.light,
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (time != null) {
        final chosen = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        
        if (chosen.isAfter(startTime!)) {
          setState(() {
            endTime = chosen;
          });
        } else {
          _showSnackBar('End time must be after start time', isError: true);
        }
      }
    }
  }

  Future<void> _saveAppointment() async {
    if (startTime == null || endTime == null) {
      _showSnackBar('Please select start and end times', isError: true);
      return;
    }

    // Check for conflicts
    final hasConflict = await _checkForConflicts();
    if (hasConflict) {
      _showSnackBar('Time slot conflicts with existing appointment', isError: true);
      return;
    }

    setState(() => isSaving = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.doctorId)
          .collection('appointments')
          .doc();

      String? patientName;
      if (selectedPatientId != null) {
        final patientDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(selectedPatientId!)
            .get();
        if (patientDoc.exists) {
          final patientData = patientDoc.data() as Map<String, dynamic>;
          patientName = patientData['name'];
        }
      }

      final appointmentData = <String, dynamic>{
        'doctorId': widget.doctorId,
        'startTime': Timestamp.fromDate(startTime!.toUtc()),
        'endTime': Timestamp.fromDate(endTime!.toUtc()),
        'status': selectedPatientId == null ? 'available' : 'booked',
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (selectedPatientId != null) {
        appointmentData['patientId'] = selectedPatientId;
      }
      if (patientName != null) {
        appointmentData['patientName'] = patientName;
      }
      if (_notesController.text.isNotEmpty) {
        appointmentData['notes'] = _notesController.text.trim();
      }

      await docRef.set(appointmentData);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => isSaving = false);
      if (mounted) {
        _showSnackBar('Failed to create appointment: ${e.toString()}', isError: true);
      }
    }
  }

  Future<bool> _checkForConflicts() async {
    if (startTime == null || endTime == null) return false;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.doctorId)
          .collection('appointments')
          .where('startTime', isLessThan: Timestamp.fromDate(endTime!.toUtc()))
          .where('endTime', isGreaterThan: Timestamp.fromDate(startTime!.toUtc()))
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : AppTheme.lightgreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _getDuration() {
    if (startTime == null || endTime == null) return '';
    final duration = endTime!.difference(startTime!);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          decoration: BoxDecoration(
            color: AppTheme.cardColor(widget.isDarkMode),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: widget.isDarkMode ? 0.5 : 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Header
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppTheme.headerGradient(widget.isDarkMode),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "New Appointment",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Schedule a new appointment slot",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: isSaving ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time Selection Section
                        _buildSectionHeader('Schedule Details', Icons.access_time),
                        const SizedBox(height: 16),
                        
                        // Start Time
                        _buildTimeSelector(
                          title: "Start Time",
                          subtitle: startTime == null
                              ? "Select start date & time"
                              : "${dateFormat.format(startTime!)} at ${timeFormat.format(startTime!)}",
                          onTap: isSaving ? null : _pickStartTime,
                          icon: Icons.play_arrow,
                          isSelected: startTime != null,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // End Time
                        _buildTimeSelector(
                          title: "End Time",
                          subtitle: endTime == null
                              ? "Select end date & time"
                              : "${dateFormat.format(endTime!)} at ${timeFormat.format(endTime!)}",
                          onTap: isSaving ? null : _pickEndTime,
                          icon: Icons.stop,
                          isSelected: endTime != null,
                          enabled: startTime != null,
                        ),

                        // Duration Display
                        if (startTime != null && endTime != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.lightgreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.lightgreen.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.timelapse,
                                  color: AppTheme.lightgreen,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Duration: ${_getDuration()}',
                                  style: TextStyle(
                                    color: AppTheme.textColor(widget.isDarkMode),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Patient Assignment Section
                        _buildSectionHeader('Patient Assignment', Icons.person_add),
                        const SizedBox(height: 16),
                        
                        Container(
                          decoration: BoxDecoration(
                            color: widget.isDarkMode 
                                ? Colors.white.withOpacity(0.05) 
                                : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.dividerColor(widget.isDarkMode),
                            ),
                          ),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .where('role', isEqualTo: 'patient')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                );
                              }
                              
                              final patients = snapshot.data!.docs;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  underline: const SizedBox.shrink(),
                                  dropdownColor: AppTheme.cardColor(widget.isDarkMode),
                                  value: selectedPatientId,
                                  hint: Text(
                                    "Leave empty for open appointment",
                                    style: TextStyle(
                                      color: AppTheme.textSecondaryColor(widget.isDarkMode),
                                    ),
                                  ),
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: null,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.public,
                                            size: 16,
                                            color: AppTheme.lightgreen,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            "all patients",
                                            style: TextStyle(
                                              color: AppTheme.textSecondaryColor(widget.isDarkMode),
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ...patients.map((doc) {
                                      final data = doc.data() as Map<String, dynamic>;
                                      return DropdownMenuItem<String>(
                                        value: doc.id,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppTheme.lightgreen.withOpacity(0.8),
                                                    AppTheme.darkgreen.withOpacity(0.8),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              data['name'] ?? 'Unnamed Patient',
                                              style: TextStyle(
                                                color: AppTheme.textColor(widget.isDarkMode),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: isSaving
                                      ? null
                                      : (value) {
                                          setState(() {
                                            selectedPatientId = value;
                                          });
                                        },
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Notes Section
                        _buildSectionHeader('Additional Notes', Icons.note_alt),
                        const SizedBox(height: 16),
                        
                        Container(
                          decoration: AppTheme.cardDecoration(widget.isDarkMode, borderRadius: 12),
                          child: TextField(
                            controller: _notesController,
                            enabled: !isSaving,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add any special instructions or notes...',
                              hintStyle: TextStyle(
                                color: AppTheme.textSecondaryColor(widget.isDarkMode),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            style: TextStyle(
                              color: AppTheme.textColor(widget.isDarkMode),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.dividerColor(widget.isDarkMode),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSaving ? null : () => Navigator.pop(context),
                        style: AppTheme.secondaryButtonStyle(widget.isDarkMode),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _saveAppointment,
                        style: AppTheme.primaryButtonStyle(widget.isDarkMode),
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Create"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.lightgreen.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.lightgreen,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: AppTheme.textColor(widget.isDarkMode),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector({
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required IconData icon,
    required bool isSelected,
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.lightgreen.withOpacity(0.1),
                    AppTheme.lightgreen.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: !isSelected
              ? widget.isDarkMode 
                  ? Colors.white.withOpacity(enabled ? 0.05 : 0.02) 
                  : Colors.grey.withOpacity(enabled ? 0.05 : 0.02)
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightgreen.withOpacity(0.5)
                : enabled 
                    ? AppTheme.dividerColor(widget.isDarkMode)
                    : AppTheme.dividerColor(widget.isDarkMode).withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightgreen.withOpacity(0.2)
                    : enabled 
                        ? AppTheme.lightgreen.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppTheme.lightgreen
                    : enabled 
                        ? AppTheme.lightgreen.withOpacity(0.7)
                        : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: enabled 
                          ? AppTheme.textColor(widget.isDarkMode)
                          : AppTheme.textSecondaryColor(widget.isDarkMode),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor(widget.isDarkMode),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: enabled 
                  ? AppTheme.textSecondaryColor(widget.isDarkMode)
                  : AppTheme.textSecondaryColor(widget.isDarkMode).withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}