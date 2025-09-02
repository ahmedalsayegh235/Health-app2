import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health/models/user_model.dart';

class ChatLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of all doctors
  Stream<QuerySnapshot> getDoctorsStream() {
    return _firestore
        .collection("users")
        .where("role", isEqualTo: "doctor")
        .snapshots();
  }

  /// Stream of chats for a specific user
  Stream<QuerySnapshot> getChatStream(String userId) {
    return _firestore
        .collection("chats")
        .where("members", arrayContains: userId)
        .snapshots();
  }

  /// Filter chats for a specific doctor
  List<QueryDocumentSnapshot> filterChatsForDoctor(
    List<QueryDocumentSnapshot> allChats,
    String doctorId,
  ) {
    return allChats.where((doc) {
      List members = doc["members"];
      return members.contains(doctorId);
    }).toList();
  }

  /// Send a chat request to a doctor
  Future<void> sendChatRequest(
    BuildContext context,
    String doctorId,
    String doctorName,
  ) async {
    try {
      final patientId = UserModel.userData.id;

      if (patientId == null) {
        _showErrorMessage(context, "User not logged in");
        return;
      }

      // Create new chat request
      await _firestore.collection("chats").add({
        "members": [patientId, doctorId],
        "isAccept": false,
        "createdAt": FieldValue.serverTimestamp(),
      });

      _showSuccessMessage(context, "Request sent to Dr. $doctorName");
    } catch (e) {
      _showErrorMessage(context, "Failed to send request: ${e.toString()}");
    }
  }

  /// Get accepted chats for current user
  Stream<QuerySnapshot> getAcceptedChatsStream(String userId) {
    return _firestore
        .collection("chats")
        .where("members", arrayContains: userId)
        .where("isAccept", isEqualTo: true)
        .snapshots();
  }

  /// Get pending requests for doctor
  Stream<QuerySnapshot> getPendingRequestsStream(String doctorId) {
    return _firestore
        .collection("chats")
        .where("members", arrayContains: doctorId)
        .where("isAccept", isEqualTo: false)
        .snapshots();
  }

  /// Accept a chat request (for doctors)
  Future<void> acceptChatRequest(
    BuildContext context,
    String chatId,
    String patientName,
  ) async {
    try {
      await _firestore
          .collection("chats")
          .doc(chatId)
          .update({"isAccept": true});

      _showSuccessMessage(context, "Chat request from $patientName accepted");
    } catch (e) {
      _showErrorMessage(context, "Failed to accept request: ${e.toString()}");
    }
  }

  /// Get other user ID from chat members
  String getOtherUserId(List<String> members, String currentUserId) {
    return members.firstWhere((id) => id != currentUserId);
  }

  /// Check if chat exists between two users
  Future<QuerySnapshot> checkExistingChat(String userId1, String userId2) {
    return _firestore
        .collection("chats")
        .where("members", arrayContains: userId1)
        .get()
        .then((snapshot) {
      return FirebaseFirestore.instance
          .collection("chats")
          .where("members", arrayContains: userId2)
          .get();
    });
  }

  /// Get chat statistics for a user
  Future<Map<String, int>> getChatStatistics(String userId) async {
    try {
      final allChatsSnapshot = await _firestore
          .collection("chats")
          .where("members", arrayContains: userId)
          .get();

      int totalChats = allChatsSnapshot.docs.length;
      int acceptedChats = allChatsSnapshot.docs
          .where((doc) => doc["isAccept"] == true)
          .length;
      int pendingChats = totalChats - acceptedChats;

      return {
        'total': totalChats,
        'accepted': acceptedChats,
        'pending': pendingChats,
      };
    } catch (e) {
      return {
        'total': 0,
        'accepted': 0,
        'pending': 0,
      };
    }
  }

  /// Delete a chat
  Future<void> deleteChat(BuildContext context, String chatId) async {
    try {
      // Delete all messages in the chat first
      final messagesSnapshot = await _firestore
          .collection("chats")
          .doc(chatId)
          .collection("messages")
          .get();

      for (var message in messagesSnapshot.docs) {
        await message.reference.delete();
      }

      // Delete the chat document
      await _firestore.collection("chats").doc(chatId).delete();

      _showSuccessMessage(context, "Chat deleted successfully");
    } catch (e) {
      _showErrorMessage(context, "Failed to delete chat: ${e.toString()}");
    }
  }

  /// Get unread message count for a chat
  Future<int> getUnreadMessageCount(String chatId, String userId) async {
    try {
      final messagesSnapshot = await _firestore
          .collection("chats")
          .doc(chatId)
          .collection("messages")
          .where("sendBy", isNotEqualTo: userId)
          .where("isRead", isEqualTo: false)
          .get();

      return messagesSnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final unreadMessages = await _firestore
          .collection("chats")
          .doc(chatId)
          .collection("messages")
          .where("sendBy", isNotEqualTo: userId)
          .where("isRead", isEqualTo: false)
          .get();

      for (var message in unreadMessages.docs) {
        await message.reference.update({"isRead": true});
      }
    } catch (e) {
      // Silently handle error for read status
    }
  }

  /// Private helper methods
  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}