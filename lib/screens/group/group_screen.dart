import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prefoods/models/group.dart';
import 'package:prefoods/screens/tabs.dart';
import 'package:prefoods/styles/text.dart';
import 'package:prefoods/styles/theme_colors.dart';
import 'package:prefoods/widgets/group/calendar.dart';
import 'package:prefoods/widgets/group/chat/chat.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({
    super.key,
    required this.group,
  });

  final Group group;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          group.name,
          style: titleStyle,
        ),
        centerTitle: true,
        backgroundColor: availableColors['blue'],
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (contxt) => const TabsScreen()),
              );
            },
            icon: const Icon(Icons.home),
          ),
          IconButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: group.id));
            },
            icon: const Icon(Icons.copy),
          ),
        ],
      ),
      body: Column(
        children: [
          Calendar(group: group),
          const SizedBox(height: 40),
          const ChatBox(),
        ],
      ),
    );
  }
}
