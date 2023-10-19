import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:guardian_key/src/features/authentication/controllers/login_controller.dart';
import 'package:guardian_key/src/features/authentication/screens/widgets/forget_password.dart';
import '../../../../constants/sizes.dart';
import '../../../../constants/text_strings.dart';

class LoginFormWidget extends StatelessWidget {
  const LoginFormWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final formKey = GlobalKey<FormState>();

    return Form(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: tFormHeight - 10),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                validator: (value) {
                  if (value == '' || value == null) {
                    return "Please enter your Email";
                  } else if (!GetUtils.isEmail(value)) {
                    return "Invalid Email Address";
                  } else {
                    return null;
                  }
                },
                controller: controller.email,
                decoration: const InputDecoration(prefixIcon: Icon(LineAwesomeIcons.user), labelText: tEmail, hintText: tEmail),
              ),
              const SizedBox(height: tFormHeight - 20),
            Obx(
                () => TextFormField(
                  obscureText: controller.obscureText.value, // This is reactive now// use RxBool to determine whether the text should be obscured or not
                controller: controller.password,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter your Password";
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.fingerprint),
                  labelText: tPassword,
                  hintText: tPassword,
                  suffixIcon: IconButton( // Changed to IconButton to add functionality
                    icon: Obx(() => 
                      Icon(controller.obscureText.value // Choose the icon based on the obscureText value
                        ? LineAwesomeIcons.eye_slash 
                        : LineAwesomeIcons.eye)
                    ),
                    onPressed: () => controller.togglePasswordVisibility(), // Toggle password visibility when tapped
                  ),
                ),
              ),
            ),
            Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Get.to(() => ForgotPasswordScreen()); // Navigate to the ForgetPasswordScreen when clicked
                  },
                  child: Text("Forget Password", style: TextStyle(color: Colors.blue)),
                ),
              ),
              const SizedBox(height: tFormHeight - 20),

              /// -- LOGIN BTN
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? () {}
                        : () {
                            if (formKey.currentState!.validate()) {
                              LoginController.instance
                                  .loginUser(controller.email.text.trim(), controller.password.text.trim());
                            }
                          },
                    child: controller.isLoading.value
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text("Loading...")
                            ],
                          )
                        : Text(tLogin.toUpperCase()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
