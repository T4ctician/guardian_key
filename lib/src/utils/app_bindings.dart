import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/controllers/login_controller.dart';
import 'package:guardian_key/src/features/authentication/controllers/signup_controller.dart';
import 'package:guardian_key/src/features/authentication/controllers/profile_controller.dart';
import 'package:guardian_key/src/features/authentication/controllers/addmodal_controller.dart';
import 'package:guardian_key/src/repository/user_repository.dart';
import 'package:guardian_key/src/repository/authentication_repository.dart';
import 'package:guardian_key/src/repository/login_repository.dart';


class AppBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => AuthenticationRepository(), fenix: true);
    Get.lazyPut(() => UserRepository(), fenix: true);
    Get.lazyPut(() => LoginRepository(), fenix: true);

    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => LoginController(), fenix: true);
    Get.lazyPut(() => SignUpController(), fenix: true);
    Get.lazyPut(() => AddModalController(), fenix:true);

  }

}