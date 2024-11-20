import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'signup_mobile.dart';
import 'login_mobile.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isLoading = false;

  void _navigateToPage(Widget page) async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 2)); // Simulate a delay

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Change status bar color
    

    return SafeArea(
      child: Scaffold(
        backgroundColor:Color(0xFFFEFEFE),
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
  radius: 20, // Adjust the size of the circle
  backgroundImage: AssetImage('lib/assets/logo.png'),
),
              const SizedBox(width: 10),
              const Text(
                'Loan Approval System',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Color(0xFF13136A),
          actions: [
            PopupMenuButton<int>(
              icon: Icon(Icons.info_outline, color: Colors.white, size: 40),
              onSelected: (value) {
                switch (value) {
                  case 0:
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('About Us'),
                          content: Text('Information about the Loan Approval System by GROUP 30.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close', style: TextStyle(color: Colors.black),),
                            ),
                          ],
                        );
                      },
                    );
                    break;
                  case 1:
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('This Page'),
                          content: Text('This is the landing page.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close', style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        );
                      },
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 0,
                  child: Text('About Us'),
                ),
                const PopupMenuItem(
                  value: 1,
                  child: Text('This Page'),
                ),
              ],
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: SpinKitFadingCircle(
                  color: Color(0xFF13136A),
                  size: 50.0,
                ),
              )
            : Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Seamless Loan Approvals, Anytime, Anywhere.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF13136A),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // Set radius value here
                child: Image.asset(
                  'lib/assets/LoanApprovalGIF.gif', // Replace PNG with GIF
                  height: 250,
                  width: 250, // Optional: Set width if needed
                  fit: BoxFit.cover, // Optional: To maintain aspect ratio while filling the container
                ),
              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 90.0, 16.0, 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () => _navigateToPage(LoginPage()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF13136A),
                                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                minimumSize: Size(140, 50),
                              ),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _navigateToPage(SignupPage()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF13136A),
                                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                minimumSize: Size(140, 50),
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
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
  }
}
