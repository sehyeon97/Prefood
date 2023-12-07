import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:prefoods/styles/text.dart';
import 'package:prefoods/styles/theme_colors.dart';
import 'package:uuid/uuid.dart';

// Refer to groups_screen.dart
class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final groupNameController = TextEditingController();
    Uuid uuid = const Uuid();

    void onNewGroup() async {
      final user = FirebaseAuth.instance.currentUser!;
      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDocument.data()!;

      // Create Group
      if (label == 'Create Group') {
        final groupName = groupNameController.text;
        String groupID = uuid.v4();
        String inviteLink = uuid.v4();
        final userGroups = userData['groups'] ?? {};

        if (userData.containsKey('groups')) {
          userGroups.addAll({
            ...{groupID: groupName}
          });

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'groups': userGroups}, SetOptions(merge: true));
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(
            {
              'groups': {groupID: groupName},
            },
            SetOptions(merge: true),
          );
        }

        await FirebaseFirestore.instance.collection('groups').doc(groupID).set({
          'name': groupName,
          'members': [
            {'userID': user.uid}
          ],
          'link': inviteLink,
          'events': [],
        });
      } else {
        // Join Group
        String inviteLink = groupNameController.text;

        // (1) add group to user's groups list
        // (a) user has no groups
        // (b) user has existing groups
        final userGroups = userData['groups'] ?? {};

        final groupData = await FirebaseFirestore.instance
            .collection('groups')
            .doc(inviteLink)
            .get();
        final groupDetails = groupData.data()!;

        if (!userData.containsKey('groups')) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(
            {
              'groups': {inviteLink: groupDetails['name']},
            },
            SetOptions(merge: true),
          );
        } else {
          userGroups.addAll({
            ...{inviteLink: groupDetails['name']}
          });
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'groups': userGroups}, SetOptions(merge: true));
        }

        // (2) add user to group's members list
        final groupMembers = groupData['members'].add({'userID': user.uid});
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(inviteLink)
            .set(
          {'members': groupMembers},
          SetOptions(merge: true),
        );
      }
    }

    void onButtonPress() {
      showDialog(
        context: context,
        builder: (contxt) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: textStyle,
                  ),
                  TextField(
                    controller: groupNameController,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onNewGroup();
                      Navigator.of(contxt).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: availableColors['blue'],
                    ),
                    child: label == 'Create Group'
                        ? const Text('Create')
                        : const Text('Join'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return ElevatedButton(
      onPressed: () {
        onButtonPress();
      },
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        backgroundColor: availableColors['blue'],
        elevation: 2.5,
        fixedSize: const Size(250, 80),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 2,
            color: availableColors['black']!,
          ),
        ),
      ),
      child: Text(
        label,
        style: textStyle,
      ),
    );
  }
}
