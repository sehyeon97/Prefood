import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prefoods/providers/current_group_id_provider.dart';
import 'package:prefoods/styles/theme_colors.dart';

class NewMessage extends ConsumerStatefulWidget {
  const NewMessage({super.key});

  @override
  ConsumerState<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends ConsumerState<NewMessage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onSubmitMessage() async {
    final String enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final username = userData.data()!['username'];
    final groupID = ref.watch(groupIDProvider);

    final currentChatData =
        await FirebaseFirestore.instance.collection('chat').doc(groupID).get();
    final storedChatData = currentChatData.data();

    if (storedChatData == null || storedChatData.isEmpty) {
      await FirebaseFirestore.instance.collection('chat').doc(groupID).set(
        {
          'history': [
            {
              'userID': user.uid,
              'username': username,
              'text': enteredMessage,
              'createdAt': Timestamp.now(),
            }
          ],
        },
      );
    } else {
      List storedChatHistory = storedChatData['history'];

      if (storedChatHistory.length > 50) {
        storedChatHistory.removeAt(0);
      }

      Map<String, dynamic> userMessageData = {
        'userID': user.uid,
        'username': username,
        'text': enteredMessage,
        'createdAt': Timestamp.now(),
      };

      storedChatHistory.add(userMessageData);

      await FirebaseFirestore.instance.collection('chat').doc(groupID).set({
        'history': storedChatHistory,
      }, SetOptions(merge: true));
    }

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 1,
        bottom: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(
                labelText: 'Send a message...',
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _onSubmitMessage();
            },
            icon: const Icon(
              Icons.send,
            ),
            color: availableColors['blue'],
          ),
        ],
      ),
    );
  }
}
