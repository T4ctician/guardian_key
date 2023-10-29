import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/controllers/masterpassword_controller.dart';
import 'package:guardian_key/src/features/authentication/models/credential_model.dart';
import 'package:guardian_key/src/repository/login_repository.dart';

class AddCredentialController extends GetxController {
  static AddCredentialController get instance => Get.find();

  /// Repositories
  final _loginRepo = LoginRepository.instance;

    String get masterPassword {
    final masterPasswordController = Get.find<MasterPasswordController>();
    return masterPasswordController.masterPassword ?? '';  // if null, return an empty string
  }

  /// Add a new login
  Future<void> addLogin(CredentialModel login) async {
    try {
      await _loginRepo.createLogin(login, masterPassword);
      Get.snackbar("Success", "Login added successfully!",
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    }
  }

  /// Update a login
  Future<void> updateLogin(CredentialModel login) async {
    try {
      await _loginRepo.updateLoginRecord(login, masterPassword);
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
  Future<CredentialModel?> getLoginByWebsiteName(String websiteName) async {
    return await _loginRepo.getLoginByWebsiteName(websiteName, masterPassword);
  }
}
