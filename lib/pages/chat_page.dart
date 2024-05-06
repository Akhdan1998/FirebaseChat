import 'package:chatapp/Components/chat_bubble.dart';
import 'package:chatapp/Components/textfield.dart';
import 'package:chatapp/service/auth/auth_service.dart';
import 'package:chatapp/service/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });
    Future.delayed(
      Duration(seconds: 1),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    myFocusNode.dispose();
  }

  final TextEditingController _message = TextEditingController();

  //scroll controller
  final ScrollController _scrollController = ScrollController();

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.easeIn,
    );
  }

  //chat & auth service
  final ChatService _chatService = ChatService();

  final AuthService _authService = AuthService();

  //send message
  void sendMessage() async {
    if (_message.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverID, _message.text);
      _message.clear();
    }
    scrollDown();
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
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    //is current user
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Chatbubble(
            message: data['message'],
            isCurrentUser: isCurrentUser,
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    return Container(
      padding: EdgeInsets.only(bottom: 10, right: 18, top: 10),
      child: Row(
        children: [
          Expanded(
            child: TextFieldCustom(
              focusNode: myFocusNode,
              controller: _message,
              hintText: 'Type a message',
              obscureText: false,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: Icon(
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
