import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginException extends Equatable implements Exception {
  final String message;

  const LoginException(this.message);

  @override
  List<Object?> get props => [message];
}

class LoginModel extends ChangeNotifier {
  var isLoading = false;

  Future login(String email, String password, bool rememberMe) async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    final dio = GetIt.I<Dio>();
    final prefs = GetIt.I<SharedPreferences>();

    // Store the current Authorization header to restore it if login fails
    final String? originalAuthHeader = dio.options.headers['Authorization']?.toString();

    // Remove Authorization header for the login request itself
    dio.options.headers.remove('Authorization');

    try {
      final response = await dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['token'] as String?;

      if (token == null) {
        // Login attempt failed to return a token, restore original header state before throwing
        if (originalAuthHeader != null) {
          dio.options.headers['Authorization'] = originalAuthHeader;
        } else {
          dio.options.headers.remove('Authorization');
        }
        throw LoginException('No token received!');
      }

      // Login successful, set the new token for subsequent requests
      dio.options.headers['Authorization'] = 'Bearer $token';

      try {
        await dio.get('/users');
      } catch (_) {
        // Ignore any errors from this call
      }

      if (rememberMe) {
        await prefs.setString('token', token);
      }
      // Removed the 'else' block that was trying to remove the token
      isLoading = false;
      notifyListeners();
      return token;
    } catch (e) {
      if (originalAuthHeader != null) {
        dio.options.headers['Authorization'] = originalAuthHeader;
      } else {
        dio.options.headers.remove('Authorization');
      }
      isLoading = false;
      notifyListeners();
      if (e is LoginException) {
        rethrow;
      } else if (e is DioException) {
        final msg = e.response?.data['message'] ?? 'Login failed due to network error!';
        throw LoginException(msg);
      } else {
        throw LoginException('An unknown error occurred during login.');
      }
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = GetIt.I<SharedPreferences>();
    final token = prefs.getString('token');
    if (token != null) {
      final dio = GetIt.I<Dio>();
      dio.options.headers['Authorization'] = 'Bearer $token';

      try {
        await dio.get('/users');
      } catch (_) {
        // Ignore any errors from this call
      }

      return true;
    }
    return false;
  }
}
