import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:chatapp/Components/chat_bubble.dart';
import 'package:chatapp/Components/textfield.dart';
import 'package:chatapp/service/auth/auth_service.dart';
import 'package:chatapp/service/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/message.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  ChatPage({
    Key? key,
    required this.receiverEmail,
    required this.receiverID,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FocusNode _myFocusNode = FocusNode();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatService _chatService;
  late final AuthService _authService;
  File? _imageFile;
  File? _pickedFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    _authService = AuthService();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    _markMessageAsSeen();
    Future.delayed(
      Duration(seconds: 1),
      () => _scrollToBottom(),
    );
  }

  @override
  void dispose() {
    _myFocusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _markMessageAsSeen() async {
    try {
      String senderID = _authService.getCurrentUser()!.uid;

      String? lastMessageId = await _chatService.getLastMessageId(
        widget.receiverID,
        senderID,
      );

      if (lastMessageId != null) {
        await _chatService.markMessageAsSeen(lastMessageId, senderID);
      } else {
        print('No last message found.');
      }
    } catch (e) {
      print('Error marking message as seen: $e');
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      Message newMessage = Message(
        senderID: _authService.getCurrentUser()!.uid,
        senderEmail: _authService.getCurrentUser()!.email!,
        receiverID: widget.receiverID,
        message: messageText,
        timestamp: DateTime.now(),
        isSeen: false,
      );
      await _chatService.sendMessage(widget.receiverID, newMessage.message);
      _messageController.clear();
      _scrollToBottom();
      _markMessageAsSeenAndNotifySender();
    }
  }

  void _markMessageAsSeenAndNotifySender() async {
    String? lastMessageId = await _getLastMessageId();
    if (lastMessageId != null) {
      String senderID = _authService.getCurrentUser()!.uid;
      await _chatService.markMessageAsSeen(lastMessageId, senderID);
      await _chatService.notifySenderMessageSeen(lastMessageId);
    }
  }

  Future<String?> _getLastMessageId() async {
    String senderID = _authService.getCurrentUser()!.uid;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('senderID', isEqualTo: senderID)
          .where('receiverID', isEqualTo: widget.receiverID)
          .orderBy('timestamp', descending: true) // Order by timestamp to get the latest message first
          .limit(1) // Limit to only the latest message
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String lastMessageId = querySnapshot.docs.first.id;
        return lastMessageId;
      } else {
        return null; // No message found
      }
    } catch (e) {
      print('Error getting last message ID: $e');
      return null;
    }
  }

  Future<File?> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      return File(pickedImage.path);
    }

    return null;
  }

  Future<void> _uploadImageToFirebase(User user) async {
    File? imageFile = await _pickImage(ImageSource.camera); // Ganti dengan sumber gambar yang diinginkan
    print('INI FOTONYA ${imageFile}');
    if (imageFile != null) {
      try {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}_${user.uid.split('/').last}.jpg';
        Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('/chat_images/$fileName');

        // Mulai unggah
        UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);

        // Tunggu hingga proses unggah selesai
        TaskSnapshot taskSnapshot = await uploadTask;

        // Ambil URL gambar yang diunggah
        String downloadURL = await taskSnapshot.ref.getDownloadURL();

        // URL gambar yang sudah diunggah tersedia di 'downloadURL'
        print('File uploaded successfully. Download URL: $downloadURL');
      } catch (e) {
        print('Error uploading image to Firebase Storage: $e');
      }
    }
  }

  // Future<void> _ensureAuthenticated() async {
  //   User? user = _auth.currentUser;
  //   if (user == null) {
  //     print('User is not authenticated. Please login.');
  //     return;
  //   }
  // }

  // Future<void> _pickImage(ImageSource source) async {
  //   await _ensureAuthenticated();
  //   final picker = ImagePicker();
  //   final pickedImage = await picker.pickImage(source: source);
  //
  //   if (pickedImage != null) {
  //     setState(() {
  //       _imageFile = File(pickedImage.path);
  //     });
  //
  //     // _authService.signInWithEmailPassword(email.text, pass.text).whenComplete(() async {
  //     //   await _uploadImageToFirebase(_imageFile!);
  //     // });
  //
  //     if (FirebaseAuth.instance.currentUser != null) {
  //       await _uploadImageToFirebase(_imageFile!);
  //     } else {
  //       print('User is not authenticated. Please login.');
  //     }
  //   }
  // }

  // Future<void> _uploadImageToFirebase(File imageFile) async {
  //   try {
  //     // Buat referensi ke Firebase Storage path yang diinginkan
  //     String fileName = path.basename(imageFile.path);
  //     Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('imageUrl/$fileName');
  //     // Mulai unggah
  //     UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
  //     // Monitor proses unggah
  //     TaskSnapshot taskSnapshot = await uploadTask;
  //     // Ambil URL gambar yang sudah diunggah
  //     String downloadURL = await taskSnapshot.ref.getDownloadURL();
  //     // URL gambar yang sudah diunggah tersedia di 'downloadURL'
  //     print('File uploaded successfully. Download URL: $downloadURL');
  //   } catch (e) {
  //     print('Error uploading image to Firebase Storage: $e');
  //   }
  // }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'], // Jenis file yang diizinkan
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        // Panggil fungsi unggah ke Firebase Storage
        await _uploadDocumentToFirebase(file);
      } else {
        print('User tidak memilih file.');
      }
    } catch (e) {
      print('Error memilih file: $e');
    }
  }

  Future<void> _uploadDocumentToFirebase(File file) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('documents/$fileName');

      // Mulai unggah
      UploadTask uploadTask = firebaseStorageRef.putFile(file);

      // Tunggu hingga proses unggah selesai
      TaskSnapshot taskSnapshot = await uploadTask;

      // Ambil URL dokumen yang diunggah
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      // URL dokumen yang sudah diunggah tersedia di 'downloadURL'
      print('File uploaded successfully. Download URL: $downloadURL');
    } catch (e) {
      print('Error uploading document to Firebase Storage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.receiverEmail, style: TextStyle(fontSize: 15),),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        List<Message> messages = snapshot.data!.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Message.fromMap(data);
        }).toList();

        messages = messages.reversed.toList();

        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        WidgetsBinding.instance!.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        });

        return ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            Message message = messages[index];
            bool isCurrentUser = message.senderID == senderID;
            return Column(
              crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Chatbubble(
                  message: message.message,
                  isCurrentUser: isCurrentUser,
                  timestamp: message.timestamp,
                  isSeen: message.isSeen ?? false,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildUserInput() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                showDialog(
                    barrierColor: Colors.transparent,
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        insetPadding: EdgeInsets.only(top: 417, right: 61),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: Icon(Icons.photo, color: Colors.redAccent.shade400,),
                            ),
                            IconButton(
                              onPressed: () async {
                                FirebaseAuth auth = FirebaseAuth.instance;
                                User? user = auth.currentUser;

                                if (user != null) {
                                  // Pengguna sudah login, panggil fungsi upload
                                  _uploadImageToFirebase(user);
                                } else {
                                  // Jika pengguna belum login, tampilkan pesan atau arahkan untuk login
                                  print('User is not authenticated. Please login.');
                                }
                              },
                              icon: Icon(Icons.camera_alt, color: Colors.blue.shade400,),
                            ),
                            IconButton(
                              onPressed: () => _pickDocument(),
                              icon: Icon(Icons.description, color: Colors.greenAccent.shade400,),
                            ),
                          ],
                        ),
                      );
                    });
              },
              icon: Icon(Icons.add)),
          Expanded(
            child: TextFieldCustom(
              focusNode: _myFocusNode,
              controller: _messageController,
              hintText: 'Type a message',
              obscureText: false,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
