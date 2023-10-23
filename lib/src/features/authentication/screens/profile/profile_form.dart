import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:guardian_key/src/constants/colors.dart';
import 'package:guardian_key/src/constants/sizes.dart';
import 'package:guardian_key/src/constants/text_strings.dart';
import 'package:guardian_key/src/features/authentication/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardian_key/src/features/authentication/controllers/profile_controller.dart';

  class ProfileFormScreen extends StatefulWidget {
    final TextEditingController firstName;
    final TextEditingController lastName;
    final TextEditingController email;
    final TextEditingController password;
    final UserModel user;

    const ProfileFormScreen({
      Key? key,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.password,
      required this.user,
    }) : super(key: key);

    @override
    _ProfileFormScreenState createState() => _ProfileFormScreenState();
  }

  class _ProfileFormScreenState extends State<ProfileFormScreen> {
    bool isPasswordObscured = true;
    final _formKey = GlobalKey<FormState>();


    void toggleObscure() {
      setState(() {
        isPasswordObscured = !isPasswordObscured;
      });
    }

  @override
  void initState() {
    super.initState();
    widget.password.clear();  // Clear the password text field controller
  }

  @override
  void dispose() {
    widget.password.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: widget.firstName,
            decoration: const InputDecoration(label: Text('First Name'), prefixIcon: Icon(LineAwesomeIcons.user)),
          ),
          const SizedBox(height: tFormHeight - 20),
          TextFormField(
            controller: widget.lastName,
            decoration: const InputDecoration(label: Text('Last Name'), prefixIcon: Icon(LineAwesomeIcons.user)),
          ),
          const SizedBox(height: tFormHeight - 20),
          TextFormField(
            controller: widget.password,
            obscureText: isPasswordObscured,
            decoration: InputDecoration(
              label: const Text("New Password"),
              hintText: "Enter new password",
              prefixIcon: const Icon(Icons.fingerprint),
              suffixIcon: IconButton(
                  icon: Icon(isPasswordObscured ? LineAwesomeIcons.eye_slash : LineAwesomeIcons.eye),
                  onPressed: toggleObscure,
            ),
          ),
            validator: (value) {
                print("Validating password...");
                if (value == null || value.isEmpty) {
                    return "Enter Password";
                } 

                List<String> errors = [];

                if (value.length < 8) {
                    errors.add("Use 8 or more characters");
                }
                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    errors.add("Use at least one uppercase letter");
                }
                if (!RegExp(r'[a-z]').hasMatch(value)) {
                    errors.add("Use at least one lowercase letter");
                }
                if (!RegExp(r'[0-9]').hasMatch(value)) {
                    errors.add("Use at least one number");
                }
                if (!RegExp(r'[!@#$&]').hasMatch(value)) {
                    errors.add(r"Use one special char !@#$&");
                }

                if (errors.isNotEmpty) {
                    return errors.join('\n');
                }
                return null;
            },

          ),
          const SizedBox(height: tFormHeight),

          /// -- Form Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final userData = UserModel(
                    id: widget.user.id,
                    email: widget.email.text.trim(),
                    password: widget.password.text.trim(),
                    firstName: widget.firstName.text.trim(),
                    lastName: widget.lastName.text.trim(),
                    dateOfBirth: widget.user.dateOfBirth,
                    gender: widget.user.gender,
                  );

                  // Update Firebase Auth Email and Password
                  final currentUser = FirebaseAuth.instance.currentUser;

                  await controller.updateRecord(userData);
                }
              },

              style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue, side: BorderSide.none, shape: const StadiumBorder()),
              child: const Text(tSaveProfile, style: TextStyle(color: tSecondaryColor)),
            ),
          ),
          const SizedBox(height: tFormHeight),

          /// -- Delete Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Confirmation dialog before deleting
                bool? shouldDelete = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete User?'),
                    content: const Text('Are you sure you want to delete your profile? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                );

                if (shouldDelete != null && shouldDelete) {
                  controller.deleteUser();
                  // Optionally, you can navigate to another page or show a message that user has been deleted
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                elevation: 0,
                foregroundColor: Colors.red,
                shape: const StadiumBorder(),
                side: BorderSide.none,
              ),
              child: const Text(tDelete),
            ),
          ),
        ],
      ),
    );
  }
}
