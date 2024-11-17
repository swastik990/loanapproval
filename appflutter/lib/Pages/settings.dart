import 'package:flutter/material.dart';
import 'package:appflutter/Pages/user_profile_page.dart'; // Correct path to your profile page
import 'package:appflutter/login_mobile.dart'; // Correct path to your login page
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? userPicture;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

 void _navigateToProfile(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UserProfilePage(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text,
        dob: _dobController.text,
        userPicture: userPicture, // Pass the user picture if available
      ),
    ),
  );
}


  Future<void> _fetchUserProfile() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/profile/'),
      headers: {
        'Authorization': 'Bearer access_token',  // Include JWT token if needed
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _firstNameController.text = data['first_name'];
        _lastNameController.text = data['last_name'];
        _phoneController.text = data['phone'];
        _dobController.text = data['dob'];
        userPicture = data['pictures'];  // Assuming 'pictures' is a URL
      });
    } else {
      // Handle error
    }
  }

  Future<void> _updateUserProfile() async {
    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/profile/'),
      headers: {
        'Authorization': 'Bearer access_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'phone': _phoneController.text,
        'dob': _dobController.text,
        // 'pictures': userPicture,  // if you allow picture upload/change
      }),
    );

    if (response.statusCode == 200) {
      // Handle success, maybe show a success message
    } else {
      // Handle error
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        userPicture = image.path; // You can upload this path in the _updateUserProfile function
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.blue[100],
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _navigateToProfile(context); // Add tap event to navigate to the profile page
                  },
                  child: CircleAvatar(
                    backgroundImage: AssetImage('lib/assets/avatar.png'), // Replace with your avatar image path
                    radius: 30,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _firstNameController.text, // Use the fetched first name
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _phoneController.text,  // Use the fetched phone
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person, color: Colors.blue),
            title: Text('Profile'),
            subtitle: Text('View and edit your profile'),
            onTap: () {
              _navigateToProfile(context); // Navigate to Profile Page
            },
          ),
          // Other ListTiles...
        ],
      ),
    );
  }
}
