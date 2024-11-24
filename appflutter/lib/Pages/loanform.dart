import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import the SharedPreferences package
import 'homepage.dart';


class LoanApplication {
  final String citizenshipNo;
  final String state;
  final String street;
  final String zipCode;
  final String education;
  final String selfEmployed;
  final double loanAmount;
  final int loanTerm;
  final int noOfDependents;
  final int cibilScore;
  final double annualIncome;
  final double residentialAsset;
  final double commercialAsset;
  final double luxuryAsset;
  final double bankAsset;

  LoanApplication({
    required this.citizenshipNo,
    required this.state,
    required this.street,
    required this.zipCode,
    required this.education,
    required this.selfEmployed,
    required this.loanAmount,
    required this.loanTerm,
    required this.noOfDependents,
    required this.cibilScore,
    required this.annualIncome,
    required this.residentialAsset,
    required this.commercialAsset,
    required this.luxuryAsset,
    required this.bankAsset,
  });

  // Converts the LoanApplication instance to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      "citizenship_no": citizenshipNo,
      "state": state,
      "street": street,
      "zip_code": zipCode,
      "education": education,
      "self_employed": selfEmployed,
      "loan_amount": loanAmount,
      "loan_term": loanTerm,
      "no_of_dependents": noOfDependents,
      "credit_score": cibilScore,
      "income_annum": annualIncome,
      "residential_assets_value": residentialAsset,
      "commercial_assets_value": commercialAsset,
      "luxury_assets_value": luxuryAsset,
      "bank_asset_value": bankAsset,
    };
  }

  // Converts the map to JSON format
  String toJsonString() => jsonEncode(toJson());
}

class LoanForm extends StatefulWidget {
  @override
  _LoanFormState createState() => _LoanFormState();
}

class _LoanFormState extends State<LoanForm> {
  int _activeStepIndex = 0;

  // Controllers for Step 1: Personal Info
 
  TextEditingController citizenshipNo = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController street = TextEditingController();
  TextEditingController zip = TextEditingController();

  // Controllers for Step 2: Apply For Loan
  bool isGraduate = false;
  bool selfEmployed = false;
  TextEditingController loanAmount = TextEditingController();
  TextEditingController loanTerm = TextEditingController();
  TextEditingController dependents = TextEditingController();
  TextEditingController creditScore = TextEditingController();

  // Controllers for Step 3: Asset Information
  TextEditingController annualIncome = TextEditingController();
  TextEditingController residentialAsset = TextEditingController();
  TextEditingController luxuryAsset = TextEditingController();
  TextEditingController bankAsset = TextEditingController();
  TextEditingController commercialAsset = TextEditingController();

  List<Step> stepList() => [
        Step(
          state: _activeStepIndex <= 0 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 0,
          title: Text(
                      'Personal Info',
                      style: TextStyle(color: Colors.black), 
                    ),
          content: _buildGeneralInformationPage(),
        ),
        Step(
          state: _activeStepIndex <= 1 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 1,
          title: Text(
                      'Apply For Loan',
                      style: TextStyle(color: Colors.black), 
                    ),
          content: _buildLoanApplicationPage(),
        ),
        Step(
          state: _activeStepIndex <= 2 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 2,
         title: Text(
                      'Asset Information',
                      style: TextStyle(color: Colors.black), 
                    ),
          content: _buildAssetInformationPage(),
        ),
      ];

  void _onStepContinue() {
    if (_activeStepIndex < (stepList().length - 1)) {
      setState(() {
        _activeStepIndex += 1;
      });
    } else {
      _submitForm();
    }
  }

  void _onStepCancel() {
    if (_activeStepIndex == 0) {
      return;
    }
    setState(() {
      _activeStepIndex -= 1;
    });
  }

Future<void> _submitForm() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('access_token');

  final url = 'http://10.0.2.2:8000/api/loan-prediction/';

