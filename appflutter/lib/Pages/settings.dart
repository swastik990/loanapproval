import 'package:flutter/material.dart';
import 'edit_profile.dart';
import 'about.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../change_password.dart'; 
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:intl/intl.dart';

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
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsUser settingsUser = SettingsUser();

  final GlobalKey _settingKey = GlobalKey();
  final GlobalKey _viewProfileKey = GlobalKey();
  final GlobalKey _editProfileKey = GlobalKey();
  final GlobalKey _changePasswordKey = GlobalKey();
  final GlobalKey _outKey = GlobalKey();

void initState() {
    
    super.initState();
    _initializeTutorial();
  }

  void _initializeTutorial() async {
  try {
    User user = await SettingsUser().fetchUser();

    // Preprocess checkInTime to remove the day name
    String preprocessedTime = user.checkInTime.replaceAll(RegExp(r', [A-Za-z]+'), '');

    // Define the date format
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

    // Parse the cleaned date string
    DateTime checkInDateTime = dateFormat.parse(preprocessedTime);

    await _checkAndShowTutorial(user.userId, checkInDateTime);
  } catch (e) {
    print('Error during tutorial initialization: $e');
  }
}

Future<void> _checkAndShowTutorial(int userId, DateTime checkInTime) async {
  final prefs = await SharedPreferences.getInstance();

  try {
    // Force reset the 'hasSeenTutorial' flag for testing purposes (REMOVE THIS in production!)
    await prefs.setBool('hasSeenTutorial', false);  // Temporary reset

    // Get the current Nepali time
    DateTime currentTimeNepali = DateTime.now().add(Duration(hours: 0, minutes: 00));

    // Calculate the difference between the current time and checkInTime
    Duration timeDifference = currentTimeNepali.difference(checkInTime).abs();

    // Log debugging information
    debugPrint('User ID: $userId');
    debugPrint('Check-In Time: $checkInTime');
    debugPrint('Current Nepali Time: $currentTimeNepali');
    debugPrint('Time Difference: ${timeDifference.inMinutes} minutes');

    // Check if the tutorial has been shown
    bool hasSeenTutorial = prefs.getBool('hasSeenTutorial') ?? false;

    // Only show the tutorial if the time difference is within 5 minutes and it hasn't been shown before
    if (!hasSeenTutorial && timeDifference.inMinutes <= 1) {
      _createTutorial();

      // Update the flag so the tutorial won't be shown again
      await prefs.setBool('hasSeenTutorial', true);
      debugPrint('Tutorial displayed.');
    } else {
      debugPrint('Conditions not met for showing tutorial.');
    }
  } catch (e) {
    debugPrint('Error during tutorial initialization: $e');
  }
}
Future<void> trackUserCount(int userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Load the existing set of user IDs (or initialize an empty set if it doesn't exist)
  List<String>? userIdList = prefs.getStringList('unique_user_ids');
  Set<String> userIds = userIdList?.toSet() ?? {};

  // Add the current user ID
  userIds.add(userId.toString());

  // Save the updated set back to SharedPreferences
  await prefs.setStringList('unique_user_ids', userIds.toList());

  // Print the current unique user count
  print('Unique user count: ${userIds.length}');
}

Future<int> getUniqueUserCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? userIdList = prefs.getStringList('unique_user_ids');
  return userIdList?.length ?? 0;
}
 Future<void> _createTutorial() async {
    final targets = [
      TargetFocus(
        identify: 'settingKey',
        keyTarget: _settingKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomCenter,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => Text(
              'This is Setting page where you can edit profile or change password.',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      
      TargetFocus(
        identify: 'viewProfile',
        keyTarget: _viewProfileKey,
        
        alignSkip: Alignment.bottomCenter,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => Text(
              'You can view your Profile.',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
       TargetFocus(
        identify: 'editProfile',
        keyTarget: _editProfileKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomCenter,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => Text(
              'You can edit your Profile.',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'changePword',
        keyTarget: _changePasswordKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomCenter,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => Text(
              'You can change password.',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'logout',
        keyTarget: _outKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomCenter,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => Text(
              'Or, You can logout.',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      
    ]
    
    ;

    final tutorial = TutorialCoachMark(targets: targets);

    Future.delayed(const Duration(milliseconds: 500), () {
      tutorial.show(context: context);
    });
  }


  @override
  Widget build(BuildContext context) {
     return SafeArea(
      child: Scaffold(
      appBar: AppBar(
        title: Text(
          key:_settingKey,
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
                          CircleAvatar(key:_viewProfileKey,   
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
                    child: Text(key: _editProfileKey,
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
                  ListTile(key: _changePasswordKey,
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
                  ListTile(key:_outKey,
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
                colors: [Color(0xFF13136A), Color(0xFF5C6BC0)], 
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hero animation for profile picture
                Hero(
                  tag: 'profile-picture',
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(
                      user.pictures ?? 'https://via.placeholder.com/150',
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // User information fields with animation
                AnimatedProfileField(label: "First Name                        :", value: user.firstName),
                AnimatedProfileField(label: "Last Name                        :", value: user.lastName),
                AnimatedProfileField(label: "Email                                 :", value: user.email),
                AnimatedProfileField(label: "D.O.B                                 :", value: user.dob),
                AnimatedProfileField(label: "Phone number                 :", value: user.phone),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Animated profile field
class AnimatedProfileField extends StatelessWidget {
  final String label;
  final String value;

  const AnimatedProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: 500),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double opacity, child) {
          return Opacity(
            opacity: opacity,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.grey,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label text with normal weight
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.normal, // Set label to normal weight
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    // Value text with bold weight
                    child: Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold, // Keep value bold
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}