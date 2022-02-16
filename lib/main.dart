import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_login_app/core/user.provider.dart';

import 'view/login.dart';

void main() {
  runApp(
    ChangeNotifierProvider.value(
      value: UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto-login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}
