import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/user.provider.dart';
import 'view/login.dart';
import 'view/home.dart';

void main() async {
  // call this method to allow flutter draw its first frame
  // before performing any async action
  WidgetsFlutterBinding.ensureInitialized();
  final pref = await SharedPreferences.getInstance();
  final user = pref.getString("user_data");
  final expiry = pref.getString("expiry");
  final token = pref.getString("user_token");
  runApp(
    ChangeNotifierProvider.value(
      value: UserProvider(),
      child: MyApp(
        user: user,
        token: token,
        expiry: expiry,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? user;
  final String? token;
  final String? expiry;
  const MyApp({Key? key, this.user, this.token, this.expiry}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
        // create the builder and get the userprovider
        builder: (_, userProvider, __) {
      // check if user is null then try auto-login
      if (userProvider.user == null) {
        userProvider.tryAutoLogin(user, token, expiry);
      }
      return MaterialApp(
        title: 'Auto-login Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // check if user data to determine which screen to show first
        home: userProvider.user == null
            ? const LoginScreen()
            : const HomeScreen(),
      );
    });
  }
}
