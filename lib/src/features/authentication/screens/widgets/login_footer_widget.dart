import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/screens/signup_screen.dart';
import '../../../../constants/sizes.dart';
import '../../../../constants/text_strings.dart';

class LoginFooterWidget extends StatelessWidget {
  const LoginFooterWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: tFormHeight - 20),
        TextButton(
          onPressed: () => Get.off(() => const SignUpScreen()),
          child: Text.rich(
            TextSpan(
              text: tDontHaveAnAccount,
              style: Theme.of(context).textTheme.bodyLarge,
              children: const [
                TextSpan(text: tSignup, style: TextStyle(color: Colors.blue))
              ]
            ),
          ),
        ),
      ],
    );
  }
}
