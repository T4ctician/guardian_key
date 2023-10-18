import 'dart:math';

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
  if (numUpperCase + numLowerCase + numSpecialChars > length) {
    throw ArgumentError('Sum of uppercase, lowercase, and special characters should not exceed total length.');
  }

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

  // Only generate numbers for the remaining length
  for (int i = password.length; i < length; i++) {
    password += number[Random.secure().nextInt(number.length)];
  }

  List<String> passwordChars = password.split('');
  passwordChars.shuffle();
  password = passwordChars.join('');
  return password;
}


