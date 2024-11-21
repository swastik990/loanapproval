import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FAQ {
  final int faqId;
  final String question;
  final String answer;
  bool isExpanded;  // To manage the expanded state of the FAQ item

  FAQ({
    required this.faqId,
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
  
  // Factory constructor to create a FAQ from JSON
  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      faqId: json['faq_id'],
      question: json['question'],
      answer: json['answer'],
    );
  }

  // Method to convert FAQ object to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'faq_id': faqId,
      'question': question,
      'answer': answer,
    };
  }
}

class FAQPage extends StatefulWidget {
  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  List<Item> _data = [];  // This will hold the FAQ data fetched from the API

  @override
  void initState() {
    super.initState();
    fetchFAQs();  // Fetch FAQ data when the page is initialized
  }

  // Fetch FAQs from Django API
  Future<void> fetchFAQs() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/faqs/'));

    if (response.statusCode == 200) {
      List<dynamic> faqList = json.decode(response.body);
      setState(() {
        _data = faqList.map((faq) => Item(
          headerValue: faq['question'],
          expandedValue: faq['answer'],
        )).toList();
      });
    } else {
      // Handle error here if the API call fails
      print('Failed to load FAQs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Some FAQs',
            style: TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
        body: _data.isEmpty
            ? Center(child: CircularProgressIndicator())  // Show loading indicator while data is being fetched
            : ListView(
                children: _data.map<Widget>((Item item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ExpansionItem(
                      item: item,
                      onTap: () {
                        setState(() {
                          item.isExpanded = !item.isExpanded;
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

class Item {
  Item({
    required this.headerValue,
    required this.expandedValue,
    this.isExpanded = false,
  });

  String headerValue;
  String expandedValue;
  bool isExpanded;
}

class ExpansionItem extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ExpansionItem({Key? key, required this.item, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ListTile with gradient background
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
              item.headerValue,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            trailing: Icon(
              item.isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: Colors.black,
            ),
            onTap: onTap,
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: item.isExpanded ? null : 0,
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
              item.expandedValue,
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
