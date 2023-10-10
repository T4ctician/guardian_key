import 'dart:math';

String generatePassword({
  bool letter = true,
  bool isNumber = true,
  bool isSpecial = true,
}) {
  const length = 8;
  const letterLowerCase = "abcdefghijklmnopqrstuvwxyz";
  const letterUpperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const number = '0123456789';
  const special = '@#%^*>\$@?/[]=+';

  String chars = "";
  if (letter) chars += '$letterLowerCase$letterUpperCase';
  if (isNumber) chars += '$number';
  if (isSpecial) chars += '$special';

  // Ensure one character from each category is added
  String password = '';
  if (letter) {
    password += letterLowerCase[Random.secure().nextInt(letterLowerCase.length)];
    password += letterUpperCase[Random.secure().nextInt(letterUpperCase.length)];
  }
  if (isNumber) {
    password += number[Random.secure().nextInt(number.length)];
  }
  if (isSpecial) {
    password += special[Random.secure().nextInt(special.length)];
  }

  // Fill the rest of the length with random characters from the combined pool
  for (int i = password.length; i < length; i++) {
    password += chars[Random.secure().nextInt(chars.length)];
  }

// Shuffle the characters to ensure randomness
  List<String> passwordChars = password.split(''); // Split the password into individual characters
  passwordChars.shuffle(); // Shuffle the characters
  password = passwordChars.join(''); // Join the characters back into a string
  return password;

}
