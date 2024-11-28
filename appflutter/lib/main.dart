import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'landing_mobile.dart'; // Your Landing Page
import 'login_mobile.dart'; // Your Home Page
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import SpinKit

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(const Duration(seconds: 2)); // Add delay for splash
  runApp(MyApp());

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.black, // Set the desired color
    statusBarIconBrightness: Brightness.light, // Adjust icon color for contrast
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'splash_screen', // Start with SplashScreen
      routes: {
        'splash_screen': (context) => SplashScreen(), // Splash Screen route
        'landing_mobile': (context) => LandingPage(), 
        '/login': (context) => LoginPage(), // Main landing page
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, 'landing_mobile');
    });

    return Scaffold(
      body: Container(
        // Gradient background with custom colors and direction
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF13136A), Color(0xff281537)], // Blue to White gradient
            begin: Alignment.topRight, // Gradient starts from the top-right
            end: Alignment.bottomLeft, // Gradient ends at the bottom-left
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rounded Image
              ClipRRect(
                borderRadius: BorderRadius.circular(20), // Set radius value here
                child: Image.asset(
                  'lib/assets/LoanApprovalGIF.gif', // Replace PNG with GIF
                  height: 100,
                  width: 100, // Optional: Set width if needed
                  fit: BoxFit.cover, // Optional: To maintain aspect ratio while filling the container
                ),
              ),
              SizedBox(height: 20),
              // Title
              Text(
                "Loan Approval System",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              // Subtitle
              Text(
                "By Group 30",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              // Spinner
              SpinKitCircle(
                color: Colors.white,
                size: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
