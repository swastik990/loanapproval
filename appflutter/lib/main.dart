import 'package:flutter/material.dart';
import 'landing_mobile.dart';
import 'package:flutter/services.dart';
// import 'package:appflutter/login_mobile.dart';
// import 'signup_mobile.dart';

void main() {

    

 
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'landing_mobile',
    routes: {
      'landing_mobile': (context) => LandingPage(),
      // 'login_mobile': (context) => MyLogin(),
      // 'signup_mobile': (context) => SignupPage()
    },
  ));
}

