import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'feedback.dart';
import 'settings.dart';
import 'loanform.dart'; // Ensure the correct import for the LoanForm page

class HomePage extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomePageContent(),
    FeedbackPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: Color(0xFF13136A), // Fixed button background color
          color: Color(0xFF13136A), // Changed to #13136a
          animationDuration: const Duration(milliseconds: 300),
          items: const <Widget>[
            Icon(Icons.home, size: 30, color: Colors.white),
            Icon(Icons.feedback, size: 30, color: Colors.white),
            Icon(Icons.settings, size: 30, color: Colors.white),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  void _onApplyButtonTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoanForm()), // Ensure LoanForm is navigated correctly
    );
  }

  void _onReadButtonTap(BuildContext context) {
    // Action for the "Read" button (can be customized further)
  }

  Widget _buildRectangleItem(BuildContext context, String title, String imagePath) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              height: 100,
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      if (title == 'Analysis using ML')
                        ElevatedButton(
                          onPressed: () {
                            _onApplyButtonTap(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Button color for "Apply"
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text('Apply', style: TextStyle(color: Colors.white)),
                        ),
                      if (title == 'Know about loan Terms' || title == 'Some FAQs')
                        ElevatedButton(
                          onPressed: () {
                            _onReadButtonTap(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Button color for "Read"
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text('Read', style: TextStyle(color: Colors.white)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('lib/assets/avatar.png'),
            ),
            SizedBox(width: 10),
            Text('Hi User', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
        backgroundColor:Color(0xFF13136A),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 84, 126, 231),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(height: 8),
                    Text(
                      'Loan Approval System',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        _buildRectangleItem(context, 'Know about loan Terms', 'lib/assets/loan_terms.png'),
                        SizedBox(height: 20),
                        _buildRectangleItem(context, 'Analysis using ML', 'lib/assets/apply_now.png'),
                        SizedBox(height: 20),
                        _buildRectangleItem(context, 'Some FAQs', 'lib/assets/loan_status.png'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
