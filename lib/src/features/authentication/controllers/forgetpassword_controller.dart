import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordController extends GetxController {
  final _firebaseAuth = FirebaseAuth.instance;

  Future<void> sendResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      
      // Display a custom dialog
      _showCustomDialog();

    } catch (e) {
      // Display an error message
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showCustomDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text('Password Reset'),
        content: Text('Password reset email has been sent to your email address.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      ),
    );
  }
}
