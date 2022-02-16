import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../core/user.provider.dart';
import 'signup.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isLoading = false;

  //we dispose the text controllers to avoid memory leaks
  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  //we create an helper method to display a snackbar for feedback
  _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Auto-login platform"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 24.0),
            const Text(
              "Access your account",
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: "Email",
                hintText: "Enter your email here",
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(
                labelText: "Password",
                hintText: "Enter your password here",
              ),
            ),
            const SizedBox(height: 20.0),
            RichText(
              text: TextSpan(
                text: "Don't have an account? ",
                children: [
                  TextSpan(
                    text: "Register",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context)
                          ..pop()
                          ..push(
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                      },
                    style: const TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ],
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 48.0),
            ElevatedButton(
              onPressed: () async {
                // check if user filled in the textfield
                final email = _email.value.text;
                final password = _password.value.text;
                if (email.isEmpty || password.isEmpty) {
                  _showSnackbar("Email and password are required");
                  return;
                }
                setState(() => _isLoading = true);
                try {
                  // login user and get response message
                  final result = await context
                      .read<UserProvider>()
                      .loginUser(email, password);
                  if (result == "success") {
                    // fetch user data and save the state in our provider class
                    await context.read<UserProvider>().getUserData();
                    //pop the login screen and navigate to homepage
                    Navigator.of(context)
                      ..pop()
                      ..push(
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                      );
                  } else {
                    setState(() => _isLoading = false);
                    _showSnackbar(result ?? "An error occurred, try again");
                  }
                } catch (e) {
                  setState(() => _isLoading = false);
                  _showSnackbar("Check your internet connection and try again");
                  debugPrint("$e");
                }
              },
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                        Colors.white,
                      ),
                    )
                  : const Text("Login"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50.0),
              ),
            )
          ],
        ),
      ),
    );
  }
}
