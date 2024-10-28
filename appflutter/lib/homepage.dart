import 'package:flutter/material.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'statements.dart';
// import 'search.dart';
// import 'feedback.dart';
// import 'settings.dart';

class HomePage extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> {
  // int _currentIndex = 0;

  // final List<Widget> _screens = [
  //   HomePageContent(),
  //   StatementPage(),
  //   SearchPage(),
  //   FeedbackPage(),
  //   SettingsPage(),
  // ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('lib/assets/avatar.png'), // Replace with your avatar image
              ),
              SizedBox(width: 10),
              Text('Hi Saitama', style: TextStyle(color: Colors.white)),
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
          backgroundColor: Colors.blue,
        ),
        body: HomePageContent(), // Set the body to HomePageContent
        // bottomNavigationBar: CurvedNavigationBar(
        //   backgroundColor: Colors.transparent,
        //   buttonBackgroundColor: const Color.fromARGB(255, 0, 140, 255),
        //   color: const Color.fromARGB(255, 0, 140, 255),
        //   animationDuration: const Duration(milliseconds: 300),
        //   items: const <Widget>[
        //     Icon(Icons.home, size: 30, color: Colors.white),
        //     Icon(Icons.receipt, size: 30, color: Colors.white),
        //     Icon(Icons.search, size: 30, color: Colors.white),
        //     Icon(Icons.feedback, size: 30, color: Colors.white),
        //     Icon(Icons.settings, size: 30, color: Colors.white),
        //   ],
        //   onTap: (index) {
        //     setState(() {
        //       _currentIndex = index;
        //     });
        //   },
        // ),
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  Widget _buildGridItem(String title, String imagePath) {
    return Column(
      children: [
        Image.asset(
          imagePath,
          height: 50,
        ),
        SizedBox(height: 5),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildLoanOption(String title, String imagePath, Color buttonColor) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              height: 40,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: Colors.blue[200],
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Balance',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                Text(
                  'NPR 364,200.00',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    _buildGridItem('LOAN TERMS', 'lib/assets/loan_terms.png'), // Replace with your asset paths
                    _buildGridItem('APPLY NOW', 'lib/assets/apply_now.png'),
                    _buildGridItem('REPAY', 'lib/assets/repay.png'),
                    _buildGridItem('TRANSFER', 'lib/assets/transfer.png'),
                    _buildGridItem('LOAN STATUS', 'lib/assets/loan_status.png'),
                    _buildGridItem('WITHDRAW', 'lib/assets/withdraw.png'),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available loans',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _buildLoanOption('HOME LOAN', 'lib/assets/home_loan.png', Colors.lightBlue),
                _buildLoanOption('CAR LOAN', 'lib/assets/car_loan.png', Colors.blue),
                _buildLoanOption('BUSINESS LOAN', 'lib/assets/business_loan.png', Colors.black),
                _buildLoanOption('EDUCATION LOAN', 'lib/assets/education_loan.png', Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
