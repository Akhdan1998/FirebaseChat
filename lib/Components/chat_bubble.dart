import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Chatbubble extends StatefulWidget {
  final String message;
  final bool isCurrentUser;

  const Chatbubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  State<Chatbubble> createState() => _ChatbubbleState();
}

class _ChatbubbleState extends State<Chatbubble> {
  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: widget.isCurrentUser
              ? EdgeInsets.only(right: 20, top: 10, bottom: 5)
              : EdgeInsets.only(left: 20, top: 10, bottom: 5),
          width: MediaQuery.of(context).size.width - 150,
          alignment: widget.isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            '${(now.hour)}:${(now.minute)}',
            style: TextStyle(fontSize: 10),
          ),
        ),
        Container(
          alignment: widget.isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          width: MediaQuery.of(context).size.width - 150,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: widget.isCurrentUser ? Colors.green : Colors.grey.shade500,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.message,
                style: TextStyle(color: Colors.white),
              ),
              widget.isCurrentUser ? Icon(Icons.check, color: Colors.white, size: 18,) : Container(),
            ],
          ),
        ),
      ],
    );
  }
}
