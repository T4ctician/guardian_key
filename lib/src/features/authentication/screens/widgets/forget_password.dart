import 'package:flutter/material.dart';
import 'package:guardian_key/src/features/authentication/controllers/forgetpassword_controller.dart';
import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/screens/login.dart';
import '../../../../constants/text_strings.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final controller = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        // Optionally, you can add a back or close button here.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30.0),
              Image.asset('assets/forget_password/forget-password.png', width:250, height:250),

              const SizedBox(height: 10.0),
              const Text('Forget Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

              const SizedBox(height: 30.0),
              const Text('Enter your email address to receive a password reset link.'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',  // Added label
                  prefixIcon: const Icon(Icons.email),  // Added email icon
                  hintText: 'example@domain.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),  // Added rounded corners
                  ),
                ),
              ),
                          const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.sendResetEmail(_emailController.text.trim()),
                  child: const Text('Send Reset Link'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),  // Rounded corners for button
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: () => Get.off(() => const LoginScreen()),
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                    text: tAlreadyHaveAnAccount,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const TextSpan(text: tLogin)
                ])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}