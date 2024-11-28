import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'signup_mobile.dart';
import 'Pages/homepage.dart';
import 'forgot_password.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String apiUrl = 'http://10.0.2.2:8000/login/';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('refresh_token', data['refresh']);
          await prefs.setString('access_token', data['access']);

          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          final responseBody = jsonDecode(response.body);
          _showErrorDialog(responseBody['error'] ?? 'Unknown error occurred.');
        }
      } catch (e) {
        _showErrorDialog('An error occurred.');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Failed'),
        content: Text('Error: $message'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK', style: TextStyle(color: Color(0xFF13136A))),
          ),
        ],
      ),
    );
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(255, 0, 0, 0), 
      statusBarIconBrightness: Brightness.light, 
    ));
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login', style: TextStyle(color: Colors.white)),
          flexibleSpace: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                // colors: [Color(0xFF13136A), Color(0xff281537)], 
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
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
  borderRadius: BorderRadius.circular(16.0), 
  child: Image.asset(
    'lib/assets/homebanner.png', 
    height: 200,
    width: 200, 
    fit: BoxFit.cover, 
  ),
),
                    SizedBox(height: 20),
                    Text(
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 30,
                        color: Color(0xFF13136A),
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
                          borderSide: BorderSide(color: Color(0xFF13136A)),
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
                      obscureText: !_isPasswordVisible, 
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF13136A)),
                        ),
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility 
                                : Icons.visibility_off, 
                            color: Color(0xFF13136A),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible; 
                            });
                          },
                        ),
                      ),
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
                        backgroundColor: Color(0xFF13136A),
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: Text(
                        'Log In',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Text('OR SIGN IN WITH', style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // children: [
                      //   IconButton(
                      //     icon: SizedBox(
                      //       width: 40,
                      //       height: 40,
                      //       child: Image.asset('lib/assets/facebook.png'), 
                      //     ),
                      //     onPressed: () {},
                      //   ),
                      //   IconButton(
                      //     icon: SizedBox(
                      //       width: 40,
                      //       height: 40,
                      //       child: Image.asset('lib/assets/google.png'), 
                      //     ),
                      //     onPressed: () {},
                      //   ),
                      // ],
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: _navigateToSignup,
                      child: Text('Don\'t have an account? Sign Up', style: TextStyle(color: Color(0xFF13136A))),
                    ),
                    // TextButton(
                    //   onPressed: _navigateToForgotPassword,
                    //   child: Text('Forgot Password?', style: TextStyle(color: Color(0xFF13136A))),
                    // ),
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


