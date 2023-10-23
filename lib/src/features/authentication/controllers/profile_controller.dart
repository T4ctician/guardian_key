import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:guardian_key/src/features/authentication/models/creditcard_model.dart';
import 'package:guardian_key/src/features/authentication/models/note_model.dart';
import 'package:guardian_key/src/features/authentication/models/user_model.dart';
import 'package:guardian_key/src/features/authentication/models/credential_model.dart'; 
import 'package:guardian_key/src/repository/authentication_repository.dart';
import 'package:guardian_key/src/repository/creditcard_repository.dart';
import 'package:guardian_key/src/repository/login_repository.dart';
import 'package:guardian_key/src/repository/note_repository.dart';
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
Future<void> updateRecord(UserModel user,) async {
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
        title: const Text('Password Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your password to confirm profile update.'),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Confirm'),
            onPressed: () => Navigator.of(context).pop(passwordController.text),
          ),
        ],
      ),
    );

    String password = passwordController.text;

    // Re-authenticate the user
    AuthCredential credential = EmailAuthProvider.credential(email: currentUser.email!, password: password);
    await currentUser.reauthenticateWithCredential(credential);

            if (currentUser != null) {
              if (currentUser.email != user.email.trim()) {
                try {
                  await currentUser.updateEmail(user.email.trim());
                } catch (e) {
                  print("Error updating email: $e");
                  // Handle errors: e.g. show a dialog with the error
                }
              }

              if (user.password.trim().isNotEmpty) {
                try {
                  await currentUser.updatePassword(user.password.trim());
                } catch (e) {
                  print("Error updating password: $e");
                  // Handle errors: e.g. show a dialog with the error
                }
              }
            }
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
        title: const Text('Password Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your password to confirm user deletion.'),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Confirm'),
            onPressed: () => Navigator.of(context).pop(passwordController.text),
          ),
        ],
      ),
    );

    String password = passwordController.text;

    
    // Re-authenticate the user
        // Define a list of repositories for each subcollection
    List<GetxController> subcollections = [
      LoginRepository.instance,
      CreditCardRepository.instance,
      NoteRepository.instance
    ];

    // Iterate over each repository and call the delete methods
    for (var repo in subcollections) {
      if (repo is LoginRepository) {
        List<CredentialModel> allLogins = await repo.getAllLogins();
        for (CredentialModel login in allLogins) {
          await repo.deleteLogin(login.id!);
        }
      } else if (repo is CreditCardRepository) {
        List<CreditCardModel> allCreditCards = await repo.getAllCreditCards();
        for (CreditCardModel card in allCreditCards) {
          await repo.deleteCreditCard(card.id!);
        }
      } else if (repo is NoteRepository) {
        List<NoteModel> allNotes = await repo.getAllNotes();
        for (NoteModel note in allNotes) {
          await repo.deleteNote(note.id!);
        }
      }
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
