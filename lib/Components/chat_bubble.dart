import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Chatbubble extends StatefulWidget {
  final String message;
  final bool isCurrentUser;
  final DateTime? timestamp;
  final bool isSeen;

  const Chatbubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    this.timestamp,
    required this.isSeen,
  }) : super(key: key);

  @override
  State<Chatbubble> createState() => _ChatbubbleState();
}

class _ChatbubbleState extends State<Chatbubble> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: widget.isCurrentUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          width: MediaQuery.of(context).size.width - 150,
          padding: EdgeInsets.all(10),
          margin: widget.isCurrentUser
              ? EdgeInsets.only(right: 10, top: 10)
              : EdgeInsets.only(left: 10, top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: !widget.isCurrentUser
                  ? Radius.circular(0)
                  : Radius.circular(12),
              bottomRight: widget.isCurrentUser
                  ? Radius.circular(0)
                  : Radius.circular(12),
            ),
            color: widget.isCurrentUser ? Colors.grey.shade500 : Colors.green,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: widget.isCurrentUser
                    ? MediaQuery.of(context).size.width - 220
                    : MediaQuery.of(context).size.width - 200,
                child: Text(
                  widget.message,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Row(
                children: [
                  Text(
                    DateFormat.Hm().format(widget.timestamp ?? DateTime.now()),
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: widget.isCurrentUser ? 5 : 0),
                  widget.isCurrentUser
                      ? widget.isSeen
                          ? Icon(
                              Icons.done_all,
                              color: Colors.blue, // Centang biru jika dilihat
                              size: 18,
                            )
                          : Icon(
                              Icons.done,
                              color: Colors.white, // Centang abu-abu jika belum dilihat
                              size: 19,
                            )
                      : Container(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}