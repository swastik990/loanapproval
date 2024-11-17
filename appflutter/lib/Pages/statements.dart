import 'package:flutter/material.dart';

class StatementPage extends StatefulWidget {
  @override
  _StatementPageState createState() => _StatementPageState();
}

class _StatementPageState extends State<StatementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  

  Widget _buildLoanCard(
      String status,
      String bankName,
      String loanAmount,
      String interest,
      Color statusColor,
      String logoPath) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Image.asset(
              logoPath,
              height: 50,
              width: 50,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                  SizedBox(height: 5),
                  Text(
                    bankName,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    loanAmount,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text('Interest: $interest'),
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
        title: Text('Statements'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade200,
        
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          tabs: [
            Tab(text: 'Applied'),
            Tab(text: 'Approved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView(
            padding: EdgeInsets.symmetric(vertical: 10), // Add vertical padding
            children: [
              _buildLoanCard(
                'Pending',
                'Sanima Bank',
                '\$100,000',
                '10.50%',
                Colors.orange,
                'lib/assets/sanima.png',
              ),
              _buildLoanCard(
                'Rejected',
                'Capital Crest Bank',
                '\$100,000',
                '16.00%',
                Colors.red,
                'lib/assets/nabil.png',
              ),
            ],
          ),
          ListView(
            padding: EdgeInsets.symmetric(vertical: 10), // Add vertical padding
            children: [
              _buildLoanCard(
                'Approved',
                'Unity Trust',
                '\$50,000',
                '12.50%',
                Colors.green,
                'lib/assets/abank.png',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
