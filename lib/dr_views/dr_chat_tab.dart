import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/dr_views/chat_widget/dr_chat_header.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/models/chat_model.dart';
import 'package:health/models/user_model.dart';
import 'package:health/patient_views/tabs/widgets/chat/chatscreen.dart';


class DrChatTab extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const DrChatTab({super.key, this.scaffoldKey});

  @override
  State<DrChatTab> createState() => _DrChatTabState();
}

class _DrChatTabState extends State<DrChatTab>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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
      if (mounted) {
        _slideController.forward();
      }
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward();
      }
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
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Animated Header
        SlideTransition(
          position: _slideAnimation,
          child: DrChatHeader(
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
                    AppTheme.backgroundColor(isDark).withValues(alpha: .95),
                  ],
                ),
              ),
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    // Custom TabBar with proper animation handling
                    AnimatedBuilder(
                      animation: _fadeController,
                      builder: (context, child) {
                        final animationValue = _fadeController.value.clamp(0.0, 1.0);
                        return Transform.scale(
                          scale: 0.8 + (animationValue * 0.2), // Scale from 0.8 to 1.0
                          child: Opacity(
                            opacity: animationValue,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: AppTheme.cardDecoration(isDark, borderRadius: 16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: TabBar(
                                  labelColor: Colors.white,
                                  unselectedLabelColor: AppTheme.textSecondaryColor(isDark),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: AppTheme.headerGradient(isDark),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  unselectedLabelStyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  tabs: const [
                                    Tab(
                                      icon: Icon(Icons.inbox_outlined, size: 20),
                                      text: "Requests",
                                    ),
                                    Tab(
                                      icon: Icon(Icons.chat_bubble_outline, size: 20),
                                      text: "Active Chats",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // TabBar Views
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildRequestsTab(currentUserId, isDark),
                          _buildActiveChatsTab(currentUserId, isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestsTab(String currentUserId, bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("chats")
          .where("members", arrayContains: currentUserId)
          .where("isAccept", isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(isDark);
        }

        if (snapshot.hasError) {
          return _buildErrorState(isDark, "Error loading requests");
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            isDark,
            icon: Icons.inbox_outlined,
            title: "No requests yet",
            subtitle: "Patient requests will appear here",
          );
        }

        var docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            return _buildAnimatedCard(
              index: index,
              child: _buildRequestCard(docs[index], currentUserId, isDark),
            );
          },
        );
      },
    );
  }

  Widget _buildActiveChatsTab(String currentUserId, bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("chats")
          .where("members", arrayContains: currentUserId)
          .where("isAccept", isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(isDark);
        }

        if (snapshot.hasError) {
          return _buildErrorState(isDark, "Error loading chats");
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            isDark,
            icon: Icons.chat_bubble_outline,
            title: "No active chats",
            subtitle: "Accepted chats will appear here",
          );
        }

        var docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            return _buildAnimatedCard(
              index: index,
              child: _buildActiveChatCard(docs[index], currentUserId, isDark),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedCard({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 800)),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        // Ensure value is properly clamped
        final clampedValue = value.clamp(0.0, 1.0);
        final scaleValue = (0.8 + (clampedValue * 0.2)).clamp(0.8, 1.0);
        
        return Transform.scale(
          scale: scaleValue,
          child: Opacity(
            opacity: clampedValue,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildRequestCard(QueryDocumentSnapshot doc, String currentUserId, bool isDark) {
    var chat = ChatModel.fromFirestore(doc);
    final patientId = chat.members!.firstWhere((id) => id != currentUserId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.cardDecoration(isDark, borderRadius: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: FutureBuilder<UserModel?>(
            future: UserModel.getUserData(patientId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return _buildCardLoading(isDark);
              }

              if (snap.hasError || !snap.hasData) {
                return _buildCardError(isDark);
              }

              var patient = snap.data!;
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _buildPatientAvatar(patient, isDark),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.name ?? "Unknown Patient",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              patient.email ?? "",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondaryColor(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildAcceptButton(chat, isDark),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActiveChatCard(QueryDocumentSnapshot doc, String currentUserId, bool isDark) {
    var chat = ChatModel.fromFirestore(doc);
    final otherId = chat.members!.firstWhere((id) => id != currentUserId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.cardDecoration(isDark, borderRadius: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: FutureBuilder<UserModel?>(
            future: UserModel.getUserData(otherId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return _buildCardLoading(isDark);
              }

              if (snap.hasError || !snap.hasData) {
                return _buildCardError(isDark);
              }

              var user = snap.data!;
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: chat.id!,
                        otherUser: user,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _buildPatientAvatar(user, isDark),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name ?? "Unknown Patient",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.role ?? "Patient",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondaryColor(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppTheme.headerGradient(isDark),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPatientAvatar(UserModel user, bool isDark) {
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
            color: AppTheme.lightgreen.withValues(alpha: .3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          (user.name?.isNotEmpty ?? false) ? user.name!.substring(0, 1).toUpperCase() : "P",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAcceptButton(ChatModel chat, bool isDark) {
    return CustomButton(
      text: "Accept",
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      onPressed: () async {
        try {
          await FirebaseFirestore.instance
              .collection("chats")
              .doc(chat.id)
              .update({"isAccept": true});
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error accepting request: $e'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        }
      },
      gradientColors: [
        AppTheme.successColor,
        AppTheme.successColor.withValues(alpha: .8),
      ],
      height: 38,
      width: 100,
      borderRadius: BorderRadius.circular(16),
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
            'Loading...',
            style: TextStyle(
              color: AppTheme.textSecondaryColor(isDark),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, {required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.textSecondaryColor(isDark),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.textColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: AppTheme.textSecondaryColor(isDark),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: TextStyle(
                color: AppTheme.textColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: AppTheme.textSecondaryColor(isDark),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardLoading(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.textSecondaryColor(isDark).withValues(alpha: .3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 18,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondaryColor(isDark).withValues(alpha: .3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 150,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondaryColor(isDark).withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightgreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardError(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.error_outline,
              color: AppTheme.errorColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Error loading user",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Please try again later",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}