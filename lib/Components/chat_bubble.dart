import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
        // Container(
        //   margin: widget.isCurrentUser
        //       ? EdgeInsets.only(right: 20, top: 10, bottom: 5)
        //       : EdgeInsets.only(left: 20, top: 10, bottom: 5),
        //   width: MediaQuery.of(context).size.width - 150,
        //   alignment: widget.isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        //   child: Text(
        //     '${(now.hour)}:${(now.minute)}',
        //     style: TextStyle(fontSize: 10),
        //   ),
        // ),
        GestureDetector(
          onDoubleTap: () {
            FlutterClipboard.copy(widget.message).then(( value ) =>
                Fluttertoast.showToast(
                    msg: "Salin!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0
                ),
            );
          },
          child: Container(
            alignment: widget.isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
            width: MediaQuery.of(context).size.width - 150,
            padding: EdgeInsets.all(10),
            margin: widget.isCurrentUser
                ? EdgeInsets.only(right: 10, top: 10, bottom: 5, left: 10,)
                : EdgeInsets.only(left: 10, top: 10, bottom: 5, right: 10,),
            decoration: BoxDecoration(
              borderRadius: widget.isCurrentUser
                  ? BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    )
                  : BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
              color: widget.isCurrentUser ? Colors.green : Colors.grey.shade500,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: widget.isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Container(
                  alignment: widget.isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                  width: widget.isCurrentUser
                      ? MediaQuery.of(context).size.width - 198
                      : MediaQuery.of(context).size.width - 180,
                  child: Text(
                    widget.message,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                widget.isCurrentUser ? Icon(Icons.check, color: Colors.white, size: 18,) : Container(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
