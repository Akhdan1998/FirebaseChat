import 'package:chatapp/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> getLastMessageId(String receiverID, String senderID) async {
    try {
      List<String> userIds = [receiverID, senderID]..sort();
      String chatRoomID = '${userIds[0]}_${userIds[1]}';

      QuerySnapshot querySnapshot = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomID)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.id : null;
    } catch (e) {
      print('Error getting last message ID: $e');
      return null;
    }
  }

  Future<void> markMessageAsSeen(String messageId, String senderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      print('Error marking message as seen: $e');
      throw e; // Meneruskan error untuk penanganan lebih lanjut
    }
  }

  Future<void> notifySenderMessageSeen(String messageId) async {
    try {
      // Lakukan hal yang diperlukan untuk memberitahu pengirim
      print('Sender notified that message $messageId has been seen');
    } catch (e) {
      print('Error notifying sender about seen message: $e');
      throw e; // Meneruskan error untuk penanganan lebih lanjut
    }
  }

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