import 'package:flutter/material.dart';

import 'package:prefoods/widgets/groups/user_groups.dart';
import 'package:prefoods/widgets/scrollable_list.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 80),
            ScrollableList(),
            SizedBox(height: 40),
            MyButton(label: 'Create Group'),
            SizedBox(height: 40),
            MyButton(label: 'Join Group'),
          ],
        ),
      ),
    );
  }
}
