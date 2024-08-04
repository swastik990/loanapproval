import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'signup_mobile.dart';
import 'homepage.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupPage()),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Change status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: const Color.fromARGB(255, 171, 171, 171),
      statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Brightness.light, // For iOS (light background)
    ));

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
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
                              child: Text('Close'),
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
                          content: Text('This is the Login page.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close'),
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
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/loan_approval.png', // Replace with your asset path
                      height: 200,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue), // Changed border color to blue
                        ),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue), // Changed border color to blue
                        ),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: Text(
                        'Log In',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('OR SIGN IN WITH', style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: SizedBox(
                            width: 40,
                            height: 40,
                            child: Image.asset('lib/assets/facebook.png'), // Replace with your asset path
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: SizedBox(
                            width: 40,
                            height: 40,
                            child: Image.asset('lib/assets/apple.png'), // Replace with your asset path
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: SizedBox(
                            width: 40,
                            height: 40,
                            child: Image.asset('lib/assets/google.png'), // Replace with your asset path
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: _navigateToSignup,
                      child: Text('Don\'t have an account? Sign Up', style: TextStyle(color: Colors.blue)),
                    ),
                    TextButton(
                      onPressed: _navigateToForgotPassword,
                      child: Text('Forgot Password?', style: TextStyle(color: Colors.blue)),
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
