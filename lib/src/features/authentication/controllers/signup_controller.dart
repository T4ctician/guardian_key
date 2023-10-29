import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/models/user_model.dart';
import 'package:guardian_key/src/features/authentication/screens/login.dart';
import 'package:guardian_key/src/repository/user_repository.dart';
import 'package:guardian_key/src/repository/authentication_repository.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  final obscureText = true.obs;
  void togglePasswordVisibility() => obscureText.value = !obscureText.value;


  //final userRepo = UserRepository.instance; //Call Get.put(UserRepo) if not define in AppBinding file (main.dart)
   final userRepo = UserRepository.instance; //Call Get.put(UserRepo) if not define in AppBinding file (main.dart)

  // TextField Controllers to get data from TextFields
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final dateOfBirth = TextEditingController(); // Instead of ''.obs
  final gender = ''.obs;

  /// Loader
  final isLoading = false.obs;

  RxBool termsAccepted = false.obs; // This will handle the state of the checkbox.

  // Define a getter for registrationSuccessful
  final RxBool _registrationSuccessful = false.obs;
  bool get registrationSuccessful => _registrationSuccessful.value;

Future<void> createUser() async {
    try {
      isLoading.value = true;
      
      // Authenticate the user with email and password
      await emailAuthentication(email.text.trim(), password.text.trim()); 
      
      // Create a new UserModel instance with all the required properties
      UserModel user = UserModel(
        email: email.text.trim(), 
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        dateOfBirth: dateOfBirth.text.trim(),
        gender: gender.value,
      );
      
      await userRepo.createUser(user); //Store Data in FireStore
      Get.snackbar("Success:", "User Created.");
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 5));
    }
}

  /// [EmailAuthentication]
  Future<void> emailAuthentication(String email, String password) async {
    try {
      await AuthenticationRepository.instance.createUserWithEmailAndPassword(email, password);
    } catch (e) {
      throw e.toString();
    }
  }

  // Add onClose() method here:
  @override
  void onClose() {
    // Dispose of the TextEditingController when the controller is closed.
    email.dispose();
    password.dispose();
    firstName.dispose();
    lastName.dispose();
    dateOfBirth.dispose(); // dispose dateOfBirth TextEditingController here
    confirmPassword.dispose();
    super.onClose(); // call super to ensure proper cleanup
  }

}
