import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_mobile.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _termsAccepted = false;

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState!.validate() && _termsAccepted) {
      String firstname = _firstnameController.text;
      String lastname = _lastnameController.text;
      String email = _emailController.text;
      String dob = _dobController.text;
      String phone = _phoneController.text;
      String password = _passwordController.text;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Sign Up'),
            content: Text('Firstname: $firstname  Lastname: $lastname\nEmail: $email\nDOB: $dob\nPhone: $phone\nPassword: $password'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.black,
      ),
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.blue, // Blue cursor
            selectionColor: Colors.blue.withOpacity(0.5), // Blue text selection color
            selectionHandleColor: Colors.blue, // Blue text selection handle color
          ),
        ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('SignUp',style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
          backgroundColor: Colors.blue,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },

          ),
          actions: [
            IconButton(
              icon: Icon(Icons.info, color: Colors.white),
              onPressed: () {
                // Show information dialog
              },
            ),
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                // Show settings page
              },
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
                    TextFormField(
                      controller: _firstnameController,
                      decoration: InputDecoration(
                        labelText: 'Firstname',
                        labelStyle: TextStyle(color: Colors.black),
                       focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue), // Changed border color to blue
                          ),
                          border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your firstname';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _lastnameController,
                      decoration: InputDecoration(
                        labelText: 'Lastname',
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue), // Changed border color to blue
                          ),
                          border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your lastname';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email', labelStyle: TextStyle(color: Colors.black),
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
                      controller: _dobController,
                      decoration: InputDecoration(
                        labelText: 'D.O.B', labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue), // Changed border color to blue
                          ),
                          border: OutlineInputBorder(),
                           suffixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                          ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your date of birth';
                        }
                        return null;
                      },
                      onTap: () async {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Colors.blue, // Changed the selected date color to blue
                                  onPrimary: Colors.white, // Text color of the selected date
                                  // onSurface: Colors.blue, // Color of the dates
                                ),
                                dialogBackgroundColor:Colors.white,
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone number',
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue), // Changed border color to blue
                          ),
                          border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
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
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue), // Changed border color to blue
                          ),
                          border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    CheckboxListTile(
                      title: Text('I agree to the Terms & Conditions'),
                      value: _termsAccepted,
                      onChanged: (bool? value) {
                        setState(() {
                          _termsAccepted = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading, activeColor: Colors.blue,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _navigateToLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: Text(
                            'Log In',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}
