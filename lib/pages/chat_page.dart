import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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

import '../controller/controller.dart';
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

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    _authService = AuthService();

    signInWithEmailAndPassword(widget.receiverEmail, '123456');

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // _markMessageAsSeen();
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

  // void _markMessageAsSeen() async {
  //   try {
  //     String senderID = _authService.getCurrentUser()!.uid;
  //
  //     String? lastMessageId = await _chatService.getLastMessageId(
  //       widget.receiverID,
  //       senderID,
  //     );
  //
  //     if (lastMessageId != null) {
  //       await _chatService.markMessageAsSeen(lastMessageId, senderID);
  //     } else {
  //       print('No last message found.');
  //     }
  //   } catch (e) {
  //     print('Error marking message as seen: $e');
  //   }
  // }

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
      // _markMessageAsSeenAndNotifySender();
    }
  }

  // void _markMessageAsSeenAndNotifySender() async {
  //   String? lastMessageId = await _getLastMessageId();
  //   if (lastMessageId != null) {
  //     String senderID = _authService.getCurrentUser()!.uid;
  //     await _chatService.markMessageAsSeen(lastMessageId, senderID);
  //     await _chatService.notifySenderMessageSeen(lastMessageId);
  //   }
  // }

  // Future<String?> _getLastMessageId() async {
  //   String senderID = _authService.getCurrentUser()!.uid;
  //
  //   try {
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection('messages')
  //         .where('senderID', isEqualTo: senderID)
  //         .where('receiverID', isEqualTo: widget.receiverID)
  //         .orderBy('timestamp', descending: true) // Order by timestamp to get the latest message first
  //         .limit(1) // Limit to only the latest message
  //         .get();
  //
  //     if (querySnapshot.docs.isNotEmpty) {
  //       String lastMessageId = querySnapshot.docs.first.id;
  //       return lastMessageId;
  //     } else {
  //       return null; // No message found
  //     }
  //   } catch (e) {
  //     print('Error getting last message ID: $e');
  //     return null;
  //   }
  // }

  Future<void> signInAnonymously() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
      // Handle login success, userCredential.user contains the authenticated user
      print('Otentikasi berhasil! Pengguna ID: ${userCredential.user!.uid}');
    } catch (e) {
      print('Error signing in anonymously: $e');
      // Handle login failure
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Handle login success, userCredential.user contains the authenticated user
      print('Authentication successful! User ID: ${userCredential.user!.uid}');
    } catch (e) {
      print('Error signing in with email and password: $e');
      // Handle login failure
    }
  }

  Future _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });

      try {
        // Upload gambar yang dipilih ke Firebase Storage
        await uploadImage(_imageFile!);
      } catch (e) {
        print('Error uploading image: $e');
        // Handle error jika terjadi kegagalan upload
      }

    } else {
      print("Tidak ada gambar yang dipilih.");
    }
  }

  Future<void> uploadImage(File imageFile) async {
    try {
      // Ambil referensi dari Firebase Storage
      FirebaseStorage storage = FirebaseStorage.instance;

      // Ambil referensi folder untuk menyimpan gambar, misalnya 'images'
      Reference storageRef = storage.ref().child('images/${DateTime.now().millisecondsSinceEpoch}');

      // Upload gambar ke Firebase Storage
      UploadTask uploadTask = storageRef.putFile(imageFile);

      // Tunggu hingga proses upload selesai
      TaskSnapshot taskSnapshot = await uploadTask;

      // Ambil URL dari gambar yang telah diupload
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Lakukan sesuatu dengan URL gambar, seperti menyimpan ke database atau menampilkan di aplikasi
      print('Image uploaded successfully: $imageUrl');
    } catch (e) {
      print('Error uploading image: $e');
      // Handle error jika terjadi kegagalan upload
    }
  }

  // Future<void> _uploadImageToStorage() async {
  //   if (_imageFile == null) return;
  //
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if (user == null) {
  //     print("User is not signed in");
  //     return;
  //   }
  //
  //   String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  //   Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('chat_images/$fileName');
  //
  //   try {
  //     await firebaseStorageRef.putFile(_imageFile!);
  //     String downloadURL = await firebaseStorageRef.getDownloadURL();
  //     print("URL gambar: $downloadURL");
  //     _saveImageUrlToFirestore(downloadURL);
  //   } catch (e) {
  //     print("Gagal mengunggah gambar: $e");
  //   }
  // }
  //
  // Future<void> _saveImageUrlToFirestore(String imageUrl) async {
  //   CollectionReference imagesCollection = FirebaseFirestore.instance.collection('images');
  //
  //   try {
  //     await imagesCollection.add({'url': imageUrl});
  //     print("URL gambar berhasil disimpan di Firestore.");
  //   } catch (e) {
  //     print("Gagal menyimpan URL gambar ke Firestore: $e");
  //   }
  // }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        print('File dipilih: ${file.path}');
      } else {
        print('User tidak memilih file.');
      }
    } catch (e) {
      print('Error memilih file: $e');
    }
  }

  // late ChatProvider chatProvider;
  // File? imageFile;
  // bool isLoading = false;
  // String imageUrl = "";
  // String groupChatId = "";
  // String currentUserId = "";
  // Future _pickImage() async {
  //   ImagePicker imagePicker = ImagePicker();
  //   final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
  //   if (pickedFile != null) {
  //     imageFile = File(pickedFile.path);
  //     if (imageFile != null) {
  //       setState(() {
  //         isLoading = true;
  //       });
  //       uploadFile();
  //     }
  //   }
  // }
  //
  // Future uploadFile() async {
  //   UploadTask uploadTask = chatProvider.uploadFile(imageFile!,
  //       "image/${DateTime.now().millisecondsSinceEpoch.toString()}");
  //   try {
  //     TaskSnapshot snapshot = await uploadTask;
  //     imageUrl = await snapshot.ref.getDownloadURL();
  //     setState(() {
  //       isLoading = false;
  //       onSendMessage(imageUrl, TypeMessage.image);
  //     });
  //   } on FirebaseException catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     Fluttertoast.showToast(msg: e.message ?? e.toString());
  //     print('WWKWKWKWKWKWKWKK ${e.message ?? e.toString()}');
  //   }
  // }
  //
  // void onSendMessage(String content, int type, {String? duration = ""}) {
  //   if (content.trim().isNotEmpty) {
  //     _messageController.clear();
  //     chatProvider.sendMessage(
  //         content, type, groupChatId, currentUserId,
  //         // widget.data.id.toString(),
  //         duration: duration!);
  //     _scrollController.animateTo(0,
  //         duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  //   } else {
  //     Fluttertoast.showToast(
  //         msg: 'Nothing to send', backgroundColor: Colors.grey);
  //   }
  // }

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

        WidgetsBinding.instance.addPostFrameCallback((_) {
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
                              onPressed: () {
                                signInWithEmailAndPassword(
                                        widget.receiverEmail, '123456')
                                    .whenComplete(() {
                                  _pickImage(ImageSource.camera)
                                      .whenComplete(() {
                                    Navigator.pop(context);
                                  });
                                });
                              },
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.blue.shade400,
                              ),
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
