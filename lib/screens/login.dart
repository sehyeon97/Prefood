import 'package:flutter/material.dart';

import 'package:prefoods/screens/tabs.dart';
import 'package:prefoods/styles/text.dart';
import 'package:prefoods/styles/theme_colors.dart';
import 'package:prefoods/widgets/login/auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String welcomeMessage = 'Welcome!';

    void navigateToTabsScreen() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext contxt) {
          return const TabsScreen();
        }),
      );
    }

    return Scaffold(
      backgroundColor: availableColors['pink'],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              welcomeMessage,
              style: titleStyleWhite,
            ),
            const SizedBox(height: 80),
            Auth(submitForm: navigateToTabsScreen),
          ],
        ),
      ),
    );
  }
}
