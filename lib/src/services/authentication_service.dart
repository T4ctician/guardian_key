import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  final LocalAuthentication _localauth = LocalAuthentication();

  Future<bool> hasBiometrics() async {
    return await _localauth.canCheckBiometrics;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _localauth.getAvailableBiometrics();
  }

  Future<bool> authenticateWithBiometrics() async {
      bool isBiometricSupported = await _localauth.isDeviceSupported();
      bool canCheckBiometrics = await _localauth.canCheckBiometrics;

      bool isAuthenticated = false;

      if (isBiometricSupported && canCheckBiometrics) {
        isAuthenticated = await _localauth.authenticate(
          localizedReason: 'Please complete the biometrics to proceed.',
        );
      }

      return isAuthenticated;
  }

Future<bool> enableBiometricAuth(String userId) async {
    final bool canAuthenticate = await _localauth.canCheckBiometrics;
    if (canAuthenticate) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometricAuthEnabled_$userId', true);
      return true;
    } else {
      return false; // Cannot enable biometric authentication
    }
}

  Future<bool> disableBiometricAuth(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricAuthEnabled_$userId', false); 
    return true;
}

  Future<bool> isBiometricAuthEnabled(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometricAuthEnabled_$userId') ?? false;
}
}
