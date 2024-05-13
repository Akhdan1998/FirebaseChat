// import 'package:chatapp/service/chat_service.dart';
// import 'package:flutter/material.dart';
//
// import '../Components/user.tile.dart';
// import '../service/auth/auth_service.dart';
// import 'chat_page.dart';
//
// class HomePage extends StatefulWidget {
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   final ChatService _chatService = ChatService();
//   final AuthService _authService = AuthService();
//
//   void logout() {
//     _authService.logout();
//   }
//   // void logout() {
//   //   final _auth = AuthService();
//   //   _auth.logout();
//   // }
//
//  // Atur status chat (dibuka/belum dibuka)
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         title: Text('Contact'),
//         actions: [
//           IconButton(
//             onPressed: logout,
//             icon: Icon(Icons.logout),
//           ),
//         ],
//       ),
//       body: _builduserList(),
//     );
//   }
//
//   Widget _builduserList() {
//     return StreamBuilder(
//         stream: _chatService.getUsersStream(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(
//               child: Text('Error'),
//             );
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//           return ListView(
//             children: snapshot.data!
//                 .map<Widget>(
//                   (userData) => _buildUserListItem(userData, context),
//                 )
//                 .toList(),
//           );
//         });
//   }
//
//   Widget _buildUserListItem(
//       Map<String, dynamic> userData, BuildContext context) {
//     if (userData['email'] != _authService.getCurrentUser()!.email) {
//       return UserTile(
//         text: userData['email'],
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ChatPage(
//                 receiverEmail: userData['email'],
//                 receiverID: userData['uid'],
//               ),
//             ),
//           );
//         },
//       );
//     } else {
//       return Container();
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:chatapp/service/chat_service.dart';
import '../Components/user.tile.dart';
import '../service/auth/auth_service.dart';
import 'chat_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  void _logout(BuildContext context) {
    _authService.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final users = snapshot.data ?? [];
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index];
              if (userData['email'] != _authService.getCurrentUser()!.email && userData['email'] != _authService.getCurrentUser()!.email) {
                return UserTile(
                  text: userData['email'],
                  onTap: () => _openChatPage(context, userData),
                );
              } else {
                return Container(); // Skip current user's own tile
              }
            },
          );
        },
      ),
    );
  }

  void _openChatPage(BuildContext context,
      Map<String, dynamic> userData) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatPage(
              receiverEmail: userData['email'],
              receiverID: userData['uid'],
            ),
      ),
    );
    await _markMessagesAsSeen(userData['uid']);
  }

  Future<void> _markMessagesAsSeen(String senderId) async {
    try {
      String receiverId = _authService.getCurrentUser()!.uid;
      // Get all messages from senderId to receiverId
      List<String> messageIds = await _chatService.getAllMessageIds(
          senderId, receiverId);

      // Mark each message as seen
      for (String messageId in messageIds) {
        await _chatService.markMessageAsSeen(messageId, senderId);
      }
    } catch (e) {
      print('Error marking messages as seen: $e');
    }
  }
}