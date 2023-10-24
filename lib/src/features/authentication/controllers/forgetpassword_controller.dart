import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordController extends GetxController {
  final _firebaseAuth = FirebaseAuth.instance;

  Future<void> sendResetEmail(String email) async {
    try {
      // Fetch sign-in methods for the given email
      List<String> signInMethods = await _firebaseAuth.fetchSignInMethodsForEmail(email);

      // If the list is empty, it means the user is not registered
      if (signInMethods.isEmpty) {
        Get.snackbar('Error', 'User not found', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // If the user is registered, proceed with sending the password reset email
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _showCustomDialog();

    } catch (e) {
      print(e);
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
