import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  final String title;
  final String content;
  final bool showButton;
  final Function() notifyParent;

  const Message({super.key,
    required this.title,
    required this.content,
    required this.showButton,
    required this.notifyParent
  });

  @override
  Widget build(BuildContext context) {
    if (showButton) {
      return AlertDialog(
        title: Text(
          title,

        ),
        content: Text(
          content,

        ),
        actions: [
          TextButton(onPressed: () {
            notifyParent();
          }, child: const Text("Ok"))
        ],
      );
    } else {
      return AlertDialog(
        title: Text(
          title,

        ),
        content: Text(
          content,
        ),
      );
    }
  }
}