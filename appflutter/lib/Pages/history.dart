import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'feedback.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:intl/intl.dart';
import 'settings.dart';

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
   final GlobalKey _historyKey = GlobalKey();
  final GlobalKey _viewRecordKey = GlobalKey();
  final GlobalKey _recordListKey = GlobalKey();
  final GlobalKey _feedBackKey = GlobalKey();

  // Fetch loan history from the API
  Future<void> fetchLoanHistory() async {
    try {
      await getToken(); 

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
            .where((record) => record['status'] == true) 
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
    _initializeTutorial();
  }
  
void _initializeTutorial() async {
  try {
    User user = await SettingsUser().fetchUser();

    // Preprocess checkInTime to remove the day name
    String preprocessedTime = user.checkInTime.replaceAll(RegExp(r', [A-Za-z]+'), '');

    // Define the date format
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

    // Parse the cleaned date string
    DateTime checkInDateTime = dateFormat.parse(preprocessedTime);

    await _checkAndShowTutorial(user.userId, checkInDateTime);
  } catch (e) {
    print('Error during tutorial initialization: $e');
  }
}

Future<void> _checkAndShowTutorial(int userId, DateTime checkInTime) async {
  final prefs = await SharedPreferences.getInstance();

  try {
    // Force reset the 'hasSeenTutorial' flag for testing purposes (REMOVE THIS in production!)
    await prefs.setBool('hasSeenTutorial', false);  // Temporary reset

    // Get the current Nepali time
    DateTime currentTimeNepali = DateTime.now().add(Duration(hours: 0, minutes: 00));

    // Calculate the difference between the current time and checkInTime
    Duration timeDifference = currentTimeNepali.difference(checkInTime).abs();

    // Log debugging information
    debugPrint('User ID: $userId');
    debugPrint('Check-In Time: $checkInTime');
    debugPrint('Current Nepali Time: $currentTimeNepali');
    debugPrint('Time Difference: ${timeDifference.inMinutes} minutes');

    // Check if the tutorial has been shown
    bool hasSeenTutorial = prefs.getBool('hasSeenTutorial') ?? false;

    // Only show the tutorial if the time difference is within 5 minutes and it hasn't been shown before
    if (!hasSeenTutorial && timeDifference.inMinutes <= 1) {
      _createTutorial();

      // Update the flag so the tutorial won't be shown again
      await prefs.setBool('hasSeenTutorial', true);
      debugPrint('Tutorial displayed.');
    } else {
      debugPrint('Conditions not met for showing tutorial.');
    }
  } catch (e) {
    debugPrint('Error during tutorial initialization: $e');
  }
}
Future<void> trackUserCount(int userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Load the existing set of user IDs (or initialize an empty set if it doesn't exist)
  List<String>? userIdList = prefs.getStringList('unique_user_ids');
  Set<String> userIds = userIdList?.toSet() ?? {};

  // Add the current user ID
  userIds.add(userId.toString());

  // Save the updated set back to SharedPreferences
  await prefs.setStringList('unique_user_ids', userIds.toList());

  // Print the current unique user count
  print('Unique user count: ${userIds.length}');
}

Future<int> getUniqueUserCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? userIdList = prefs.getStringList('unique_user_ids');
  return userIdList?.length ?? 0;
}
 Future<void> _createTutorial() async {
    final targets = [
      TargetFocus(
        identify: 'historyKey',
        keyTarget: _historyKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomCenter,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => Text(
              'This is History page where you can check your loan approval records.',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      
      TargetFocus(
        identify: 'viewRecord',
        keyTarget: _viewRecordKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomCenter,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => Text(
              'You can view your records and approved loan amount.',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'recordList',
        keyTarget: _recordListKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomCenter,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => Text(
              'You can view the list of loan approvals and rejections.',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'feedback',
        keyTarget: _feedBackKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomCenter,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => Text(
              'This is Feedback Button, where you give ratings of the app.',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    
    ]
    
    ;

    final tutorial = TutorialCoachMark(targets: targets);

    Future.delayed(const Duration(milliseconds: 500), () {
      tutorial.show(context: context);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: KeyedSubtree(
    key: _historyKey,  // Use the GlobalKey here
    child: Text(
      'History',
      style: TextStyle(color: Colors.white),
    ),
  ),
    
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              // colors: [Color(0xFF13136A), Color(0xff281537),], 
              colors: [Color(0xFF13136A), Color(0xFF5C6BC0)], 
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : LayoutBuilder(
        builder: (context, constraints) {
          final isPortrait =
              MediaQuery.of(context).orientation == Orientation.portrait;

          return isPortrait
              ? Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 80.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Container(key: _viewRecordKey,
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
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            loanHistory.isEmpty
                                ? Center(key: _recordListKey,
                                    child: Text(
                                      'No loan history found.',
                                      style: TextStyle(
                                          fontSize: 16.0, color: Colors.grey),
                                    ),
                                  )
                                : ListView.builder(key: _recordListKey,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: loanHistory.length,
                                    itemBuilder: (context, index) {
                                      final record = loanHistory[index];
                                      return Card(
                                        child: ListTile(
                                          leading: const Icon(
                                              Icons.account_balance_wallet,
                                              color: Colors.green),
                                          title: Text(
                                              'Loan Amount: Rs ${record['loan_amount']}'),
                                          subtitle: Text.rich(
                                            TextSpan(
                                              children: [
                                                const TextSpan(
                                                  text: 'Status: ',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                                TextSpan(
                                                  text: record['status']
                                                      ? 'Approved'
                                                      : 'Rejected',
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
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16.0,
                      left: 16.0,
                      right: 16.0,
                      child: FeedbackButton( key:_feedBackKey,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FeedbackScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Padding(
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
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        loanHistory.isEmpty
                            ? const Center(
                                child: Text(
                                  'No loan history found.',
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: loanHistory.length,
                                itemBuilder: (context, index) {
                                  final record = loanHistory[index];
                                  return Card(
                                    child: ListTile(
                                      leading: const Icon(
                                          Icons.account_balance_wallet,
                                          color: Colors.green),
                                      title: Text(
                                          'Loan Amount: Rs ${record['loan_amount']}'),
                                      subtitle: Text.rich(
                                        TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Status: ',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            TextSpan(
                                              text: record['status']
                                                  ? 'Approved'
                                                  : 'Rejected',
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
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                        const SizedBox(height: 20),
                        FeedbackButton(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FeedbackScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
        },
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
