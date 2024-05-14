import 'dart:io';

import 'package:chatapp/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Future<void> markMessageAsSeen(String messageId, String senderId) async {
  //   try {
  //     DocumentSnapshot messageSnapshot = await FirebaseFirestore.instance
  //         .collection('chat_rooms')
  //         .doc(messageId)
  //         .get();
  //
  //     if (messageSnapshot.exists) {
  //       await FirebaseFirestore.instance
  //           .collection('chat_rooms')
  //           .doc(messageId)
  //           .update({'isSeen': true});
  //     } else {
  //       print('Error: Document with ID $messageId not found');
  //     }
  //   } catch (e) {
  //     print('Error marking message as seen: $e');
  //     throw e; // Propagate the error for further handling
  //   }
  // }
  //
  // Future<List<String>> getAllMessageIds(String senderId, String receiverId) async {
  //   List<String> messageIds = [];
  //
  //   try {
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection('chat_rooms')
  //         .where('senderID', isEqualTo: senderId)
  //         .where('receiverID', isEqualTo: receiverId)
  //         .get();
  //
  //     messageIds = querySnapshot.docs.map((doc) => doc.id).toList();
  //   } catch (e) {
  //     print('Error getting message IDs: $e');
  //   }
  //
  //   return messageIds;
  // }

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> sendMessage(String receiverID, String message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    bool seen = true;

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: DateTime.now(),
      isSeen: seen,
    );

    List<String> ids = [currentUserID, receiverID]..sort();
    String chatRoomID = ids.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String receiverID, String senderID) {
    String chatRoomID = getChatRoomID(receiverID, senderID);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  String getChatRoomID(String receiverID, String senderID) {
    List<String> userIds = [receiverID, senderID]..sort();
    return '${userIds[0]}_${userIds[1]}';
  }

  static Future<String> uploadImage(File imageFile) async {
    String fileName = basename(imageFile.path);

      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask task = ref.putFile(imageFile);
      TaskSnapshot snapshot = await task.whenComplete(() {});

      return await snapshot.ref.getDownloadURL();
  }

  // Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
  //   List<String> ids = [userID, otherUserID];
  //   ids.sort();
  //   String chatRoomID = ids.join('_');
  //   return _firestore
  //       .collection('chat_rooms')
  //       .doc(chatRoomID)
  //       .collection('messages')
  //       .orderBy('timestamp', descending: false)
  //       .snapshots();
  // }

  // String getChatRoomID(String receiverID, String senderID) {
  //   // Sort the user IDs to create a consistent chat room ID format
  //   List<String> userIds = [receiverID, senderID];
  //   userIds.sort(); // Sort user IDs alphabetically
  //
  //   // Concatenate the sorted user IDs to create the chat room ID
  //   String chatRoomID = '${userIds[0]}_${userIds[1]}';
  //
  //   return chatRoomID;
  // }

  // Stream<QuerySnapshot<Object?>> getMessages(String receiverID, String senderID) {
  //   String chatRoomID = getChatRoomID(receiverID, senderID);
  //
  //   return FirebaseFirestore.instance
  //       .collection('chat_rooms')
  //       .doc(chatRoomID)
  //       .collection('messages')
  //       .orderBy('timestamp', descending: true)
  //       .snapshots();
  // }
}