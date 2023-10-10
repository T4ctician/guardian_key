import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/screens/homepage.dart';
import 'package:guardian_key/src/features/authentication/screens/welcome_screen.dart';

import 'exceptions/t_exceptions.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  late final Rx<User?> _firebaseUser;

  /// QUICK links to get frequently used values in other classes.
  User? get firebaseUser => _firebaseUser.value;
  String get getUserID => _firebaseUser.value?.uid ?? "";
  String get getUserEmail => _firebaseUser.value?.email ?? "";

  /// When App launch, this func called.
  /// It set the firebaseUser state & remove the Splash Screen
  @override
  void onReady() {
    _firebaseUser = Rx<User?>(_auth.currentUser);
    _firebaseUser.bindStream(_auth.userChanges());
    ever(_firebaseUser, _setInitialScreen);
  }

  /// Setting initial screen onLOAD (optional)
  _setInitialScreen(User? user) async {
    user == null
        ? Get.offAll(() => const WelcomeScreen())
        : Get.offAll(() => const HomePage());
  }

  /// [EmailAuthentication] - LOGIN
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      final result = TExceptions.fromCode(e.code); // Throw custom [message] variable
      throw result.message;
    } catch (_) {
      const result = TExceptions();
      throw result.message;
    }
  }

  /// [EmailAuthentication] - REGISTER
  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      firebaseUser != null ? Get.offAll(() => const HomePage()) : Get.to(() => const WelcomeScreen());
    } on FirebaseAuthException catch (e) {
      final ex = TExceptions.fromCode(e.code);
      throw ex.message;
    } catch (_) {
      const ex = TExceptions();
      throw ex.message;
    }
  }

  /// LOGOUT USER - Valid for all authentication methods.
  Future<void> logout() async {
    await _auth.signOut();
  }
}

