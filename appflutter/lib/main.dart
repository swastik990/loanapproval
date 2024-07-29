import 'package:flutter/material.dart';
import 'landing_mobile.dart';
// import 'package:appflutter/login_mobile.dart';
// import 'signup_mobile.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'landing_mobile',
      routes: {
        'landing_mobile': (context) => LandingPage(),
        // 'login_mobile': (context) => MyLogin(),
        // 'signup_mobile': (context) => SignupPage()
      },
    );
  }
}
