import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
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
    return Scaffold(
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
      body: SingleChildScrollView(
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Statement',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedbacks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
