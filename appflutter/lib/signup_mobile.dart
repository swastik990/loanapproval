import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_mobile.dart'; // Ensure this file exists and contains the LoginPage class
import 'Pages/homepage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class User {
  String first_name;
  String last_name;
  String email;
  DateTime dob;
  String phone;
  String password;
  
  bool agreeTerms;

  User({
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.dob,
    required this.phone,
    required this.password,
    
    this.agreeTerms = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': first_name,
      'last_name': last_name,
      'email': email,
      'dob': dob.toIso8601String().split('T')[0], // Convert to YYYY-MM-DD format
      'phone': phone,
      'password': password,
      
      'agree_terms': agreeTerms,
    };
  }
}

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  User _user = User(
    first_name: '',
    last_name: '',
    email: '',
    dob: DateTime.now(),
    phone: '',
    password: '',
  );

 bool _isPasswordVisible = false;
  void _signup() async {
    if (_formKey.currentState!.validate() && _user.agreeTerms) {
      ApiService apiService = ApiService();
      try {
        final response = await apiService.signup(_user);
        if (response.statusCode == 201) {
          _showSuccessDialog();
        } else {
          _showErrorDialog(response.body);
        }
      } catch (e) {
        _showErrorDialog('An error occurred: $e');
      }
    } else if (!_user.agreeTerms) {
      _showErrorDialog('You must agree to the terms and conditions');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Up Success'),
        content: Text('Your account has been created.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToLogin(); // Navigate to login after closing the dialog
            },
            child: Text('Login', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

// void _navigateToHome() {
//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(
//       builder: (context) => HomePage1(firstName: _user.first_name), // Pass first name
//     ),
//   );
// }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Up Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK',style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      appBar: AppBar(
        title: Text('Sign Up', style: TextStyle(color: Colors.white)),
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
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.info, color: Colors.white),
        //     onPressed: () {
        //       // Show information dialog
        //     },
        //   ),
        //   IconButton(
        //     icon: Icon(Icons.settings, color: Colors.white),
        //     onPressed: () {
        //       // Show settings page
        //     },
        //   ),r
        // ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
      children: [
          ClipRRect(
  borderRadius: BorderRadius.circular(16.0), 
  child: Image.asset(
    'lib/assets/homebanner.png', 
    height: 150,
    width: 150, 
    fit: BoxFit.cover, 
  ),
),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    initialValue: _user.first_name,
                    decoration: InputDecoration(
                      labelText: 'Firstname',
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF13136A)),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _user.first_name = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your firstname';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    initialValue: _user.last_name,
                    decoration: InputDecoration(
                      labelText: 'Lastname',
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF13136A)),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _user.last_name = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your lastname';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    initialValue: _user.email,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF13136A)),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _user.email = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'D.O.B',
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF13136A)),
                      ),
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF13136A)),
                    ),
                    controller: TextEditingController(
                      text: "${_user.dob.year.toString().padLeft(4, '0')}-${_user.dob.month.toString().padLeft(2, '0')}-${_user.dob.day.toString().padLeft(2, '0')}",
                    ),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _user.dob,
                        firstDate: DateTime(1950),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Color(0xFF13136A),
                                onPrimary: Colors.white,
                              ),
                              dialogBackgroundColor: Colors.white,
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null && picked != _user.dob) {
                        setState(() {
                          _user.dob = picked;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    initialValue: _user.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone number',
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF13136A)),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _user.phone = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    initialValue: _user.password,
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
                    
                    obscureText: !_isPasswordVisible, 
                    onChanged: (value) {
                      setState(() {
                        _user.password = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // CheckboxListTile(
                  //   title: Text('Is Admin'),
                  //   value: _user.isAdmin,
                  //   onChanged: (bool? value) {
                  //     setState(() {
                  //       _user.isAdmin = value ?? false;
                  //     });
                  //   },
                  //   controlAffinity: ListTileControlAffinity.leading,
                  //   activeColor: Color(0xFF13136A),
                  // ),
                  // SizedBox(height: 20),
                  CheckboxListTile(
                    title: Text('I agree to the Terms & Conditions'),
                    value: _user.agreeTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        _user.agreeTerms = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Color(0xFF13136A),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF13136A),
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    )));
  }
}

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8000'; // Update with your backend URL

  Future<http.Response> signup(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    return response;
  }
}
