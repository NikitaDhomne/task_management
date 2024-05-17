import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_synchro/screens/homepage.dart';

import 'package:task_synchro/screens/signIn_screen.dart';

class SplashServices {
  void isLogin(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user != null) {
      Timer(Duration(seconds: 5), () {
        Navigator.pushReplacementNamed(context, Homepage.routeName);
      });
    } else {
      Timer(Duration(seconds: 5), () {
        Navigator.pushReplacementNamed(context, SignInPage.routeName);
      });
    }
  }
}
