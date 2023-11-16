import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:guardian_key/src/features/authentication/controllers/masterpassword_controller.dart';
import 'package:guardian_key/src/features/authentication/models/creditcard_model.dart';
import 'package:guardian_key/src/features/authentication/models/note_model.dart';
import 'package:guardian_key/src/features/authentication/models/user_model.dart';
import 'package:guardian_key/src/features/authentication/models/credential_model.dart'; 
import 'package:guardian_key/src/repository/authentication_repository.dart';
import 'package:guardian_key/src/repository/creditcard_repository.dart';
import 'package:guardian_key/src/repository/login_repository.dart';
import 'package:guardian_key/src/repository/note_repository.dart';
import 'package:guardian_key/src/repository/user_repository.dart';
import 'package:guardian_key/src/services/authentication_service.dart';
import 'package:guardian_key/src/services/encryption_service.dart';
import 'package:shared_preferences/shared_preferences.dart';



class ProfileController extends GetxController with WidgetsBindingObserver {
  static ProfileController get instance => Get.find();

  /// Repositories
  final _authRepo = AuthenticationRepository.instance;
  final _userRepo = UserRepository.instance;
  final AuthenticationService _authenticationService = AuthenticationService();
  bool _isAuthenticating = false;
  bool _isFirstLaunch = true;
  DateTime? _lastBackgroundedTime;
  DateTime? _lastAuthenticatedTime;
  final masterPasswordController = Get.find<MasterPasswordController>();
  RxString newPassword = ''.obs;
  final _encryptionService = EncryptionService();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance?.addObserver(this);
    _getLastBackgroundedTime();
    String userId = _authRepo.getUserID;
    _authenticationService.isBiometricAuthEnabled(userId).then((isEnabled) {
      if (isEnabled) {
        _authenticateUser();
      }
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.onClose();
  }

  String get masterPassword => masterPasswordController.masterPassword;



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

      bool isPasswordObscured = true;

       // Show a dialog to get the current password from the user
    var result = await showDialog(
      barrierDismissible: false,
      context: Get.context!,  
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => AlertDialog(
            title: const Text('Password Confirmation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please enter your current password to confirm profile update.'),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: isPasswordObscured,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Current Password',
                    suffixIcon: IconButton(
                      icon: Icon(isPasswordObscured ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          isPasswordObscured = !isPasswordObscured;
                        });
                      },
                    ),
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
      },
    );
    // If the user pressed 'Cancel', throw a custom error
    if (result == null) {
      throw Exception("UserCancelledOperation");
    }

      String currentPassword = passwordController.text;

      // Re-authenticate the user with the current password
      AuthCredential credential = EmailAuthProvider.credential(email: currentUser.email!, password: currentPassword);
      await currentUser.reauthenticateWithCredential(credential);

      if (currentUser != null) {
        if (currentUser.email != user.email.trim()) {
          try {
            await currentUser.updateEmail(user.email.trim());
          } catch (e) {
            // print("Error updating email: $e");
            // Handle errors: e.g. show a dialog with the error
          }
        }

        // Retrieve the new password from the controller
        String newPasswordValue = newPassword.value; // Assuming you've declared newPassword in the controller

        if (newPasswordValue.trim().isNotEmpty) {
          try {
            await currentUser.updatePassword(newPasswordValue.trim());
          } catch (e) {
            // print("Error updating password: $e");
            // Handle errors: e.g. show a dialog with the error
          }
        }
      }

      // Update user record in Firestore
      await _userRepo.updateUserRecord(user);
      
      Get.snackbar("Success", "Profile has been saved.");

    } catch (e) {
    if (e.toString() == "Exception: UserCancelledOperation") {
      Get.snackbar("Save Profile Action:", "Cancelled");
    } else {
      Get.snackbar("Error", "Wrong Password.");
    }
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

    bool isPasswordObscured = true;

    // Show a dialog to get the password from the user
    var result = await showDialog(
      barrierDismissible: false,
      context: Get.context!,  
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => AlertDialog(
            title: const Text('Password Confirmation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please enter your password to confirm user deletion.'),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: isPasswordObscured,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(isPasswordObscured ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          isPasswordObscured = !isPasswordObscured;
                        });
                      },
                    ),
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
      },
    );
    
    // If the user pressed 'Cancel', throw a custom error
    if (result == null) {
      throw Exception("UserCancelledOperation");
    }
    String password = passwordController.text;

    if (password.isEmpty) {
      throw Exception("UserCancelledOperation");
    }
    

    // Re-authenticate the user with the given password
    AuthCredential credential = EmailAuthProvider.credential(email: currentUser.email!, password: password);

    try {
      await currentUser.reauthenticateWithCredential(credential);
    } catch (e) {
      throw Exception("WrongPassword");
    }
        // Define a list of repositories for each subcollection
    List<GetxController> subcollections = [
      LoginRepository.instance,
      CreditCardRepository.instance,
      NoteRepository.instance
    ];
    Get.snackbar("In Progress:", "Deleting.");

    // Iterate over each repository and call the delete methods
    for (var repo in subcollections) {
      if (repo is LoginRepository) {
        List<CredentialModel> allLogins = await repo.getAllLogins(masterPassword);
        for (CredentialModel login in allLogins) {
          await repo.deleteLogin(login.id!);
        }
      } else if (repo is CreditCardRepository) {
        List<CreditCardModel> allCreditCards = await repo.getAllCreditCards(masterPassword);
        for (CreditCardModel card in allCreditCards) {
          await repo.deleteCreditCard(card.id!);
        }
      } else if (repo is NoteRepository) {
        List<NoteModel> allNotes = await repo.getAllNotes(masterPassword);
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
    if (e.toString() == "Exception: UserCancelledOperation") {
      Get.snackbar("Delete User Action:", "Cancelled");
    } else if (e.toString() == "Exception: WrongPassword") {
      Get.snackbar("Error", "Wrong Password");
    } else {
      Get.snackbar("Error", "Error while deleting user: $e");
    }
  }
}

  Future<void> setAutoFill(bool isEnabled) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('autoFillEnabled', isEnabled);
  }

  Future<bool> isAutoFillEnabled() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool('autoFillEnabled') ?? false;
  }

  // Use this method when you want to enable biometric authentication
  Future<bool> enableBiometricAuth() async {
    String userId = _authRepo.getUserID;
    return await _authenticationService.enableBiometricAuth(userId);
}

  // Use this method when you want to disable biometric authentication
  Future<bool> disableBiometricAuth() async {
    String userId = _authRepo.getUserID;
    return await _authenticationService.disableBiometricAuth(userId);
}

  // Use this method when you want to check if biometric auth is enabled
  Future<bool> isBiometricAuthEnabled() async {
    String userId = _authRepo.getUserID;
    return await _authenticationService.isBiometricAuthEnabled(userId);
}

    Future<void> _getLastBackgroundedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedTimeMillis = prefs.getInt('lastBackgroundedTime');
    if (storedTimeMillis != null) {
      _lastBackgroundedTime = DateTime.fromMillisecondsSinceEpoch(storedTimeMillis);
    }
  }

  Future<void> _setLastBackgroundedTime(DateTime time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastBackgroundedTime', time.millisecondsSinceEpoch);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        // Logic for when the app is paused or inactive
        _lastBackgroundedTime = DateTime.now();
        await _setLastBackgroundedTime(_lastBackgroundedTime!);
    } else if (state == AppLifecycleState.resumed && !_isFirstLaunch) {
        // Resumed logic remains unchanged
        final currentTime = DateTime.now();

        // Fetch user's ID and pass it to isBiometricAuthEnabled
        String userId = _authRepo.getUserID;
        bool isBiometricAuthEnabled = await _authenticationService.isBiometricAuthEnabled(userId);

        if (isBiometricAuthEnabled &&
            _lastBackgroundedTime != null &&
            currentTime.difference(_lastBackgroundedTime!).inMinutes >= 5 &&
            (_lastAuthenticatedTime == null || currentTime.difference(_lastAuthenticatedTime!).inMinutes > 10) &&
            !_isAuthenticating) {
            _authenticateUser();
        }
    }
    _isFirstLaunch = false;
  }


  Future<void> _authenticateUser() async {
    _isAuthenticating = true;
    bool isAuthenticated = await _authenticationService.authenticateWithBiometrics();
    if (isAuthenticated) {
      _lastAuthenticatedTime = DateTime.now();  // Set the last authenticated time
    } else {
      // Exit the app if authentication fails
      WidgetsBinding.instance.addPostFrameCallback((_) => SystemNavigator.pop());
    }
    _isAuthenticating = false;
  }


}
