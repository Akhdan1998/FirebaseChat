import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final DateTime timestamp;
  bool isSeen;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    this.isSeen = false, // Default value for isSeen
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'isSeen': isSeen,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderID'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      receiverID: map['receiverID'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isSeen: map['isSeen'] ?? false,
    );
  }
}