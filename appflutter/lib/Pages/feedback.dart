import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';  

class Feedback {
  String feedbackText;
  double? rating; // Rating can be null

  Feedback({
    required this.feedbackText,
    this.rating,
  });

  // Convert a Feedback object to JSON
  Map<String, dynamic> toJson() {
    return {
      'feedback': feedbackText,
      'rating': rating,
    };
  }

  // Create a Feedback object from JSON
  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      feedbackText: json['feedback'] as String,
      rating: json['rating'] != null ? json['rating'] as double : null,
    );
  }
}

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController feedbackController = TextEditingController();
  double rating = 0.0; // Store the selected rating
  bool isSubmitting = false; // Show loader while submitting feedback

  // Function to submit feedback to the backend
  Future<void> submitFeedback(Feedback feedbackData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token'); // Retrieve the token

    if (token == null) {
      print('No token found');
      return; // No token, exit function
    }

    final url = Uri.parse('http://10.0.2.2:8000/feedback/'); // For Android emulator

    setState(() {
      isSubmitting = true; // Show the loader while submitting
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(feedbackData.toJson()), // Convert Feedback object to JSON
    );

    setState(() {
      isSubmitting = false; // Hide the loader after submission
    });

    if (response.statusCode == 201) {
      print('Feedback submitted successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback submitted successfully!')),
      );
    } else {
      print('Failed to submit feedback: ${response.statusCode}');
      print('Error: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Feedback", style: TextStyle(color: Colors.white)),
          flexibleSpace: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF13136A), Color(0xFF5C6BC0)], // Gradient colors
                                begin: Alignment.bottomRight, // Start from top-left
                                end: Alignment.topLeft, // End at bottom-right
                              ),
                            ),
                          ),
           leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ), // Disable the back button
        ),
        body: isSubmitting
            ? Center(child: CircularProgressIndicator()) // Show loader during submission
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 85, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            "Your Feedback Matters",
                            style: TextStyle(
                              fontSize: isLandscape ? 28 : 35,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 70),
                    Text(
                      "How would you rate us?",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.green,
                      ),
                      onRatingUpdate: (newRating) {
                        setState(() {
                          rating = newRating; // Update rating
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Tell us more about your experience",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: feedbackController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Write your feedback here...",
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF13136A), // Background color
    ),
    onPressed: () {
      if (feedbackController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please provide feedback")),
        );
      } else {
        final feedbackData = Feedback(
          feedbackText: feedbackController.text,
          rating: rating == 0 ? null : rating,
        );
        submitFeedback(feedbackData);
      }
    },
    child: Text(
      "Submit",
      style: TextStyle(color: Colors.white), // Text color
    ),
  ),
)

                  ],
                ),
              ),
      ),
    );
  }
}
