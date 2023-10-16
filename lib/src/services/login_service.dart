import 'package:guardian_key/src/features/authentication/models/credential_model.dart';  // Make sure to import CredentialModel
import 'package:guardian_key/src/repository/login_repository.dart';

class LoginService {
  final _loginRepo = LoginRepository.instance;

  Future<List<CredentialModel>> fetchPasswordData() async {  // Updated to CredentialModel
    return await _loginRepo.getAllLogins();  // Ensure _loginRepo returns CredentialModel
  }
  
  Future<List<String>> fetchWebsiteList() async {
    try {
      // Fetch your password data from the data source
      final List<CredentialModel> data = await fetchPasswordData();  // Updated to CredentialModel

      // Extract website names from the password data
      final List<String> websiteNames = data.map((p) => p.websiteName).toList();

      return websiteNames;
    } catch (e) {
      // Handle any errors here
      print('Error fetching website list: $e');
      return []; // Return an empty list or handle the error as needed
    }
  }

  Future<CredentialModel> getPasswordByWebsiteName(String websiteName) async {  // Updated to CredentialModel
    try {
      final List<CredentialModel> data = await fetchPasswordData();  // Updated to CredentialModel
      
      // Find the password with the matching website name
      final selectedPassword = data.firstWhere(
        (password) => password.websiteName == websiteName,
        orElse: () => CredentialModel(  // Updated to CredentialModel
          websiteName: '',
          userID: '',
          email: '',
          password: '',
        ), // Return an empty CredentialModel object if no matching password is found
      );

      return selectedPassword;
    } catch (e) {
      // Handle any errors here
      print('Error fetching password by website name: $e');
      return CredentialModel(  // Updated to CredentialModel
        websiteName: '',
        userID: '',
        email: '',
        password: '',
      ); // Return an empty CredentialModel object in case of an error
    }
  }

  // Inside the LoginService class
  Stream<List<CredentialModel>> listenToAllLogins() {
    return _loginRepo.listenToAllLogins();
  }

  
}
