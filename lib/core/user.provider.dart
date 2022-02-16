import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  // Create the baseurl variable
  static const String _baseUrl = "http://restapi.adequateshop.com/api";

  // Create a private user variable to store user data in this provider
  User? _user;

  // Create a private token variable to store user authentication token
  String? _token;
  // store the current user ID variable
  int? _userId;

  // Since user variable is private, we need a getter to access it outside of this class
  User? get user => _user;

  // Create the network call to login user and save their token
  Future<String?> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(
          "$_baseUrl/authaccount/login",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      var parsedResponse = jsonDecode(response.body) as Map<String, dynamic>?;
      print(parsedResponse);
      if (parsedResponse?['data'] != null) {
        final SharedPreferences pref = await SharedPreferences.getInstance();
        DateTime datePlus1Day = DateTime.now().add(const Duration(days: 1));
        _token = parsedResponse!['data']['Token'];
        _userId = parsedResponse['data']['Id'];
        pref.setString("user_token", _token!);
        pref.setString("expiry", datePlus1Day.toIso8601String());
      }
      return parsedResponse?['message'];
    } catch (e) {
      debugPrint("$e");
      rethrow;
    }
  }

  // Create the network call to register user and prompt a success message
  Future<String?> signupUser(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(
          "$_baseUrl/authaccount/registration",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: {
          'email': email,
          'password': password,
          'name': name,
        },
      );
      var parsedResponse = jsonDecode(response.body) as Map<String, dynamic>?;
      return parsedResponse?['message'];
    } catch (e) {
      rethrow;
    }
  }

  // Create a network call to get user details and update the state
  Future<bool> getUserData() async {
    try {
      final response = await http.get(
        Uri.parse(
          "$_baseUrl/users/$_userId",
        ),
        headers: {
          "Authorization": "Bearer $_token",
        },
      );
      var parsedResponse = jsonDecode(response.body) as Map<String, dynamic>?;
      if (parsedResponse != null) {
        final SharedPreferences pref = await SharedPreferences.getInstance();
        _user = User.fromMap(parsedResponse);
        pref.setString("user_data", jsonEncode(_user?.toMap()));
        notifyListeners();
      }
      return parsedResponse?.containsKey("id") ?? false;
    } catch (e) {
      rethrow;
    }
  }

  // Create a network call to update user details and update the state
  Future<String> updateUserData(
    String name,
    String email, [
    String location = "USA",
  ]) async {
    try {
      final response = await http.put(
          Uri.parse(
            "$_baseUrl/users/$_userId",
          ),
          body: {
            'email': email,
            'location': location,
            'name': name,
          },
          headers: {
            "Authorization": "Bearer $_token",
            "Content-Type": "application/json",
          });
      var parsedResponse = jsonDecode(response.body) as Map<String, dynamic>?;
      if (parsedResponse != null && parsedResponse['id'] != null) {
        final SharedPreferences pref = await SharedPreferences.getInstance();

        _user = User.fromMap(parsedResponse);
        pref.setString("user_data", jsonEncode(_user?.toMap()));
        notifyListeners();
        return "success";
      } else {
        return parsedResponse?['message'] ?? "Unable to update user details";
      }
    } catch (e) {
      rethrow;
    }
  }

  // Logout method to delete user token from shared preferences
  // It also unsets user and token variable
  Future<void> logoutUser() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();

    pref.clear();
    _token = null;
    _user = null;
    _userId = null;
    notifyListeners();
  }

  // This handles the logic to automatically login user when they open our application
  void tryAutoLogin(String? userData, String? token, String? expiry) async {
    DateTime dateTime = DateTime.parse(expiry ?? "2000-01-01");
    DateTime timeNow = DateTime.now();
    if (expiry != null &&
        userData != null &&
        token != null &&
        timeNow.isBefore(dateTime)) {
      final parsedUser = jsonDecode(userData);
      _token = token;
      _userId = parsedUser['id'];
      _user = User.fromMap(parsedUser);
    } else {
      final SharedPreferences pref = await SharedPreferences.getInstance();

      pref.clear();
    }
  }
}

class User {
  // please note that we get all these data from the API we are using
  final int id;
  final String name;
  final String email;
  final String profilepicture;
  final String location;

  User.fromMap(Map<String, dynamic> user)
      : id = user['id'],
        name = user['name'],
        email = user['email'],
        profilepicture = user['profilepicture'],
        location = user['location'];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "profilepicture": profilepicture,
      "location": location,
    };
  }
}
