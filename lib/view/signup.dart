import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../core/user.provider.dart';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isLoading = false;

  //we dispose the text controllers to avoid memory leaks
  @override
  void dispose() {
    super.dispose();
    _name.dispose();
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

  // the default method called to render widgets to the screen
  @override
  Widget build(BuildContext context) {
    // the layout of a screen is created using the scaffold widget
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
              "Create your account",
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: "Full name",
                hintText: "Enter your full name here",
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
                text: "Already have an account? ",
                children: [
                  TextSpan(
                    text: "Login",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context)
                          ..pop()
                          ..push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
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
                final name = _name.value.text;
                final email = _email.value.text;
                final password = _password.value.text;
                if (email.isEmpty || password.isEmpty || name.isEmpty) {
                  _showSnackbar("All fields are required");
                  return;
                }
                setState(() => _isLoading = true);
                try {
                  // login user and get response message
                  final result = await context
                      .read<UserProvider>()
                      .signupUser(name, email, password);
                  if (result == "success") {
                    //pop the login screen and navigate to login screen
                    Navigator.of(context)
                      ..pop()
                      ..push(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    _showSnackbar(
                        "Your account has been created, please login");
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
                  : const Text("Register"),
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
