import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordConfigScreen extends StatefulWidget {
  @override
  _PasswordConfigScreenState createState() => _PasswordConfigScreenState();
}

class _PasswordConfigScreenState extends State<PasswordConfigScreen> {
  double _passwordLength = 8;
  double _numUpperCase = 1;  
  double _numLowerCase = 1;  
  double _numSpecialChars = 1; 

  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _passwordLength = prefs.getDouble('${userId}_passwordLength') ?? 8;
      _numUpperCase = prefs.getDouble('${userId}_numUpperCase') ?? 1;
      _numLowerCase = prefs.getDouble('${userId}_numLowerCase') ?? 1;
      _numSpecialChars = prefs.getDouble('${userId}_numSpecialChars') ?? 1;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('${userId}_passwordLength', _passwordLength);
    await prefs.setDouble('${userId}_numUpperCase', _numUpperCase);
    await prefs.setDouble('${userId}_numLowerCase', _numLowerCase);
    await prefs.setDouble('${userId}_numSpecialChars', _numSpecialChars);
    // Show a snackbar on the previous screen (ProfileScreen) after navigating back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password configuration saved!'),
        duration: Duration(seconds: 3),
      ),
    );

    // Navigate back to the ProfileScreen
    Navigator.pop(context);
  }
  

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Configuration'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveSettings,  // Save settings when the save icon is clicked
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Password Length Slider
            Text('Password Length: ${_passwordLength.toInt()}'),
            Slider(
              value: _passwordLength,
              onChanged: (value) {
                setState(() {
                  _passwordLength = value;
                });
              },
              min: 8,
              max: 16,
              divisions: 8,
              label: _passwordLength.toInt().toString(),
            ),
            _buildSliderSetting(
              title: 'Number of Upper Case Characters',
              value: _numUpperCase,
              onChanged: (value) => setState(() => _numUpperCase = value),
            ),
            _buildSliderSetting(
              title: 'Number of Lower Case Characters',
              value: _numLowerCase,
              onChanged: (value) => setState(() => _numLowerCase = value),
            ),
            _buildSliderSetting(
              title: 'Number of Special Characters',
              value: _numSpecialChars,
              onChanged: (value) => setState(() => _numSpecialChars = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSetting({required String title, required double value, required ValueChanged<double> onChanged}) {
    return Column(
      children: [
        Text('$title: ${value.toInt()}'),
        Slider(
          value: value,
          onChanged: onChanged,
          min: 1,
          max: 6,
          divisions: 5,
          label: value.toInt().toString(),
        ),
      ],
    );
  }
}

