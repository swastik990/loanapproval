import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';
import 'package:flutter/services.dart';  
import 'package:flutter_spinkit/flutter_spinkit.dart';


class EditProfilePage extends StatefulWidget {
  final User user;

  EditProfilePage({required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUpdating = false; // To manage update button state

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.user.firstName;
    _lastNameController.text = widget.user.lastName;
    _dobController.text = widget.user.dob;
    _phoneController.text = widget.user.phone;
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: SpinKitFadingCircle(
                  color: Color(0xFF13136A),
                  size: 50.0,
                ),),
    );

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('Token not found');
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('http://10.0.2.2:8000/profile/'), 
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['first_name'] = _firstNameController.text;
      request.fields['last_name'] = _lastNameController.text;
      request.fields['dob'] = _dobController.text;
      request.fields['phone'] = _phoneController.text;

      if (_profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'pictures',
          _profileImage!.path,
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
        Navigator.pop(context); 
      } else {
        final error = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $error')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
     return SafeArea(
      child: Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : widget.user.pictures != null
                              ? NetworkImage(widget.user.pictures!)
                              : AssetImage('lib/assets/default_profile.png') as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      child: ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape:CircleBorder(
                            
                          ),
                        ),
                        child: Icon(Icons.change_circle, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                
                TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                                                labelText: 'First Name',
                                                labelStyle: TextStyle(color: Colors.black),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Color(0xFF13136A)),
                                                ),
                                                border: OutlineInputBorder(),
                                              ),
                            keyboardType: TextInputType.phone,
                            
                          
                          ),
                SizedBox(height: 16),
                
                TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                                                labelText: 'Last Name',
                                                labelStyle: TextStyle(color: Colors.black),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Color(0xFF13136A)),
                                                ),
                                                border: OutlineInputBorder(),
                                              ),
                            keyboardType: TextInputType.phone,
                            
                          
                          ),
                SizedBox(height: 16),
                TextField(
                  controller: _dobController,
                  decoration: InputDecoration(
                      labelText: 'D.O.B',
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF13136A)),
                      ),
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF13136A)),
                    ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(_dobController.text),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
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
                    if (pickedDate != null) {
                      _dobController.text = pickedDate.toIso8601String().split('T')[0];
                    }
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
  controller: _phoneController,
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
  validator: (value) {
    if (value!.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  },
),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isUpdating ? null : _updateProfile,
                  child: _isUpdating
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                              'Update',
                              style: TextStyle(color: Colors.white), // Set text color to white
                            ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
