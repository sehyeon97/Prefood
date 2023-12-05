import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prefoods/data/screen_size.dart';
import 'package:prefoods/models/group.dart';
import 'package:prefoods/providers/current_group_id_provider.dart';

import 'package:prefoods/screens/group/group_screen.dart';
import 'package:prefoods/styles/text.dart';
import 'package:prefoods/styles/theme_colors.dart';

class ScrollableList extends ConsumerStatefulWidget {
  const ScrollableList({
    super.key,
  });

  @override
  ConsumerState<ScrollableList> createState() => _ScrollableListState();
}

class _ScrollableListState extends ConsumerState<ScrollableList> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    void onSelectGroup(int index, final groupID) async {
      final groupData = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupID)
          .get();
      ref.read(groupIDProvider.notifier).setGroupID(groupID);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext contxt) => GroupScreen(
            group: Group(
              id: groupID,
              name: groupData['name'],
              inviteLink: groupData['link'],
              events: [],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: Device.screenSize.width * 0.8,
      height: Device.screenSize.height * 0.3,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, groupsSnapshot) {
          if (groupsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final userData = groupsSnapshot.data!.data();

          if (userData!['groups'] != null) {
            return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: userData['groups'].length,
                itemBuilder: (BuildContext context, int index) {
                  return ElevatedButton(
                    onPressed: () {
                      onSelectGroup(
                          index, userData['groups'].keys.toList()[index]);
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      elevation: 2.5,
                      fixedSize: const Size(250, 80),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 2,
                          color: availableColors['black']!,
                        ),
                      ),
                      backgroundColor: availableColors['blue'],
                    ),
                    child: Text(
                      userData['groups'].values.toList()[index],
                      style: TextStyle(
                        color: availableColors['black'],
                      ),
                    ),
                  );
                });
          } else {
            return const Text(
              'You are not in any group',
              style: textStyle,
              textAlign: TextAlign.center,
            );
          }
        },
      ),
    );
  }
}
