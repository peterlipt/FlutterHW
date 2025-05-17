import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../network/user_item.dart';

class ListException extends Equatable implements Exception {
  final String message;

  const ListException(this.message);

  @override
  List<Object?> get props => [message];
}

class ListModel extends ChangeNotifier{
  var isLoading = false;
  var users = <UserItem>[];

  Future loadUsers() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();
    try {
      final dio = GetIt.I<Dio>();
      final prefs = GetIt.I<SharedPreferences>();
      final token = prefs.getString('token');
      if (token == null) {
        throw ListException('Nincs bejelentkezve!');
      }
      dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await dio.get('/users');
      final data = response.data as List;
      users = data.map((e) => UserItem(e['name'], e['avatarUrl'])).cast<UserItem>().toList();
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Hiba a felhasználók lekérésekor!';
      throw ListException(msg);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}