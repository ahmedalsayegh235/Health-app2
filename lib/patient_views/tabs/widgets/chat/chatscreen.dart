import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/models/chat_model.dart';
import 'package:health/models/user_model.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final UserModel otherUser;

  const ChatScreen({super.key, required this.chatId, required this.otherUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isTyping = false;
  String _messagePreview = '';

  @override
  @override
void initState() {
  super.initState();

  _fadeController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  _fadeAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _fadeController,
    curve: Curves.easeInOut,
  ));

  _fadeController.forward();

  _controller.addListener(_onTextChanged);
}

  void _onTextChanged() {
    setState(() {
      _isTyping = _controller.text.trim().isNotEmpty;
      _messagePreview = _controller.text;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final chatRef = FirebaseFirestore.instance.collection("chats").doc(widget.chatId);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(isDark),
      appBar: _buildModernAppBar(isDark),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Messages area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.backgroundColor(isDark),
                      AppTheme.backgroundColor(isDark).withValues(alpha: .95.clamp(0.0, 1.0)),
                    ],
                  ),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: chatRef
                      .collection("messages")
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return _buildLoadingState(isDark);
                    }

                    var msgs = snapshot.data!.docs
                        .map((doc) => MessageModel.fromFirestore(doc))
                        .toList();

                    if (msgs.isEmpty) {
                      return _buildEmptyState(isDark);
                    }

                    return _buildMessagesList(msgs, currentUserId, isDark);
                  },
                ),
              ),
            ),

            // Input area
            _buildModernInputBar(chatRef, currentUserId, isDark, isDarkMode),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.headerGradient(isDark),
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          // Doctor avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: .3),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.local_hospital,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Doctor info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUser.name ?? "Doctor",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.videocam,
              color: Colors.white,
              size: 18,
            ),
          ),
          onPressed: () {
            // Video call functionality
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 18,
            ),
          ),
          onPressed: () {
            _showOptionsMenu(context);
          },
        ),
        const SizedBox(width: 16),
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
            'Loading messages...',
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppTheme.headerGradient(isDark),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Start your consultation',
            style: TextStyle(
              color: AppTheme.textColor(isDark),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to Dr. ${widget.otherUser.name}',
            style: TextStyle(
              color: AppTheme.textSecondaryColor(isDark),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<MessageModel> msgs, String currentUserId, bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: msgs.length,
      itemBuilder: (context, index) {
        var msg = msgs[index];
        bool isMe = msg.sendBy == currentUserId;
        bool showAvatar = index == msgs.length - 1 || 
            msgs[index + 1].sendBy != msg.sendBy;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: _buildMessageBubble(msg, isMe, showAvatar, isDark),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe, bool showAvatar, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) _buildAvatar(),
          if (!isMe && !showAvatar) const SizedBox(width: 40),
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isMe
                    ? LinearGradient(
                        colors: AppTheme.headerGradient(isDark),
                      )
                    : null,
                color: !isMe ? AppTheme.cardColor(isDark) : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(!isMe ? 4 : 18),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMe 
                        ? AppTheme.lightgreen.withOpacity(0.3)
                        : AppTheme.shadowColor(isDark),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text ?? "",
                    style: TextStyle(
                      color: isMe ? Colors.white : AppTheme.textColor(isDark),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(msg.timestamp),
                    style: TextStyle(
                      color: isMe 
                          ? Colors.white.withOpacity(0.8)
                          : AppTheme.textSecondaryColor(isDark),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isMe && showAvatar) _buildMyAvatar(),
          if (isMe && !showAvatar) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.headerGradient(false),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.local_hospital,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildMyAvatar() {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: AppTheme.lightgreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildModernInputBar(
    DocumentReference chatRef,
    String currentUserId,
    bool isDark,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(isDark),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor(isDark),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.lightgreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  color: AppTheme.lightgreen,
                  size: 22,
                ),
                onPressed: () {
                  _showAttachmentOptions(context);
                },
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey.shade800.withOpacity(0.5)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isTyping 
                        ? AppTheme.lightgreen.withOpacity(0.5)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    hintStyle: TextStyle(
                      color: AppTheme.textSecondaryColor(isDark),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(
                    color: AppTheme.textColor(isDark),
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: _isTyping
                    ? LinearGradient(colors: AppTheme.headerGradient(isDark))
                    : null,
                color: !_isTyping ? AppTheme.textSecondaryColor(isDark) : null,
                borderRadius: BorderRadius.circular(22),
                boxShadow: _isTyping
                    ? [
                        BoxShadow(
                          color: AppTheme.lightgreen.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: IconButton(
                icon: Icon(
                  _isTyping ? Icons.send_rounded : Icons.mic,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _isTyping
                    ? () => _sendMessage(chatRef, currentUserId)
                    : () {
                        // Voice message functionality
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage(DocumentReference chatRef, String currentUserId) async {
    if (_controller.text.trim().isNotEmpty) {
      final messageText = _controller.text.trim();
      _controller.clear();
      setState(() {
        _isTyping = false;
      });

      try {
        await chatRef.collection("messages").add({
          "text": messageText,
          "sendBy": currentUserId,
          "timestamp": FieldValue.serverTimestamp(),
        });

        // Auto-scroll to bottom
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A2E)
              : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person, color: AppTheme.lightgreen),
              title: Text('View Doctor Profile'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to doctor profile
              },
            ),
            ListTile(
              leading: Icon(Icons.medical_services, color: AppTheme.lightgreen),
              title: Text('Medical History'),
              onTap: () {
                Navigator.pop(context);
                // View medical history
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: AppTheme.lightgreen),
              title: Text('Mute Notifications'),
              onTap: () {
                Navigator.pop(context);
                // Mute notifications
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: Colors.red),
              title: Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                _showBlockConfirmation(context);
              },
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: 'Close',
              onPressed: () => Navigator.pop(context),
              
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A2E)
              : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: AppTheme.lightgreen),
              title: Text('Photo Library'),
              onTap: () {
                Navigator.pop(context);
                // Open photo library
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppTheme.lightgreen),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // Open camera
              },
            ),
            ListTile(
              leading: Icon(Icons.insert_drive_file, color: AppTheme.lightgreen),
              title: Text('Documents'),
              onTap: () {
                Navigator.pop(context);
                // Open document picker
              },
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Block User'),
        content: Text('Are you sure you want to block Dr. ${widget.otherUser.name}? You will no longer receive messages from them.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement block functionality
            },
            child: Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

 String _formatTime(dynamic timestamp) {
  if (timestamp == null) return '';

  DateTime dateTime;

  if (timestamp is Timestamp) {
    dateTime = timestamp.toDate();
  } else if (timestamp is DateTime) {
    dateTime = timestamp;
  } else {
    return '';
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (messageDate == today) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  } else if (messageDate == yesterday) {
    return 'Yesterday ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  } else {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
}