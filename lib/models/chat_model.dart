import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  String? id;
  List<String>? members; // [patientId, doctorId]
  bool? isAccept;
  DateTime? createdAt;

  ChatModel({this.id, this.members, this.isAccept, this.createdAt});

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      members: List<String>.from(data['members']),
      isAccept: data['isAccept'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {"members": members, "isAccept": isAccept, "createdAt": createdAt};
  }
}


class MessageModel {
  String? id;
  String? text;
  String? sendBy;
  DateTime? timestamp;

  MessageModel({this.id, this.text, this.sendBy, this.timestamp});

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      text: data['text'],
      sendBy: data['sendBy'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "text": text,
      "sendBy": sendBy,
      "timestamp": timestamp,
    };
  }
}