import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/models/chat_model.dart';
import 'package:health/models/user_model.dart';
import 'package:health/patient_views/tabs/widgets/chatscreen.dart';
import 'package:provider/provider.dart';

class DrChatTab extends StatelessWidget {
  const DrChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // ---------- TabBar ----------
          Container(
            color: AppTheme.cardColor(isDarkMode),
            child: const TabBar(
              labelColor: AppTheme.lightgreen,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.lightgreen,
              indicatorWeight: 3,
              tabs: [
                Tab(text: "Requests"),
                Tab(text: "Active Chats"),
              ],
            ),
          ),

          // ---------- TabBar Views ----------
          Expanded(
            child: TabBarView(
              children: [
                // ---------- Doctor Requests ----------
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chats")
                      .where("members", arrayContains: currentUserId)
                      .where("isAccept", isEqualTo: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(child: Text("No requests yet"));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var chat = ChatModel.fromFirestore(docs[index]);
                        final patientId = chat.members!.firstWhere(
                          (id) => id != currentUserId,
                        );
                        return FutureBuilder<UserModel?>(
                          future: UserModel.getUserData(patientId),
                          builder: (context, snap) {
                            if (!snap.hasData) {
                              return const SizedBox();
                            }
                            var patient = snap.data!;

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.lightgreen,
                                  child: Text(
                                    patient.name?.substring(0, 1) ?? "?",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  patient.name ?? "Unknown",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textColor(isDarkMode),
                                  ),
                                ),
                                subtitle: Text(
                                  patient.email ?? "",
                                  style: TextStyle(
                                    color: AppTheme.textSecondaryColor(
                                      isDarkMode,
                                    ),
                                  ),
                                ),
                                trailing: ElevatedButton.icon(
                                  icon: const Icon(Icons.check, size: 18),
                                  label: const Text("Accept"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.lightgreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection("chats")
                                        .doc(chat.id)
                                        .update({"isAccept": true});
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                // ---------- Doctor Active Chats ----------
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chats")
                      .where("members", arrayContains: currentUserId)
                      .where("isAccept", isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(child: Text("No active chats"));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var chat = ChatModel.fromFirestore(docs[index]);
                        final otherId = chat.members!.firstWhere(
                          (id) => id != currentUserId,
                        );
                        return FutureBuilder<UserModel?>(
                          future: UserModel.getUserData(otherId),
                          builder: (context, snap) {
                            if (!snap.hasData) return const SizedBox();
                            var user = snap.data!;

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                title: Text(
                                  user.name ?? "Unknown",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textColor(isDarkMode),
                                  ),
                                ),
                                subtitle: Text(
                                  user.role ?? "",
                                  style: TextStyle(
                                    color: AppTheme.textSecondaryColor(
                                      isDarkMode,
                                    ),
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chat_bubble_outline,
                                  color: AppTheme.lightgreen,
                                ),
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
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
