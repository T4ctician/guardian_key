import 'package:flutter/material.dart';
import 'package:guardian_key/model/password_model.dart';

class Constants {
  static Color searchGrey = const Color.fromARGB(255, 82, 101, 120);

  static Color darkBlue = const Color.fromARGB(255, 135, 170, 255);
  static Color lightBlue = const Color.fromARGB(255, 235, 241, 255);

  static Color lightGreen = const Color.fromARGB(255, 231, 249, 242);
  static Color darkGreen = const Color.fromARGB(255, 113, 217, 179);

  static Color lightRed = const Color.fromARGB(255, 253, 237, 241);
  static Color darkRed = const Color.fromARGB(255, 245, 145, 169);

  static Color logoBackground = const Color.fromARGB(255, 239, 239, 239);

  static Color fabBackground = const Color.fromARGB(255, 55, 114, 255);

  static Color buttonBackground = const Color.fromARGB(255, 55, 114, 255);

  static List<passwords> passwordData = [
    passwords(
      websiteName: "www.google.com", 
      userID: "hulornob",
      email: "hulornob@gmail.com",
      password: "asdsad123"
    ),
      passwords(
      websiteName: "www.facebook.com", 
      userID: "noob",
      email: "noob@gmail.com",
      password: "a123d123"
    )
  ];

static List<String> websiteList = passwordData.map((p) => p.websiteName).toList();

}
