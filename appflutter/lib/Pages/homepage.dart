import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'history.dart';
import 'settings.dart';
import 'faq.dart';
import 'loanform.dart'; 
import 'loan_terms.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
// User model
class User {
  final int userId;
  final String firstName;
  final String lastName;
  final String phone;
  final String dob;
  final String email;
  final String? pictures;
  final bool agreeTerms;
  final String checkInTime;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.dob,
    required this.email,
    this.pictures,
    required this.agreeTerms,
    required this.checkInTime,
  });

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

  Future<User> fetchUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return User.fromJson(jsonResponse);
    } else {
      throw Exception('Seems issue in network connection');
    }
  }
}

// Home page with navigation
class HomePage extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomePageContent(),
    LoanHistoryScreen(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(255, 0, 0, 0), // Adjusted color for visibility
      statusBarIconBrightness: Brightness.light, // For dark status bar background
    ));
    
    return SafeArea(
      
      
      child: Scaffold(
        
        body: _screens[_currentIndex],
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: Color(0xFF13136A),
          color: Color(0xFF13136A),
          animationDuration: const Duration(milliseconds: 300),
          items: const <Widget>[
            Icon(Icons.home, size: 30, color: Colors.white),
            Icon(Icons.history, size: 30, color: Colors.white),
            Icon(Icons.settings, size: 30, color: Colors.white),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

// Home page content with FutureBuilder for user data
class HomePageContent extends StatelessWidget {
  void _onApplyButtonTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoanForm()),
    );
  }

  void _onReadButtonTap(BuildContext context) {}

  Widget _buildRectangleItem(BuildContext context, String title, String imagePath) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              height: 100,
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      if (title == 'Analysis using ML')
                        ElevatedButton(
                          onPressed: () {
                            _onApplyButtonTap(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text('Apply', style: TextStyle(color: Colors.white)),
                        ),
                         if (title == 'Know about loan Terms' || title == 'Some FAQs')
                      ElevatedButton(
  onPressed: () {
    if (title == 'Know about loan Terms') {
      // Navigate to the Loan Terms page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoanTermsPage()),
      );
    } else if (title == 'Some FAQs') {
      // Navigate to the FAQs page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FAQPage()),
      );
    } else {
      // Optional: handle other cases or do nothing
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  ),
  child: Text('Read', style: TextStyle(color: Colors.white)),
),

                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: SettingsUser().fetchUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          User user = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
                          automaticallyImplyLeading: false,
                          title: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  user.pictures?.isNotEmpty == true
                                      ? user.pictures!
                                      : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTSLU5_eUUGBfxfxRd4IquPiEwLbt4E_6RYMw&s',
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Welcome ${user.firstName}', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          // actions: [
                          //   IconButton(
                          //     icon: Icon(Icons.notifications, color: Colors.white),
                          //     onPressed: () {},
                          //   ),
                          //   IconButton(
                          //     icon: Icon(Icons.info_outline, color: Colors.white),
                          //     onPressed: () {},
                          //   ),
                          // ],
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

            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
            colors: [Color(0xFF13136A), const Color.fromARGB(255, 114, 107, 152)], // Blue to White gradient
            begin: Alignment.bottomLeft, // Gradient starts from the top-right
            end: Alignment.topRight, // Gradient ends at the bottom-left
          ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          SizedBox(height: 8),
                          Text(
                            'Loan Approval System',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                          Column(
                            children: [
                              _buildRectangleItem(context, 'Know about loan Terms', 'lib/assets/loan_terms.png'),
                              SizedBox(height: 20),
                              _buildRectangleItem(context, 'Analysis using ML', 'lib/assets/apply_now.png'),
                              SizedBox(height: 20),
                              _buildRectangleItem(context, 'Some FAQs', 'lib/assets/withdraw.png'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Center(child: Text('No user data available.'));
        }
      },
    );
  }
}
