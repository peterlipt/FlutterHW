import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'network/data_source_interceptor.dart';
import 'ui/provider/login/login_model.dart';
import 'ui/provider/login/login_page.dart';
import 'ui/provider/list/list_model.dart';
import 'ui/provider/list/list_page.dart';

//DO NOT MODIFY
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureFixDependencies();
  await configureCustomDependencies();
  runApp(const MyApp());
}

//DO NOT MODIFY
Future configureFixDependencies() async {
  var dio = Dio();
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
    ),
  );
  dio.interceptors.add(DataSourceInterceptor());
  GetIt.I.registerSingleton(dio);
  GetIt.I.registerSingleton(await SharedPreferences.getInstance());
  GetIt.I.registerSingleton(<NavigatorObserver>[]);
}

//Add custom dependencies if necessary
Future configureCustomDependencies() async {

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginModel()),
        ChangeNotifierProvider(create: (_) => ListModel()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPageProvider(),
          '/list': (context) => const ListPageProvider(),
        },
        //DO NOT MODIFY
        navigatorObservers: GetIt.I<List<NavigatorObserver>>(),
        //DO NOT MODIFY
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}