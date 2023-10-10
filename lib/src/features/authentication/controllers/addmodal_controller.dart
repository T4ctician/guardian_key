import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/models/login_model.dart';
import 'package:guardian_key/src/repository/login_repository.dart';

class AddModalController extends GetxController {
  static AddModalController get instance => Get.find();

  /// Repositories
  final _loginRepo = LoginRepository.instance;

  @override
  void onClose() {
    super.onClose(); // Call super to ensure proper cleanup
  }

  /// Add a new login
  Future<void> addLogin(LoginModel login) async {
    try {
      await _loginRepo.createLogin(login);
      Get.snackbar("Success", "Login added successfully!",
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    }
  }

  /// Update a login
  Future<void> updateLogin(LoginModel login) async {
    try {
      await _loginRepo.updateLoginRecord(login);
      Get.snackbar("Success", "Login updated successfully!",
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    }
  }

  /// Delete a login
  Future<void> deleteLogin(String loginId) async {
    try {
      await _loginRepo.deleteLogin(loginId);
      Get.snackbar("Success", "Login deleted successfully!",
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    }
  }

  // Fetch a login by its website name
  Future<LoginModel?> getLoginByWebsiteName(String websiteName) async {
    return await _loginRepo.getLoginByWebsiteName(websiteName);
  }
}
