import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String fullName;
  final String? companyName;
  final String? phoneNumber;
  final String role;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.companyName,
    this.phoneNumber,
    required this.role,
  });

  @override
  List<Object?> get props => [id, email, fullName, companyName, phoneNumber, role];
}