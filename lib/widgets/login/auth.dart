import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prefoods/data/screen_size.dart';
import 'package:prefoods/styles/text.dart';
import 'package:prefoods/styles/theme_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class Auth extends StatefulWidget {
  const Auth({
    super.key,
    required this.submitForm,
  });

  final void Function() submitForm;

  @override
  State<StatefulWidget> createState() {
    return _AuthState();
  }
}

class _AuthState extends State<Auth> {
  final _formKey = GlobalKey<FormState>();
  String _enteredEmail = '';
  String _enteredPassword = '';
  String _enteredUsername = '';

  int _selectedTabIndex = 0;
  String _formLabel = 'Signup';

  void _onTabClick(int index) {
    setState(() {
      if (index == 0) {
        _formLabel = 'Signup';
      } else {
        _formLabel = 'Login';
      }
      _selectedTabIndex = index;
    });
  }

  void _onSubmitForm() async {
    final bool isFormValid = _formKey.currentState!.validate();
    if (isFormValid) {
      _formKey.currentState!.save();

      try {
        if (_selectedTabIndex == 0) {
          final UserCredential userCredential =
              await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail,
            password: _enteredPassword,
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'username': _enteredUsername,
            'email': _enteredEmail,
          });

          setState(() {
            _selectedTabIndex = 1;
            _formLabel = 'Login';
          });
        } else {
          // log users in
          await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail,
            password: _enteredPassword,
          );

          widget.submitForm();
        }
      } on FirebaseAuthException catch (error) {
        _showSubmissionError(error);
      }
    }
  }

  void _showSubmissionError(error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.message ?? 'Authentication failed',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Device.screenSize.width * 0.05),
      child: Card(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: availableColors['orange'],
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        if (_selectedTabIndex != 0) {
                          _onTabClick(0);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize:
                            Size.fromWidth(Device.screenSize.width * 0.44),
                        backgroundColor: _selectedTabIndex == 0
                            ? availableColors['blue']
                            : availableColors['orange'],
                      ),
                      child: const Text(
                        'Signup',
                        style: textStyle,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        if (_selectedTabIndex != 1) {
                          _onTabClick(1);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize:
                            Size.fromWidth(Device.screenSize.width * 0.44),
                        backgroundColor: _selectedTabIndex == 0
                            ? availableColors['orange']
                            : availableColors['blue'],
                      ),
                      child: const Text(
                        'Login',
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  label: Center(
                    child: Text('Email'),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                textAlign: TextAlign.center,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      !value.contains('@')) {
                    return 'Enter a valid email';
                  }

                  return null;
                },
                onSaved: (newValue) {
                  _enteredEmail = newValue!;
                },
              ),
              if (_selectedTabIndex == 0)
                TextFormField(
                  decoration: const InputDecoration(
                    label: Center(
                      child: Text('Username'),
                    ),
                  ),
                  enableSuggestions: false,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length < 3 ||
                        value.trim().length > 16) {
                      return 'Username must be at least 3 characters.';
                    }

                    return null;
                  },
                  onSaved: (newValue) {
                    _enteredUsername = newValue!;
                  },
                ),
              TextFormField(
                decoration: const InputDecoration(
                  label: Center(
                    child: Text('Password'),
                  ),
                ),
                obscureText: true,
                textAlign: TextAlign.center,
                validator: (value) {
                  if (value == null || value.trim().length < 6) {
                    return 'Password must be at least 6 characters long.';
                  }

                  return null;
                },
                onSaved: (newValue) {
                  _enteredPassword = newValue!;
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  _onSubmitForm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: availableColors['blue'],
                ),
                child: Text(
                  _formLabel,
                  style: TextStyle(
                    color: availableColors['black'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
