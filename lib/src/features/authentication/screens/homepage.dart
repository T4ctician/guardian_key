import 'package:flutter/material.dart';
import 'package:guardian_key/src/features/authentication/screens/widgets/homepage_widget.dart';


class HomePage  extends StatelessWidget {
  const HomePage ({super.key});
  

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: HomePageWidget(),  // Reference to the widget from homepage_widget.dart
      ),
    );
  }
}
