import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible1 = false; 
  bool _isPasswordVisible2 = false; 
  bool _isPasswordVisible3 = false; 

  Future<void> changePassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No token found, please log in again')),
      );
      return;
    }

    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("New passwords do not match")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://10.0.2.2:8000/change-password/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'old_password': _oldPasswordController.text,
        'new_password': _newPasswordController.text,
        'confirm_new_password': _confirmPasswordController.text,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password updated successfully")),
      );
    } else {
      final responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['detail'] ?? "Failed to update password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF1A237E),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('lib/assets/changepassword.png', height: 180),
            SizedBox(height: 20),
            TextField(
              controller: _oldPasswordController,
              obscureText: !_isPasswordVisible1,
              decoration: InputDecoration(
                labelText: 'Old Password',
                labelStyle: TextStyle(color: Colors.black),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Color(0xFF13136A)),
                                                ),
                border: OutlineInputBorder(),
                 suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible1
                                ? Icons.visibility // Show password icon
                                : Icons.visibility_off, // Hide password icon
                            color: Color(0xFF13136A),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible1 = !_isPasswordVisible1; // Toggle visibility
                            });
                          },
                        ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _newPasswordController,
              obscureText: !_isPasswordVisible2,
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: Colors.black),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Color(0xFF13136A)),
                                                ),
                border: OutlineInputBorder(),
                 suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible2
                                ? Icons.visibility // Show password icon
                                : Icons.visibility_off, // Hide password icon
                            color: Color(0xFF13136A),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible2 = !_isPasswordVisible2; // Toggle visibility
                            });
                          },
                        ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_isPasswordVisible3,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                labelStyle: TextStyle(color: Colors.black),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Color(0xFF13136A)),
                                                ),
                border: OutlineInputBorder(),
                 suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible3
                                ? Icons.visibility // Show password icon
                                : Icons.visibility_off, // Hide password icon
                            color: Color(0xFF13136A),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible3 = !_isPasswordVisible3; // Toggle visibility
                            });
                          },
                        ),
              ),
            ),
            SizedBox(height: 20),
           ElevatedButton(
  onPressed: _isLoading ? null : changePassword,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green, // Background color
    // Text color
  ),
  child: _isLoading
      ? CircularProgressIndicator(color: Colors.white)
      : Text(
          'Change',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
),

          ],
        ),
      ),
    );
  }
}
