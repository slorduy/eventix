import 'package:eventix/domain/entities/user.dart';

class UserModel {
  final String name;
  final String lastName;
  final String email;
  final String id;

  const UserModel({
    required this.name,
    required this.lastName,
    required this.email,
    required this.id,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['first_name'] as String,
      lastName: json['last_name'] as String,
    );
  }

  User toEntity() {
    return User(id: id, name: name, lastName: lastName, email: email);
  }
}
