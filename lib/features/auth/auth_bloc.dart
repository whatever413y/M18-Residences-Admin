import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/models/admin.dart';
import 'package:rental_management_system_flutter/services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  Admin? _cachedAdmin;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginWithAccountId>(_onLoginWithAccountId);
    on<LogoutRequested>(_onLogout);
    on<FetchReceiptUrl>(_onFetchReceiptUrl);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    try {
      final isAuth = await authService.isAuthenticated();
      if (!isAuth) {
        return emit(Unauthenticated('Session has expired. Please try again'));
      }

      final token = await authService.getSavedToken();
      final adminUsername = await authService.getSavedAdminId();

      if (token == null || adminUsername == null) {
        return emit(Unauthenticated('Token or user missing'));
      }

      _cachedAdmin = Admin(username: adminUsername);
      emit(Authenticated(token: token, admin: _cachedAdmin!));
    } catch (e) {
      emit(Unauthenticated('Auth error: $e'));
    }
  }

  Future<void> _onLoginWithAccountId(LoginWithAccountId event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await authService.adminLogin(event.username, event.password);
      if (token == null) {
        emit(AuthError('Invalid credentials'));
        return;
      }
      final admin = authService.cachedAdmin!;
      _cachedAdmin = admin;
      emit(Authenticated(token: token, admin: admin));
    } on TimeoutException {
      emit(AuthError('Connection timed out. Please try again.'));
    } on SocketException {
      emit(AuthError('Network error. Please check your connection.'));
    } catch (e) {
      emit(AuthError('Unexpected error: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await authService.logout();
    _cachedAdmin = null;
    emit(Unauthenticated('You have been logged out.'));
  }

  Future<void> _onFetchReceiptUrl(FetchReceiptUrl event, Emitter<AuthState> emit) async {
    emit(ReceiptUrlLoading());
    try {
      final url = await authService.fetchReceiptUrl(event.tenantName, event.filename);
      if (url == null) throw Exception('URL not found');
      emit(ReceiptUrlLoaded(url));
    } catch (e) {
      emit(ReceiptUrlError(e.toString()));
    }
  }

  Admin? get cachedAdmin => _cachedAdmin;
}
