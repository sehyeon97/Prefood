import 'package:flutter/material.dart';
import 'package:prefoods/widgets/group/chat/chat_messages.dart';
import 'package:prefoods/widgets/group/chat/new_message.dart';

class ChatBox extends StatelessWidget {
  const ChatBox({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Column(
        children: [
          Expanded(child: ChatMessages()),
          NewMessage(),
        ],
      ),
    );
  }
}
