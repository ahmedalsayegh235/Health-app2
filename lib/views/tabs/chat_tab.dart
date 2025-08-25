import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/models/chat_model.dart';
import 'package:health/models/user_model.dart';
import 'package:health/views/tabs/widgets/chatscreen.dart';
import 'package:provider/provider.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return DefaultTabController(
      length: UserModel.userData.role == 'doctor' ? 2 : 2, // tabs for both
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Chats"),
        ),
        body: 
                  // ---------- Doctor Requests ----------
                //   StreamBuilder(
                //     stream: FirebaseFirestore.instance
                //         .collection("chats")
                //         .where("members", arrayContains: currentUserId)
                //         .where("isAccept", isEqualTo: false)
                //         .snapshots(),
                //     builder: (context, snapshot) {
                //       if (!snapshot.hasData) return CircularProgressIndicator();
                //       var docs = snapshot.data!.docs;
                //       if (docs.isEmpty)
                //         return Center(child: Text("No requests yet"));
                //       return ListView.builder(
                //         itemCount: docs.length,
                //         itemBuilder: (context, index) {
                //           var chat = ChatModel.fromFirestore(docs[index]);
                //           final patientId = chat.members!.firstWhere(
                //             (id) => id != currentUserId,
                //           );
                //           return FutureBuilder<UserModel?>(
                //             future: UserModel.getUserData(patientId),
                //             builder: (context, snap) {
                //               if (!snap.hasData) return SizedBox();
                //               var patient = snap.data!;
                //               return ListTile(
                //                 title: Text(patient.name ?? "Unknown"),
                //                 subtitle: Text(patient.email ?? ""),
                //                 trailing: ElevatedButton(
                //                   onPressed: () async {
                //                     await FirebaseFirestore.instance
                //                         .collection("chats")
                //                         .doc(chat.id)
                //                         .update({"isAccept": true});
                //                   },
                //                   child: Text("Accept"),
                //                 ),
                //               );
                //             },
                //           );
                //         },
                //       );
                //     },
                //   ),

                //   // ---------- Doctor Active Chats ----------
                //   StreamBuilder(
                //     stream: FirebaseFirestore.instance
                //         .collection("chats")
                //         .where("members", arrayContains: currentUserId)
                //         .where("isAccept", isEqualTo: true)
                //         .snapshots(),
                //     builder: (context, snapshot) {
                //       if (!snapshot.hasData) return CircularProgressIndicator();
                //       var docs = snapshot.data!.docs;
                //       if (docs.isEmpty)
                //         return Center(child: Text("No active chats"));
                //       return ListView(
                //         children: docs.map((doc) {
                //           var chat = ChatModel.fromFirestore(doc);
                //           final otherId = chat.members!.firstWhere(
                //             (id) => id != currentUserId,
                //           );
                //           return FutureBuilder<UserModel?>(
                //             future: UserModel.getUserData(otherId),
                //             builder: (context, snap) {
                //               if (!snap.hasData) return SizedBox();
                //               var user = snap.data!;
                //               return ListTile(
                //                 title: Text(user.name ?? "Unknown"),
                //                 subtitle: Text(user.role ?? ""),
                //                 onTap: () {
                //                   Navigator.push(
                //                     context,
                //                     MaterialPageRoute(
                //                       builder: (_) => ChatScreen(
                //                         chatId: chat.id!,
                //                         otherUser: user,
                //                       ),
                //                     ),
                //                   );
                //                 },
                //               );
                //             },
                //           );
                //         }).toList(),
                //       );
                //     },
                //   ),
                // ]
               
                  // ---------- Patient Doctors ----------
               StreamBuilder(
  stream: FirebaseFirestore.instance
      .collection("users")
      .where("role", isEqualTo: "doctor")
      .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    var docs = snapshot.data!.docs;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var doctor = docs[index];
        final doctorId = doctor.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: AppTheme.cardColor(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("chats")
                  .where(
                    "members",
                    arrayContains: UserModel.userData.id,
                  )
                  .snapshots(),
              builder: (context, chatSnapshot) {
                if (!chatSnapshot.hasData) {
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          doctor["name"],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor(isDark),
                          ),
                        ),
                      ),
                      const CircularProgressIndicator(strokeWidth: 2),
                    ],
                  );
                }

                // Filter chats for this specific doctor
                var chats = chatSnapshot.data!.docs.where((doc) {
                  List members = doc["members"];
                  return members.contains(doctorId);
                }).toList();

                Widget actionBtn;

                if (chats.isEmpty) {
                  // No chat exists - show Request button
                  actionBtn = CustomButton(
                    text: "Request",
                    textStyle: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 12,
                    ),
                    onPressed: () async {
                      final patientId = UserModel.userData.id;

                      // Create new chat request
                      await FirebaseFirestore.instance
                          .collection("chats")
                          .add({
                        "members": [patientId, doctorId],
                        "isAccept": false,
                        "createdAt": FieldValue.serverTimestamp(),
                      });

                      // Optional: Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Request sent to Dr. ${doctor["name"]}"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    gradientColors: [
                      Colors.red.shade400,
                      Colors.red.shade300,
                    ],
                    height: 44,
                    width: 120,
                  );
                } else {
                  // Chat exists - check if accepted or pending
                  var chat = chats.first;
                  bool accepted = chat["isAccept"] ?? false;

                  if (accepted) {
                    // Chat accepted - show Open Chat button
                    actionBtn = CustomButton(
                      text: "Open Chat",
                      textStyle: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 12,
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
                      height: 44,
                      width: 120,
                    );
                  } else {
                    // Chat pending - show Pending button (disabled)
                    actionBtn = CustomButton(
                      textStyle: TextStyle(
                        color: isDarkMode ? Colors.grey : Colors.black54,
                        fontSize: 12,
                      ),
                      text: "Pending",
                      onPressed: null, // Disabled button
                      gradientColors: [
                        Colors.yellow.shade600,
                        Colors.yellow,
                      ],
                      height: 44,
                      width: 120,
                    );
                  }
                }

                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        doctor["name"],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor(isDark),
                        ),
                      ),
                    ),
                    actionBtn,
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  },
),

                  // // ---------- Patient Active Chats ----------
                  // StreamBuilder(
                  //   stream: FirebaseFirestore.instance
                  //       .collection("chats")
                  //       .where("members", arrayContains: currentUserId)
                  //       .where("isAccept", isEqualTo: true)
                  //       .snapshots(),
                  //   builder: (context, snapshot) {
                  //     if (!snapshot.hasData)
                  //       return const Center(child: CircularProgressIndicator());
                  //     var docs = snapshot.data!.docs;
                  //     final isDark =
                  //         Theme.of(context).brightness == Brightness.dark;

                  //     if (docs.isEmpty) {
                  //       return Center(
                  //         child: Text(
                  //           "No active chats",
                  //           style: TextStyle(
                  //             color: AppTheme.textSecondaryColor(isDark),
                  //             fontSize: 16,
                  //           ),
                  //         ),
                  //       );
                  //     }

                  //     return ListView.builder(
                  //       padding: const EdgeInsets.all(16),
                  //       itemCount: docs.length,
                  //       itemBuilder: (context, index) {
                  //         var chat = ChatModel.fromFirestore(docs[index]);
                  //         final otherId = chat.members!.firstWhere(
                  //           (id) => id != currentUserId,
                  //         );

                  //         return FutureBuilder<UserModel?>(
                  //           future: UserModel.getUserData(otherId),
                  //           builder: (context, snap) {
                  //             if (!snap.hasData) return const SizedBox();

                  //             var user = snap.data!;
                  //             return Card(
                  //               margin: const EdgeInsets.only(bottom: 16),
                  //               color: AppTheme.cardColor(isDark),
                  //               shape: RoundedRectangleBorder(
                  //                 borderRadius: BorderRadius.circular(20),
                  //               ),
                  //               elevation: 6,
                  //               child: Padding(
                  //                 padding: const EdgeInsets.all(16),
                  //                 child: Row(
                  //                   children: [
                  //                     CircleAvatar(
                  //                       radius: 28,
                  //                       backgroundColor: AppTheme.lightgreen
                  //                           .withAlpha(40),
                  //                       child: Icon(
                  //                         Icons.person,
                  //                         color: AppTheme.lightgreen,
                  //                         size: 32,
                  //                       ),
                  //                     ),
                  //                     const SizedBox(width: 16),
                  //                     Expanded(
                  //                       child: Column(
                  //                         crossAxisAlignment:
                  //                             CrossAxisAlignment.start,
                  //                         children: [
                  //                           Text(
                  //                             user.name ?? "Unknown",
                  //                             style: TextStyle(
                  //                               fontSize: 18,
                  //                               fontWeight: FontWeight.bold,
                  //                               color: AppTheme.textColor(
                  //                                 isDark,
                  //                               ),
                  //                             ),
                  //                           ),
                  //                           Text(
                  //                             user.role ?? "",
                  //                             style: TextStyle(
                  //                               fontSize: 14,
                  //                               color:
                  //                                   AppTheme.textSecondaryColor(
                  //                                     isDark,
                  //                                   ),
                  //                             ),
                  //                           ),
                  //                         ],
                  //                       ),
                  //                     ),
                  //                     CustomButton(
                  //                       text: "Open Chat",
                  //                       textStyle: TextStyle(
                  //                         color: isDarkMode
                  //                             ? Colors.white
                  //                             : Colors.black,
                  //                         fontSize: 12,
                  //                       ),
                  //                       onPressed: () {
                  //                         Navigator.push(
                  //                           context,
                  //                           MaterialPageRoute(
                  //                             builder: (_) => ChatScreen(
                  //                               chatId: chat.id!,
                  //                               otherUser: user,
                  //                             ),
                  //                           ),
                  //                         );
                  //                       },
                  //                       height: 44,
                  //                       width: 120,
                                      
                  //                       gradientColors: AppTheme.headerGradient(
                  //                         isDark,
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ),
                  //             );
                  //           },
                  //         );
                  //       },
                  //     );
                  //   },
                  // ),
              
        ),
  
    );
  }
}
