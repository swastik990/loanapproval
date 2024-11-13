import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String phone;
  final String dob;
  final String? userPicture;

  // Constructor to accept user data
  UserProfilePage({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.dob,
    this.userPicture,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: userPicture != null
                  ? NetworkImage(userPicture!) // Show fetched picture
                  : AssetImage('lib/assets/avatar.png') as ImageProvider, // Fallback avatar
              radius: 50,
            ),
            SizedBox(height: 20),
            Text(
              'First Name: $firstName',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Last Name: $lastName',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Phone: $phone',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Date of Birth: $dob',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
