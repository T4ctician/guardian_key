import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:guardian_key/src/constants/colors.dart';
import 'package:guardian_key/src/constants/sizes.dart';
import 'package:guardian_key/src/constants/text_strings.dart';
import 'package:guardian_key/src/features/authentication/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardian_key/src/features/authentication/controllers/profile_controller.dart';

class ProfileFormScreen extends StatelessWidget {
  const ProfileFormScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.user,
  }) : super(key: key);

  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController email;
  final TextEditingController password;
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: firstName,
            decoration: const InputDecoration(label: Text('First Name'), prefixIcon: Icon(LineAwesomeIcons.user)),
          ),
          const SizedBox(height: tFormHeight - 20),
          TextFormField(
            controller: lastName,
            decoration: const InputDecoration(label: Text('Last Name'), prefixIcon: Icon(LineAwesomeIcons.user)),
          ),
          const SizedBox(height: tFormHeight - 20),
          TextFormField(
            controller: password,
            obscureText: true,
            decoration: InputDecoration(
              label: const Text(tPassword),
              prefixIcon: const Icon(Icons.fingerprint),
              suffixIcon: IconButton(icon: const Icon(LineAwesomeIcons.eye_slash), onPressed: () {}),
            ),
          ),
          const SizedBox(height: tFormHeight),

          /// -- Form Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
          onPressed: () async {
            final userData = UserModel(
              id: user.id,
              email: email.text.trim(),
              password: password.text.trim(),
              firstName: firstName.text.trim(),
              lastName: lastName.text.trim(),
              dateOfBirth: user.dateOfBirth,
              gender: user.gender,
            );

            // Update Firebase Auth Email and Password
            final currentUser = FirebaseAuth.instance.currentUser;

            if (currentUser != null) {
              if (currentUser.email != email.text.trim()) {
                try {
                  await currentUser.updateEmail(email.text.trim());
                } catch (e) {
                  print("Error updating email: $e");
                  // Handle errors: e.g. show a dialog with the error
                }
              }

              if (password.text.trim().isNotEmpty) {
                try {
                  await currentUser.updatePassword(password.text.trim());
                } catch (e) {
                  print("Error updating password: $e");
                  // Handle errors: e.g. show a dialog with the error
                }
              }
            }

            await controller.updateRecord(userData);
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
                    title: Text('Delete User?'),
                    content: Text('Are you sure you want to delete your profile? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
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
