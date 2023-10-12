import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

const letterLowerCase = "abcdefghijklmnopqrstuvwxyz";
const letterUpperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const number = '0123456789';
const special = '@#%^*>\$@?/[]=+';


Future<String> generatePassword({
  required int length,
  required int numUpperCase,
  required int numLowerCase,
  required int numSpecialChars,
}) async {

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int numUpperCase = prefs.getDouble('numUpperCase')?.toInt() ?? 1;
  int numLowerCase = prefs.getDouble('numLowerCase')?.toInt() ?? 1;
  int numSpecialChars = prefs.getDouble('numSpecialChars')?.toInt() ?? 1;

  String chars = "$letterLowerCase$letterUpperCase$number$special";
  
  String password = '';
  for (int i = 0; i < numUpperCase; i++) {
    password += letterUpperCase[Random.secure().nextInt(letterUpperCase.length)];
  }
  for (int i = 0; i < numLowerCase; i++) {
    password += letterLowerCase[Random.secure().nextInt(letterLowerCase.length)];
  }
  for (int i = 0; i < numSpecialChars; i++) {
    password += special[Random.secure().nextInt(special.length)];
  }

  for (int i = password.length; i < length; i++) {
    password += chars[Random.secure().nextInt(chars.length)];
  }

  List<String> passwordChars = password.split('');
  passwordChars.shuffle();
  password = passwordChars.join('');
  return password;
}
