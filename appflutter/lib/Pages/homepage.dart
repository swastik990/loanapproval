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
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:intl/intl.dart';

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
  final String apiUrl = 'http://10.0.2.2:8000/profile/'; // Replace with your API URL

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

  // final GlobalKey _userNameShowKey = GlobalKey();
  final GlobalKey _userNameShowKey2 = GlobalKey();
  final GlobalKey _appLoanKey = GlobalKey();
  final GlobalKey _navigationHistoryKey = GlobalKey();
 
  late List<Widget> _screens;

 @override
@override
void initState() {
  super.initState();

  
  _screens = [
    HomePageContent(
      userNameKey2: _userNameShowKey2,
      appLoanKey: _appLoanKey,
    ),
    LoanHistoryScreen(),
    SettingsPage(),
  ];

  
 

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
          key: _navigationHistoryKey,
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: Color(0xFF13136A),
          color: Color(0xFF13136A),
          animationDuration: const Duration(milliseconds: 300),
          items:  <Widget>[
            Icon(Icons.home, size: 30, color: Colors.white),
            Icon( Icons.history, size: 30, color: Colors.white, ),
            Icon(Icons.settings, size: 30, color: Colors.white, ),
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
        identify: 'userNameShow2',
        keyTarget: _userNameShowKey2,
         shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomCenter,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => Text(
              'Welcome to Loan Approval App Created By Group 30. This a Small Guide to use our APP.',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      
      TargetFocus(
        identify: 'applyLoan',
        keyTarget: _appLoanKey,
        alignSkip: Alignment.bottomCenter,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => Text(
              'You can apply for a loan by clicking on this button',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'navigationbuttonhistory',
        keyTarget: _navigationHistoryKey,
         shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.topCenter,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => Text(
              'You can navigate through this.',
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
}

// Home page content with FutureBuilder for user data
class HomePageContent extends StatelessWidget {
  // final GlobalKey userNameKey;
  final GlobalKey userNameKey2;
  final GlobalKey appLoanKey;

  HomePageContent({
    // required this.userNameKey, 
  required this.userNameKey2, 
  required this.appLoanKey});
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
                          key: appLoanKey,
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
                                // key: userNameKey,
                                backgroundImage: NetworkImage(
                                  user.pictures?.isNotEmpty == true
                                      ? user.pictures!
                                      : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTSLU5_eUUGBfxfxRd4IquPiEwLbt4E_6RYMw&s',
                                ),
                              ),
                              SizedBox(width: 10),
                              Text( 
                                key: userNameKey2,
                              'Hi ${user.firstName}', style: TextStyle(color: Colors.white)),
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

           body: Container(
   // Light grey background
  child: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: 8),
                Text(
                  'Loan Approval System',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 0, 0, 0),
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
),

          );
        } else {
          return Center(child: Text('No user data available.'));
        }
      },
    );
  }
}
