import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prefoods/providers/current_group_id_provider.dart';
import 'package:prefoods/widgets/group/chat/message_bubble.dart';

class ChatMessages extends ConsumerWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupID = ref.watch(groupIDProvider);
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .doc(groupID)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Center(
            child: Text('No messages found.'),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }

        final List loadedMessages = snapshot.data!.data()!['history'];
        final List orderedLoadedMessages = loadedMessages.reversed.toList();

        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 13,
            right: 13,
          ),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (contxt, index) {
            final chatMessage = orderedLoadedMessages[index]['text'];
            final nextChatMessage = index + 1 < loadedMessages.length
                ? orderedLoadedMessages[index + 1]['text']
                : null;

            final currentMessageUserId = orderedLoadedMessages[index]['userID'];
            final nextMessageUserId = nextChatMessage != null
                ? orderedLoadedMessages[index]['userID']
                : null;

            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage,
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                username: orderedLoadedMessages[index]['username'],
                message: chatMessage,
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
