import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:guardian_key/src/repository/authentication_repository.dart';
import 'package:guardian_key/src/repository/user_repository.dart';


class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  /// TextField Controllers to get data from TextFields
  final email = TextEditingController();
  final password = TextEditingController();

  var obscureText = true.obs; // Password will be obscured initially.

  /// Loader
  final isLoading = false.obs;

  // Function to toggle the visibility
  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  /// Call this Function from Design & it will perform the LOGIN Op.
  Future<void> loginUser(String email, String password) async {
    try {
      isLoading.value = true;
      await AuthenticationRepository.instance.loginWithEmailAndPassword(email, password);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 5));
    }
  }

}
