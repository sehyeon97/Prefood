import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:prefoods/screens/tabs/friends_screen.dart';
import 'package:prefoods/screens/tabs/groups_screen.dart';

import 'package:prefoods/styles/text.dart';
import 'package:prefoods/styles/theme_colors.dart';

const String _screenTitle = 'My Groups';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedIndex = 0;

  final tabs = const [
    GroupsScreen(),
    FriendsScreen(),
  ];

  void _onBarItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: availableColors['blue'],
        title: const Text(
          _screenTitle,
          style: titleStyle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app,
              color: availableColors['black'],
            ),
          ),
        ],
      ),
      backgroundColor: availableColors['pink'],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.groups),
            label: 'Groups',
            backgroundColor: availableColors['blue'],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.group),
            label: 'Friends',
            backgroundColor: availableColors['orange'],
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: availableColors['black'],
        onTap: (value) {
          _onBarItemTap(value);
        },
      ),
      body: tabs[_selectedIndex],
    );
  }
}
