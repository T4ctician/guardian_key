import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';

class EncryptionService {
  // Derive a key from the master password using SHA-256
  Key _deriveKey(String masterPassword) {
    final digest = sha256.convert(utf8.encode(masterPassword));
    return Key.fromUtf8(digest.toString().substring(0, 32)); // Using the first 32 characters of the hash
  }

  // Encrypt data using a derived key from the master password
  // Now returns a Map containing both the encrypted data and the IV
  Map<String, String> encryptData(String plaintext, String masterPassword) {
    final key = _deriveKey(masterPassword);
    final iv = IV.fromSecureRandom(16); // Securely generate a random IV
    final encrypter = Encrypter(AES(key));

    final encryptedText = encrypter.encrypt(plaintext, iv: iv).base64;
    return {
      'encryptedText': encryptedText,
      'iv': iv.base64,
    };
  }

  // Decrypt data using a derived key from the master password and the provided IV
  String decryptData(String encryptedText, String masterPassword, String ivBase64) {
    final key = _deriveKey(masterPassword);
    final iv = IV.fromBase64(ivBase64); // Convert the base64 IV back to IV
    final encrypter = Encrypter(AES(key));

    return encrypter.decrypt64(encryptedText, iv: iv);
  }

  String hashPassword(String password) {
  var bytes = utf8.encode(password); // data being hashed
  var digest = sha256.convert(bytes);
  return digest.toString();
  }
}

