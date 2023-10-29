import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/controllers/login_controller.dart';
import 'package:guardian_key/src/features/authentication/controllers/masterpassword_controller.dart';
import 'package:guardian_key/src/features/authentication/controllers/signup_controller.dart';
import 'package:guardian_key/src/features/authentication/controllers/profile_controller.dart';
import 'package:guardian_key/src/features/authentication/controllers/addcredential_controller.dart';
import 'package:guardian_key/src/features/authentication/controllers/addnote_controller.dart';
import 'package:guardian_key/src/features/authentication/controllers/addcreditcard_controller.dart';
import 'package:guardian_key/src/repository/note_repository.dart';
import 'package:guardian_key/src/repository/user_repository.dart';
import 'package:guardian_key/src/repository/creditcard_repository.dart';
import 'package:guardian_key/src/repository/authentication_repository.dart';
import 'package:guardian_key/src/repository/login_repository.dart';



class AppBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => AuthenticationRepository(), fenix: true);
    Get.lazyPut(() => UserRepository(), fenix: true);
    Get.lazyPut(() => LoginRepository(), fenix: true);
    Get.lazyPut(() => NoteRepository(), fenix: true);
    Get.lazyPut(() => CreditCardRepository(), fenix: true);

    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => LoginController(), fenix: true);
    Get.lazyPut(() => SignUpController(), fenix: true);
    Get.lazyPut(() => AddCredentialController(), fenix:true);
    Get.lazyPut(() => AddNoteController(), fenix:true);
    Get.lazyPut(() => CreditCardController(), fenix:true);
    Get.lazyPut(() => MasterPasswordController(), fenix:true);



  }

}