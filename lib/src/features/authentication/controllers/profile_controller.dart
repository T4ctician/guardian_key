import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:guardian_key/src/features/authentication/models/user_model.dart';
import 'package:guardian_key/src/features/authentication/models/login_model.dart'; 
import 'package:guardian_key/src/repository/authentication_repository.dart';
import 'package:guardian_key/src/repository/login_repository.dart';
import 'package:guardian_key/src/repository/user_repository.dart';



class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  /// Repositories
  final _authRepo = AuthenticationRepository.instance;
  final _userRepo = UserRepository.instance;

  /// Get User Email and pass to UserRepository to fetch user record.
  getUserData() {
    try {
      final currentUserEmail = _authRepo.getUserEmail;
      if (currentUserEmail.isEmpty) {
        Get.snackbar("Error", "No user found!",
            snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
        return;
      } else {
        return _userRepo.getUserDetails(currentUserEmail);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    }
  }

  /// Fetch List of user records.
  Future<List<UserModel>> getAllUsers() async => await _userRepo.allUsers();

  /// Update User Data
Future<void> updateRecord(UserModel user) async {
  try {
    // Get the current user
    User? currentUser = _authRepo.getCurrentUser();

    // Ensure the user is not null
    if (currentUser == null) {
      Get.snackbar("Error", "No user currently logged in.");
      return;
    }

    // Create a controller for the password input
    TextEditingController passwordController = TextEditingController();

    // Show a dialog to get the password from the user
    await showDialog(
      context: Get.context!,  // assuming you have GetX setup
      builder: (context) => AlertDialog(
        title: Text('Password Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please enter your password to confirm profile update.'),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Confirm'),
            onPressed: () => Navigator.of(context).pop(passwordController.text),
          ),
        ],
      ),
    );

    String password = passwordController.text;

    // Re-authenticate the user
    AuthCredential credential = EmailAuthProvider.credential(email: currentUser.email!, password: password);
    await currentUser.reauthenticateWithCredential(credential);

    // Update user record in Firestore
    await _userRepo.updateUserRecord(user);
    
    Get.snackbar("Success", "Profile has been saved.");

  } catch (e) {
    Get.snackbar("Error", "Wrong Password");
  }
}


Future<void> deleteUser() async {
  String uID = _authRepo.getUserID;

  if (uID.isEmpty) {
    Get.snackbar("Error", "User cannot be deleted.");
    return;
  }

  try {
    // Get the current user
    User? currentUser = _authRepo.getCurrentUser();

    // Ensure the user is not null
    if (currentUser == null) {
      Get.snackbar("Error", "No user currently logged in.");
      return;
    }

    // Create a controller for the password input
    TextEditingController passwordController = TextEditingController();

    // Show a dialog to get the password from the user
    await showDialog(
      context: Get.context!,  // assuming you have GetX setup
      builder: (context) => AlertDialog(
        title: Text('Password Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please enter your password to confirm user deletion.'),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Confirm'),
            onPressed: () => Navigator.of(context).pop(passwordController.text),
          ),
        ],
      ),
    );

    String password = passwordController.text;

    // Re-authenticate the user
    AuthCredential credential = EmailAuthProvider.credential(email: currentUser.email!, password: password);
    await currentUser.reauthenticateWithCredential(credential);

    // Delete all login records associated with the user
    List<LoginModel> allLogins = await LoginRepository.instance.getAllLogins();
    for (LoginModel login in allLogins) {
      await LoginRepository.instance.deleteLogin(login.id!);
    }

    // Delete the user from Firestore
    await _userRepo.deleteUser(uID);
    
    // Delete the user from Firebase Authentication
    await currentUser.delete();

    Get.snackbar("Success", "Account and all associated data have been deleted.");
    
    // Redirect or perform any other action
    AuthenticationRepository.instance.logout();

  } catch (e) {
    Get.snackbar("Error", "Error while deleting user. Please try again later.");
  }
}



}
