import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding

void main() {
  runApp(MaterialApp(
    home: LoanTermsPage(),
  ));
}

class LoanTermsPage extends StatefulWidget {
  @override
  _LoanTermsPageState createState() => _LoanTermsPageState();
}

class _LoanTermsPageState extends State<LoanTermsPage> {
  // A list to store loan terms fetched from the Django API
  List<LoanTerm> _terms = [];

  @override
  void initState() {
    super.initState();
    // Fetch the loan terms when the widget is initialized
    fetchLoanTerms();
  }

  // Method to fetch loan terms from the Django API
  Future<void> fetchLoanTerms() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/terms/'));

    if (response.statusCode == 200) {
      // If the API returns a 200 OK response, decode the JSON data
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _terms = data.map((termData) => LoanTerm.fromJson(termData)).toList();
      });
    } else {
      // If the server doesn't return a 200 OK response, throw an error
      throw Exception('Failed to load loan terms');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Loan Terms',
            style: TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF13136A), Color(0xFF5C6BC0)], // Gradient colors
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
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: _terms.isEmpty
              ? [Center(child: CircularProgressIndicator())] // Show a loading indicator if terms are not fetched yet
              : _terms.map<Widget>((LoanTerm term) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: LoanTermItem(
                      term: term,
                      onTap: () {
                        setState(() {
                          term.isExpanded = !term.isExpanded;
                        });
                      },
                    ),
                  );
                }).toList(),
        ),
      ),
    );
  }
}

class LoanTerm {
  String title;
  String details;
  bool isExpanded;

  LoanTerm({
    required this.title,
    required this.details,
    this.isExpanded = false,
  });

  // Factory method to create LoanTerm from JSON data
  factory LoanTerm.fromJson(Map<String, dynamic> json) {
    return LoanTerm(
      title: json['title'],
      details: json['details'],
    );
  }
}

class LoanTermItem extends StatelessWidget {
  final LoanTerm term;
  final VoidCallback onTap;

  const LoanTermItem({Key? key, required this.term, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 76, 106, 241).withOpacity(0.4),
                const Color.fromARGB(255, 255, 255, 255).withOpacity(0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            title: Text(
              term.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            trailing: Icon(
              term.isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: Colors.black,
            ),
            onTap: onTap,
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: term.isExpanded ? null : 0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 242, 242, 242).withOpacity(0.3),
                Colors.blueAccent.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              term.details,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
