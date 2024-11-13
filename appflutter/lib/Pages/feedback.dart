import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text('Feedback Screen'),
      ),
    );
  }
}
