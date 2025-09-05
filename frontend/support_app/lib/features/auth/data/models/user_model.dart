import 'package:support_app/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.companyName,
    super.phoneNumber,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'],
      email: json['email'],
      fullName: json['full_name'],
      companyName: json['company_name'],
      phoneNumber: json['phone_number'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'email': email,
      'full_name': fullName,
      'company_name': companyName,
      'phone_number': phoneNumber,
      'role': role,
    };
  }
}