// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class passwords {
  final String websiteName;
  final String userID; 
  final String email;
  final String password; 

  passwords({
    required this.websiteName,
    required this.userID,
    required this.email,
    required this.password,
  });

  passwords copyWith({
    String? websiteName,
    String? userID,
    String? email,
    String? password,
  }) {
    return passwords(
      websiteName: websiteName ?? this.websiteName,
      userID: userID ?? this.userID,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'websiteName': websiteName,
      'userID': userID,
      'email': email,
      'password': password,
    };
  }

  factory passwords.fromMap(Map<String, dynamic> map) {
    return passwords(
      websiteName: map['websiteName'] as String,
      userID: map['userID'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory passwords.fromJson(String source) => passwords.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'passwords(websiteName: $websiteName, userID: $userID, email: $email, password: $password)';
  }

  @override
  bool operator ==(covariant passwords other) {
    if (identical(this, other)) return true;
  
    return 
      other.websiteName == websiteName &&
      other.userID == userID &&
      other.email == email &&
      other.password == password;
  }

  @override
  int get hashCode => websiteName.hashCode ^ userID.hashCode ^ email.hashCode ^ password.hashCode;
}
