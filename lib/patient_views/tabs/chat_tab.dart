import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/controllers/chat_controller.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/models/user_model.dart';
import 'package:health/patient_views/tabs/widgets/chat/chatscreen.dart';
import 'package:health/patient_views/tabs/widgets/chat/chat_header.dart';
import 'package:provider/provider.dart';

class ChatTab extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const ChatTab({super.key, this.scaffoldKey});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late ChatLogic _chatLogic;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _chatLogic = ChatLogic();
    _startAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
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
      curve: Curves.easeOutQuart,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      children: [
        // Animated Header
        SlideTransition(
          position: _slideAnimation,
          child: ChatHeader(
            isDark: isDark,
            scaffoldKey: widget.scaffoldKey,
          ),
        ),
        
        // Animated Content
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.backgroundColor(isDark),
                    AppTheme.backgroundColor(isDark).withOpacity(0.95),
                  ],
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatLogic.getDoctorsStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return _buildLoadingState(isDark);
                  }

                  var doctors = snapshot.data!.docs;

                  if (doctors.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  return _buildDoctorsList(doctors, currentUserId, isDark);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightgreen),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading doctors...',
            style: TextStyle(
              color: AppTheme.textSecondaryColor(isDark),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_hospital_outlined,
            size: 64,
            color: AppTheme.textSecondaryColor(isDark),
          ),
          const SizedBox(height: 16),
          Text(
            'No doctors available',
            style: TextStyle(
              color: AppTheme.textColor(isDark),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check back later',
            style: TextStyle(
              color: AppTheme.textSecondaryColor(isDark),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList(List<QueryDocumentSnapshot> doctors, String currentUserId, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
          curve: Curves.easeOutBack,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: _buildDoctorCard(doctors[index], currentUserId, isDark),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDoctorCard(QueryDocumentSnapshot doctor, String currentUserId, bool isDark) {
    final doctorId = doctor.id;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: AppTheme.cardDecoration(isDark, borderRadius: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Optional: Add doctor profile tap functionality
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatLogic.getChatStream(UserModel.userData.id!),
                builder: (context, chatSnapshot) {
                  if (!chatSnapshot.hasData) {
                    return _buildDoctorCardLoading(doctor, isDark);
                  }

                  var chats = _chatLogic.filterChatsForDoctor(
                    chatSnapshot.data!.docs,
                    doctorId,
                  );

                  Widget actionButton = _buildActionButton(
                    chats,
                    doctorId,
                    doctor,
                    isDarkMode,
                    isDark,
                  );

                  return _buildDoctorCardContent(doctor, actionButton, isDark);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCardLoading(QueryDocumentSnapshot doctor, bool isDark) {
    return Row(
      children: [
        _buildDoctorAvatar(isDark),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctor["name"] ?? "Doctor",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor(isDark),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightgreen),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCardContent(QueryDocumentSnapshot doctor, Widget actionButton, bool isDark) {
    return Row(
      children: [
        _buildDoctorAvatar(isDark),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctor["name"] ?? "Doctor",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor(isDark),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
        actionButton,
      ],
    );
  }

  Widget _buildDoctorAvatar(bool isDark) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.headerGradient(isDark),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightgreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.local_hospital,
        color: Colors.white,
        size: 25,
      ),
    );
  }

  Widget _buildActionButton(
    List<QueryDocumentSnapshot> chats,
    String doctorId,
    QueryDocumentSnapshot doctor,
    bool isDarkMode,
    bool isDark,
  ) {
    if (chats.isEmpty) {
      return _buildRequestButton(doctorId, doctor, isDarkMode);
    }

    var chat = chats.first;
    bool accepted = chat["isAccept"] ?? false;

    if (accepted) {
      return _buildOpenChatButton(chat, doctor, isDarkMode, isDark);
    } else {
      return _buildPendingButton(isDarkMode);
    }
  }

  Widget _buildRequestButton(String doctorId, QueryDocumentSnapshot doctor, bool isDarkMode) {
    return CustomButton(
      text: "Request",
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      onPressed: () => _chatLogic.sendChatRequest(
        context,
        doctorId,
        doctor["name"],
      ),
      gradientColors: [
        Colors.blue.shade500,
        Colors.blue.shade400,
      ],
      height: 38,
      width: 100,
      borderRadius: BorderRadius.circular(16),
    );
  }

  Widget _buildOpenChatButton(
    QueryDocumentSnapshot chat,
    QueryDocumentSnapshot doctor,
    bool isDarkMode,
    bool isDark,
  ) {
    return CustomButton(
      text: "Chat",
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: chat.id,
              otherUser: UserModel.fromFirestore(doctor),
            ),
          ),
        );
      },
      gradientColors: AppTheme.headerGradient(isDark),
      height: 38,
      width: 100,
      borderRadius: BorderRadius.circular(16),
    );
  }

  Widget _buildPendingButton(bool isDarkMode) {
    return Container(
      height: 38,
      width: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade300,
            Colors.orange.shade200,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "Pending",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}