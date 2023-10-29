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
    print('Building SignUpFormWidget');
    final controller = Get.find<SignUpController>();
    final formKey = GlobalKey<FormState>();

  return Container(
    padding: const EdgeInsets.symmetric(vertical: tFormHeight - 10),
    child: SingleChildScrollView( 
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          TextFormField(
            controller: controller.firstName,
            decoration: InputDecoration(
              label: Text(
                tFirstName + (controller.firstName.text.isEmpty ? " *" : ""), 
                style: TextStyle(
                  color: controller.firstName.text.isEmpty ? Colors.red : null
                )
              ),
              prefixIcon: const Icon(LineAwesomeIcons.user),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'First Name cannot be empty';
              }
              return null;
            },
          ),
            const SizedBox(height: tFormHeight - 20),
            TextFormField(
              controller: controller.lastName,
              decoration: const InputDecoration(
                  label: Text(tLastName),
                  prefixIcon: Icon(LineAwesomeIcons.user)),
            ),
            TextFormField(
              controller: controller.email,
              decoration: InputDecoration(
                label: Text(
                  tEmail + (controller.email.text.isEmpty ? " *" : ""), 
                  style: TextStyle(
                    color: controller.email.text.isEmpty ? Colors.red : null
                  )
                ),
                prefixIcon: const Icon(LineAwesomeIcons.envelope),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email cannot be empty';
                } else if (!RegExp(
                  r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
                ).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: tFormHeight - 20),
            TextFormField(
              controller: controller.dateOfBirth, // Use TextEditingController for TextField
              readOnly: true, // Make it read-only so user cannot type but only select date using DatePicker
              decoration: const InputDecoration(
                  label: Text(tDateOfBirth),
                  prefixIcon: Icon(LineAwesomeIcons.calendar)),
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  final String formattedDate = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                  controller.dateOfBirth.text = formattedDate; // Assign formatted date to the Controller
                }
              },
            ),


            const SizedBox(height: tFormHeight - 20),
            DropdownButtonFormField(
              items: ['Male', 'Female', 'Prefer not to say']
                  .map((label) => DropdownMenuItem(
                        value: label,
                        child: Text(label),
                      ))
                  .toList(),
              onChanged: (value) => controller.gender.value = value.toString(),
              decoration: const InputDecoration(
                  label: Text(tGender),
                  prefixIcon: Icon(LineAwesomeIcons.venus_mars)),
            ),
            const SizedBox(height: tFormHeight - 20),
            Obx(
            () => TextFormField(
              controller: controller.password,
              obscureText: controller.obscureText.value,
              decoration: InputDecoration(
                label: Text(
                  'Password' + (controller.password.text.isEmpty ? ' *' : ''),
                  style: TextStyle(
                    color: controller.password.text.isEmpty ? Colors.red : null,
                  ),
                ),
                prefixIcon: const Icon(LineAwesomeIcons.key),
                suffixIcon: IconButton(
                  onPressed: controller.togglePasswordVisibility,
                  icon: Icon(
                    controller.obscureText.value ? LineAwesomeIcons.eye : LineAwesomeIcons.eye_slash,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter Password";
                } else if (value.length < 8) {
                  return "Use 8 or more characters";
                } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return "Use at least one uppercase letter";
                } else if (!RegExp(r'[a-z]').hasMatch(value)) {
                  return "Use at least one lowercase letter";
                } else if (!RegExp(r'[0-9]').hasMatch(value)) {
                  return "Use at least one number";
                } else if (!RegExp(r'[!@#$&]').hasMatch(value)) {
                  return r"Use one special char !@#$&";
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: tFormHeight - 20),
          Obx(
            () => TextFormField(
              controller: controller.confirmPassword,
              obscureText: controller.obscureText.value,
              decoration: InputDecoration(
                label: Text(
                  'Confirm Password' + (controller.confirmPassword.text.isEmpty ? ' *' : ''),
                  style: TextStyle(
                    color: controller.confirmPassword.text.isEmpty ? Colors.red : null,
                  ),
                ),
                prefixIcon: const Icon(LineAwesomeIcons.key),
                suffixIcon: IconButton(
                  onPressed: controller.togglePasswordVisibility,
                  icon: Icon(
                    controller.obscureText.value ? LineAwesomeIcons.eye : LineAwesomeIcons.eye_slash,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirm Password';
                } else if (value != controller.password.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ),

            const SizedBox(height: tFormHeight - 20),
            ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,  // To prevent the row from expanding
                children: [
                  Obx(
                    () => IconButton(
                      icon: controller.termsAccepted.value 
                            ? Icon(Icons.check_box, color: Colors.blue) 
                            : Icon(Icons.check_box_outline_blank),
                      onPressed: () {
                        controller.termsAccepted.value = !controller.termsAccepted.value;
                      },
                    ),
                  ),
                ],
              ),
              title: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style, // this is the default text style
                  children: <TextSpan>[
                    const TextSpan(text: 'I accept the '),
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: const TextStyle(
                        color: Colors.blue, // Text color for Terms and Conditions
                        decoration: TextDecoration.underline, // Underline decoration
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Terms and Conditions'),
                                content: const SingleChildScrollView(
                                  child: Text(termsandcondition),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Close'),
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
                      : Text(tSignup.toUpperCase()),
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

