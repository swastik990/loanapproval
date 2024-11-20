import 'package:flutter/material.dart';
import 'edit_profile.dart';
import 'about.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../change_password.dart'; 

// User model class
class User {
  final int userId;
  final String firstName;
  final String lastName;
  final String phone;
  final String dob;
  final String email;
  final String? pictures;
  final bool? agreeTerms;
  final String checkInTime;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.dob,
    required this.email,
    required this.pictures,
    required this.agreeTerms,
    required this.checkInTime,
  });

  // Factory constructor to create a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      dob: json['dob'],
      email: json['email'],
      pictures: json['pictures'],
      agreeTerms: json['agree_terms'],
      checkInTime: json['check_in_time'],
    );
  }

  // Method to convert a User object into JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'dob': dob,
      'email': email,
      'pictures': pictures,
      'agree_terms': agreeTerms,
      'check_in_time': checkInTime,
    };
  }
}

// User settings service to fetch data with JWT authentication
class SettingsUser {
  final String apiUrl = 'http://10.0.2.2:8000/profile/';  // Replace with your API URL

  // Fetch users from the API with JWT Authentication
  Future<User> fetchUser() async {
    // Get the JWT token from SharedPreferences (assuming it is saved there after login)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Token not found');
    }

    // Set up the headers with the JWT token
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',  // Send the token in the Authorization header
    };

    // Make the GET request
    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON data
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return User.fromJson(jsonResponse);
    } else {
      // If the server returns an error, throw an exception
      throw Exception('Seems issue in network connection');
    }
  }
}

class SettingsPage extends StatelessWidget {
  final SettingsUser settingsUser = SettingsUser();

  @override
  Widget build(BuildContext context) {
     return SafeArea(
      child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF13136A), Color(0xFF5C6BC0)], // Gradient colors
                                begin: Alignment.bottomRight, // Start from top-left
                                end: Alignment.topLeft, // End at bottom-right
                              ),
                            ),
                          ),
        automaticallyImplyLeading: false, // This removes the back arrow
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.info_outline),
        //     onPressed: () {
        //       // Info button action
        //     },
        //   ),
        // ],
      ),
      body: FutureBuilder<User>(
        future: settingsUser.fetchUser(), // Fetch the user data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No user data available'));
          } else {
            // Access the fetched user data here
            User user = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile picture and info, wrapped in GestureDetector for navigation
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage(user: user)),
                      );
                    },
                    child: Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                               user.pictures ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTSLU5_eUUGBfxfxRd4IquPiEwLbt4E_6RYMw&s', // Use the fetched user's picture
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '${user.firstName} ${user.lastName}',  // Use the dynamic first and last name
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            user.email,  // Use the fetched user's email
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Edit Profile button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfilePage(user:user)),
                      );
                    },
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.white), // Set text color to white
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF13136A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Change password
                  ListTile(
                    leading: Icon(Icons.lock_outline, color: Color(0xFF13136A)),
                    title: Text('Change password'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Change password action
                      Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                                  );
                    },
                  ),
                  // About Us
                  ListTile(
                    leading: Icon(Icons.info_outline, color: Color(0xFF13136A)),
                    title: Text('About Us'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // About Us action
                      Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AboutUsPage()),
                                  );
                    },
                  ),
                  // Log Out
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('LogOut'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.remove('access_token'); // Clear the token
                      Navigator.pushReplacementNamed(context, '/login'); // Navigate to the login page
                    },
                  ),
                ],
              ),
            ));
          }
        },
      ),
    ));
  }
}

// ProfilePage widget
class ProfilePage extends StatelessWidget {
  final User user; // Receive the user data in the constructor

  ProfilePage({required this.user});

  @override
  Widget build(BuildContext context) {
     return SafeArea(
      child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF13136A), Color(0xFF5C6BC0)], // Gradient colors
                                begin: Alignment.bottomRight, // Start from top-left
                                end: Alignment.topLeft, // End at bottom-right
                              ),
                            ),
                          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Enlarged profile picture with edit icon
            CircleAvatar(
              radius: 70, // Increased radius for a larger profile image
              backgroundImage: NetworkImage( user.pictures ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTSLU5_eUUGBfxfxRd4IquPiEwLbt4E_6RYMw&s',), // Use the user's picture
            ),
            SizedBox(height: 20),

            // User information fields
            buildProfileField("First Name:", user.firstName),
            buildProfileField("Last Name:", user.lastName),
            buildProfileField("Email:", user.email),
            buildProfileField("D.O.B:", user.dob),
            buildProfileField("Phone number:", user.phone),
          ],
        ),
      ),
    )));
  }

  // Helper widget to create each field
  Widget buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 199, 199, 199),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
