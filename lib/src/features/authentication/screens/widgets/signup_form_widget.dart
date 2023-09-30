import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:guardian_key/src/features/authentication/models/user_model.dart';
import '../../../../constants/sizes.dart';
import '../../../../constants/text_strings.dart';
import '../../controllers/signup_controller.dart';

class SignUpFormWidget extends StatelessWidget {
  const SignUpFormWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpController());
    final formKey = GlobalKey<FormState>();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: tFormHeight - 10),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: controller.firstName,
              decoration: const InputDecoration(
                  label: Text(tFirstName),
                  prefixIcon: Icon(LineAwesomeIcons.user)),
            ),
            const SizedBox(height: tFormHeight - 20),
            TextFormField(
              controller: controller.lastName,
              decoration: const InputDecoration(
                  label: Text(tLastName),
                  prefixIcon: Icon(LineAwesomeIcons.user)),
            ),
            const SizedBox(height: tFormHeight - 20),
            TextFormField(
              controller: controller.email,
              decoration: const InputDecoration(
                  label: Text(tEmail),
                  prefixIcon: Icon(LineAwesomeIcons.envelope)),
            ),
            const SizedBox(height: tFormHeight - 20),
            TextFormField(
              controller: controller.dateOfBirth,
              decoration: const InputDecoration(
                  label: Text(tDateOfBirth),
                  prefixIcon: Icon(LineAwesomeIcons.calendar)),
            ),
            const SizedBox(height: tFormHeight - 20),
            DropdownButtonFormField(
              items: ['Male', 'Female', 'Other']
                  .map((label) => DropdownMenuItem(
                        child: Text(label),
                        value: label,
                      ))
                  .toList(),
              onChanged: (value) => controller.gender.value = value.toString(),
              decoration: const InputDecoration(
                  label: Text(tGender),
                  prefixIcon: Icon(LineAwesomeIcons.venus_mars)),
            ),
            const SizedBox(height: tFormHeight - 20),
            CheckboxListTile(
              title: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style, // this is the default text style
                  children: <TextSpan>[
                    TextSpan(text: 'I accept the '),
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: TextStyle(
                        color: Colors.blue, // Text color for Terms and Conditions
                        decoration: TextDecoration.underline, // Underline decoration
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Terms and Conditions'),
                                content: SingleChildScrollView(
                                  child: Text(termsandcondition),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                    ),
                  ],
                ),
              ),
              value: controller.termsAccepted.value,
              onChanged: (newValue) => controller.termsAccepted.value = newValue!,
              controlAffinity: ListTileControlAffinity.leading,  // Places the checkbox at the start
            ),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.termsAccepted.value // Button is enabled only if terms are accepted
                      ? () {
                          if (formKey.currentState!.validate()) {
                      final user = UserModel(
                        email: controller.email.text.trim(),
                        password: controller.password.text.trim(),
                        firstName: controller.firstName.text.trim(),
                        lastName: controller.lastName.text.trim(),
                        dateOfBirth: controller.dateOfBirth.text.trim(),
                        gender: controller.gender.value,
                      );
                      SignUpController.instance.createUser();
                    }
                  }
                      : null,
                  child: controller.isLoading.value
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
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
                      : Text(tSignup.toUpperCase()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

