import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:guardian_key/src/repository/user_repository.dart';
import 'package:guardian_key/src/services/encryption_service.dart';


class MasterPasswordController extends GetxController {
  RxString _masterPassword = ''.obs;
  RxInt charactersLeft = (32).obs;

  bool hasPromptedForMasterPassword = false;
  RxBool isMasterPasswordVerified = false.obs;


  String get masterPassword => _masterPassword.value;
  set masterPassword(String value) => _masterPassword.value = value;

  OverlayEntry? _overlayEntry;

  final EncryptionService _encryptionService = EncryptionService();
  final UserRepository _userRepo = UserRepository.instance;

  Future<String?> promptForMasterPassword(BuildContext context) async {
    return await showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        TextEditingController passwordController = TextEditingController();
        bool isObscureText = true;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Set Master Passwords for your all passwords.'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
            children: [
              const Text(
                'Keep your Master Password safe with you.\n\n'
                'This password will be used to unlock your encrypted passwords.'
              ),
              SizedBox(height: 10),TextField(
                  controller: passwordController,
                  maxLength: 32,
                  obscureText: isObscureText,
                  decoration: InputDecoration(
                    hintText: 'Enter master password',
                    counterText: '${charactersLeft.value} characters left',
                    suffixIcon: IconButton(
                      icon: Icon(
                        isObscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isObscureText = !isObscureText;
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      charactersLeft.value = 32 - value.length;
                    });
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  masterPassword = passwordController.text;
                  Navigator.of(context).pop(passwordController.text);
                },
              ),
            ],
          );
        });
      },
    );
  }

  Future<String?> promptForMasterPasswordVerification(BuildContext context) async {
    return await showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        TextEditingController passwordController = TextEditingController();
        bool isObscureText = true;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Enter Master Password for verification'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Master Password will be used for encryption and decryption'),
                SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  maxLength: 32,
                  obscureText: isObscureText,
                  decoration: InputDecoration(
                    hintText: 'Enter master password',
                    counterText: '${charactersLeft.value} characters left',
                    suffixIcon: IconButton(
                      icon: Icon(
                        isObscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isObscureText = !isObscureText;
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      charactersLeft.value = 32 - value.length;
                    });
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  masterPassword = passwordController.text;
                  Navigator.of(context).pop(passwordController.text);
                },
              ),
            ],
          );
        });
      },
    );
  }


  Future<void> saveHashedMasterPassword(String masterPassword) async {
    // print('Hashing and saving master password...');
    // Hash the master password using the function from EncryptionService
    String hashedPassword = _encryptionService.hashPassword(masterPassword);
    // print('Master password hashed: $hashedPassword');

    // Save the hashed master password using UserRepository
    try {
      await _userRepo.saveMasterPasswordHash(hashedPassword);
      // print('Hashed master password saved successfully.');
    } catch (e) {
      print('Error saving hashed master password: $e');
    }
  }

  Future<String?> fetchMasterPasswordHash() async {
    try {
      return await _userRepo.getMasterPasswordHash();
    } catch (e) {
      print("Error fetching master password hash: $e");
      return null;
    }
  }
  
  Future<void> ensureMasterPasswordIsSet() async {
    if (!shouldPromptForMasterPassword()) {
      return;
    }

    hasPromptedForMasterPassword = true; // Update the flag

    String? storedMasterPasswordHash = await fetchMasterPasswordHash();

    // If no stored hash, prompt for master password setup
    if (storedMasterPasswordHash == null || storedMasterPasswordHash.isEmpty) {
      await handleInitialMasterPasswordSetup();
      return;
    }

    // If there's a stored hash, verify against it
    await verifyAgainstStoredHash(storedMasterPasswordHash);
  }

  bool shouldPromptForMasterPassword() {
    print("ensureMasterPasswordIsSet called");

    if (isMasterPasswordVerified.value || hasPromptedForMasterPassword) {
      print("Master password already verified or has been prompted");
      return false;
    }
    return true;
  }

  Future<void> handleInitialMasterPasswordSetup() async {
    print("No stored master password hash found. Prompting user to set master password.");
    final masterPassword = await promptForMasterPassword(Get.context!);
    if (masterPassword != null && masterPassword.isNotEmpty) {
      await saveHashedMasterPassword(masterPassword);
    }
  }

  Future<void> verifyAgainstStoredHash(String storedMasterPasswordHash) async {
    print("Stored master password hash found. Prompting user for verification.");
    final masterPassword = await promptForMasterPasswordVerification(Get.context!);
    if (masterPassword == null || masterPassword.isEmpty) {
      return;
    }

    // Mark the master password as verified for this session
    isMasterPasswordVerified.value = true;

    // Hash the entered password
    String enteredHashedPassword = _encryptionService.hashPassword(masterPassword);

    // Check against stored hash
    if (enteredHashedPassword != storedMasterPasswordHash) {
      // Incorrect master password
      handleIncorrectMasterPassword();
    } else {
      // Correct master password
      handleCorrectMasterPassword();
    }
  }

  Future<void> handleIncorrectMasterPassword() async {
    Get.snackbar("Error", "Incorrect master password", duration: Duration(seconds: 3));
    _showOverlay(Get.overlayContext!);
    await Future.delayed(Duration(seconds: 3));
    _removeOverlay();
    SystemNavigator.pop();
  }

  Future<void> handleCorrectMasterPassword() async {
    final userRepository = Get.find<UserRepository>();
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentUserEmail == null || currentUserEmail.isEmpty) {
      throw Exception('No user email found.');
    }

    var user = await userRepository.getUserDetails(currentUserEmail);
    Get.snackbar("Welcome", "${user.firstName}!", duration: Duration(seconds: 3));
  }

  void _showOverlay(BuildContext context) {
  _overlayEntry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: GestureDetector(
        onTap: () {}, // This empty onTap handler effectively "absorbs" the tap
        child: Container(
          color: Colors.transparent, // This could also be a semi-transparent color to darken the background
        ),
      ),
    ),
  );

  Overlay.of(context).insert(_overlayEntry!);
}

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

}

