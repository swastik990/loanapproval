import 'package:flutter/material.dart';
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

    await Future.delayed(const Duration(seconds: 2));

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('lib/assets/logo.png'),
              ),
              const SizedBox(width: 10),
              const Text(
                'Loan Approval System',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF13136A), Color(0xFF5C6BC0)],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
          ),
          actions: [
            PopupMenuButton<int>(
              icon: const Icon(Icons.info_outline, color: Colors.white, size: 40),
              onSelected: (value) {
                switch (value) {
                  case 0:
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('About Us'),
                        content: const Text('Information about the Loan Approval System by GROUP 30.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Close',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    );
                    break;
                  case 1:
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('This Page'),
                        content: const Text('This is the landing page.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Close',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    );
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 0,
                  child: Text('About Us'),
                ),
                PopupMenuItem(
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
            : Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/assets/back.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Loan Approval System\n',
                                    style: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF13136A),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' using\n',
                                    style: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(255, 103, 7, 0),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Machine Learning',
                                    style: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(255, 0, 72, 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(120),
                              child: Image.asset(
                                'lib/assets/LoanApprovalGIF.gif',
                                height: 250,
                                width: 250,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 90.0, 16.0, 16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _navigateToPage( LoginPage()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF13136A),
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                    minimumSize: const Size(140, 50),
                                  ),
                                  child: const Text(
                                    'Log In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () => _navigateToPage(SignupPage()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF13136A),
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                    minimumSize: const Size(140, 50),
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
              ),
      ),
    );
  }
}