  // Create LoanApplication instance with data from controllers
  final application = LoanApplication(
    citizenshipNo: citizenshipNo.text,
    state: state.text,
    street: street.text,
    zipCode: zip.text,
    education: isGraduate ? 'Graduate' : 'Not Graduate',
    selfEmployed: selfEmployed ? 'Yes' : 'No',
    loanAmount: double.tryParse(loanAmount.text) ?? 0,
    loanTerm: int.tryParse(loanTerm.text) ?? 0,
    noOfDependents: int.tryParse(dependents.text) ?? 0,
    cibilScore: int.tryParse(creditScore.text) ?? 0,
    annualIncome: double.tryParse(annualIncome.text) ?? 0,
    residentialAsset: double.tryParse(residentialAsset.text) ?? 0,
    commercialAsset: double.tryParse(commercialAsset.text) ?? 0,
    luxuryAsset: double.tryParse(luxuryAsset.text) ?? 0,
    bankAsset: double.tryParse(bankAsset.text) ?? 0,
  );

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: application.toJsonString(),
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    _showDialog('Success', responseData['prediction']);
  } else {
    try {
      final responseData = json.decode(response.body);
      _showDialog('Error', responseData['message'] ?? 'An error occurred.');
    } catch (e) {
      _showDialog('Error', 'An error occurred: ${response.statusCode}');
    }
  }
}



  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => HomePage()),
                                  );
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return SafeArea(
      child: Scaffold(
    appBar: AppBar(
      title: Text(
        'Loan Application Form',
        style: TextStyle(color: Colors.white),
        
      ),
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
      ),
    ),
    body: Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: Color(0xFF13136A), // Primary color for AppBar and buttons
          onPrimary: Colors.white, // Text color for primary elements
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFF13136A), // Button background color
        ),
      ),
      child: Stepper(
        type: StepperType.vertical,
        currentStep: _activeStepIndex,
        steps: stepList(),
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        onStepTapped: (int index) {
          setState(() {
            _activeStepIndex = index;
          });
        },
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          final isLastStep = _activeStepIndex == stepList().length - 1;
          return Row(
            children: [
              if (_activeStepIndex > 0)
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 183, 183, 183),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(color: Colors.black), // Text color
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 30, 250, 49),
                  ),
                  child: Text(
                    isLastStep ? 'Submit' : 'Next',
                    style: TextStyle(color: Colors.black), // Text color
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  ));
}




  Widget _buildGeneralInformationPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
           
            _buildTextField(controller: citizenshipNo, label: 'Citizenship Number'),
            _buildTextField(controller: country, label: 'Country'),
            _buildTextField(controller: state, label: 'State'),
            _buildTextField(controller: street, label: 'Street Address'),
            _buildTextField(controller: zip, label: 'Zip Code', keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanApplicationPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            _buildTextField(controller: loanAmount, label: 'Loan Amount', keyboardType: TextInputType.number),
            _buildTextField(controller: loanTerm, label: 'Loan Term', keyboardType: TextInputType.number),
            _buildTextField(controller: creditScore, label: 'Credit Score', keyboardType: TextInputType.number),
            _buildTextField(controller: dependents, label: 'Number of Dependents', keyboardType: TextInputType.number),
            SwitchListTile(
              title: Text('Graduate'),
              value: isGraduate,
              onChanged: (value) {
                setState(() {
                  isGraduate = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Self Employed'),
              value: selfEmployed,
              onChanged: (value) {
                setState(() {
                  selfEmployed = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetInformationPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            _buildTextField(controller: annualIncome, label: 'Annual Income', keyboardType: TextInputType.number),
            _buildTextField(controller: residentialAsset, label: 'Residential Asset'),
            _buildTextField(controller: luxuryAsset, label: 'Luxury Asset'),
            _buildTextField(controller: bankAsset, label: 'Bank Asset'),
            _buildTextField(controller: commercialAsset, label: 'Commercial Asset'),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF13136A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF13136A), width: 2.0),
          ),
        ),
      ),
    );
  }
}
