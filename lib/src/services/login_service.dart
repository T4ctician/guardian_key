import 'package:guardian_key/src/features/authentication/models/login_model.dart';  // Make sure to import LoginModel
import 'package:guardian_key/src/repository/login_repository.dart';

class LoginService {
  final _loginRepo = LoginRepository.instance;

  Future<List<LoginModel>> fetchPasswordData() async {  // Updated to LoginModel
    return await _loginRepo.getAllLogins();  // Ensure _loginRepo returns LoginModel
  }
  
  Future<List<String>> fetchWebsiteList() async {
    try {
      // Fetch your password data from the data source
      final List<LoginModel> data = await fetchPasswordData();  // Updated to LoginModel

      // Extract website names from the password data
      final List<String> websiteNames = data.map((p) => p.websiteName).toList();

      return websiteNames;
    } catch (e) {
      // Handle any errors here
      print('Error fetching website list: $e');
      return []; // Return an empty list or handle the error as needed
    }
  }

  Future<LoginModel> getPasswordByWebsiteName(String websiteName) async {  // Updated to LoginModel
    try {
      final List<LoginModel> data = await fetchPasswordData();  // Updated to LoginModel
      
      // Find the password with the matching website name
      final selectedPassword = data.firstWhere(
        (password) => password.websiteName == websiteName,
        orElse: () => LoginModel(  // Updated to LoginModel
          websiteName: '',
          userID: '',
          email: '',
          password: '',
        ), // Return an empty LoginModel object if no matching password is found
      );

      return selectedPassword;
    } catch (e) {
      // Handle any errors here
      print('Error fetching password by website name: $e');
      return LoginModel(  // Updated to LoginModel
        websiteName: '',
        userID: '',
        email: '',
        password: '',
      ); // Return an empty LoginModel object in case of an error
    }
  }

  // Inside the LoginService class
  Stream<List<LoginModel>> listenToAllLogins() {
    return _loginRepo.listenToAllLogins();
  }

  
}
