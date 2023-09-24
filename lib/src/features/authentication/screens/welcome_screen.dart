import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardian_key/src/features/authentication/screens/homepage.dart';
//import 'package:guardian_key/src/features/authentication/screens/signup/signup_screen.dart';
import '../../../constants/colors.dart';
import '../../../constants/image_strings.dart';
import '../../../constants/text_strings.dart';
import '../../../constants/sizes.dart';
import 'login.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var width = mediaQuery.size.width;
    var height = mediaQuery.size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: tPrimaryColor, // Always use light mode background color
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(tDefaultSize),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Hero(
                    tag: 'welcome-image-tag',
                    child: Image(
                      image: const AssetImage(tWelcomeScreenImage),
                      width: width * 0.7,
                      height: height * 0.6,
                    ),
                  ),
                  Column(
                    children: [
                      Text(tWelcomeTitle, style: Theme.of(context).textTheme.displaySmall),
                      Text(tWelcomeSubTitle, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.to(() => const LoginScreen()),
                          child: Text(tLogin.toUpperCase()),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.to(() => const HomePage()),
                          child: Text(tSignup.toUpperCase()),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
