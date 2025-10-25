import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in'),
      ),
      body: SignInScreen(
        providers: [
          EmailAuthProvider(),
        ],
        actions: [
          AuthStateChangeAction<SignedIn>((context, state){
            Navigator.pop(context);
          }),
        ],
        subtitleBuilder: (context, action) {
          return const Padding(
            padding:EdgeInsets.only(bottom: 8),
            child: Text('Sign in to sync your streak and entries'), 
          );
        },
      ),
    );
  }
}