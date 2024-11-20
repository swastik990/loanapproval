import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'feedback.dart';

class LoanHistoryScreen extends StatefulWidget {
  const LoanHistoryScreen({Key? key}) : super(key: key);

  @override
  _LoanHistoryScreenState createState() => _LoanHistoryScreenState();
}

class _LoanHistoryScreenState extends State<LoanHistoryScreen> {
  List<dynamic> loanHistory = [];
  bool isLoading = true;
  late String token;
  double totalApprovedLoanAmount = 0.0;

  final String apiUrl = "http://10.0.2.2:8000/api/loan-history/";

  // Fetch the token from SharedPreferences
  Future<void> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access_token') ?? '';
    if (token.isEmpty) {
      print('Token not found!');
    }
  }

  // Fetch loan history from the API
  Future<void> fetchLoanHistory() async {
    try {
      await getToken(); // Ensure the token is loaded before making the API request

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Calculate total approved loan amount
        totalApprovedLoanAmount = data
            .where((record) => record['status'] == true) // Filter approved loans
            .fold(0.0, (sum, record) {
              final loanAmount =
                  double.tryParse(record['loan_amount'].toString()) ?? 0.0;
              return sum + loanAmount;
            });

        setState(() {
          loanHistory = data;
          isLoading = false;
        });
      } else {
        print('Failed to load loan history. Status: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching loan history: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLoanHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF13136A), Color(0xFF5C6BC0)], // Gradient colors
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Total Loan Records: ${loanHistory.length}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Loan Amount: Rs $totalApprovedLoanAmount',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Loan History',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: loanHistory.isEmpty
                        ? const Center(
                            child: Text(
                              'No loan history found.',
                              style: TextStyle(fontSize: 16.0, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: loanHistory.length,
                            itemBuilder: (context, index) {
                              final record = loanHistory[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.account_balance_wallet,
                                      color: Colors.green),
                                  title: Text('Loan Amount: Rs ${record['loan_amount']}'),
                                  subtitle: Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Status: ',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: record['status'] ? 'Approved' : 'Rejected',
                                          style: TextStyle(
                                            color: record['status']
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              '\nUpdated: ${record['time_updated']}',
                                          style:
                                              const TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 20),
                  FeedbackButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FeedbackScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class FeedbackButton extends StatelessWidget {
  final VoidCallback onTap;

  const FeedbackButton({required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.feedback, size: 18.0, color: Colors.black),
                SizedBox(width: 8.0),
                Text(
                  'Share Feedback',
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, size: 18.0, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
