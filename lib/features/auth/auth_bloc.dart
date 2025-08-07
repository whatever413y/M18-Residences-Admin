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
      final admin = authService.cachedAdmin!;
      _cachedAdmin = admin;
      emit(Authenticated(token: token!, admin: admin));
    } catch (e) {
      emit(AuthError('Login failed: $e'));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await authService.logout();
    _cachedAdmin = null;
    emit(Unauthenticated('You have been logged out.'));
  }

  Admin? get cachedAdmin => _cachedAdmin;
}
