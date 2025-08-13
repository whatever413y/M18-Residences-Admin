import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginWithAccountId extends AuthEvent {
  final String username;
  final String password;

  LoginWithAccountId({required this.username, required this.password});
}

class LogoutRequested extends AuthEvent {}

class FetchReceiptUrl extends AuthEvent {
  final String tenantName;
  final String filename;

  FetchReceiptUrl(this.tenantName, this.filename);
}
