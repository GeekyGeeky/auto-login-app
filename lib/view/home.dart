import 'package:auto_login_app/core/user.provider.dart';
import 'package:auto_login_app/view/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPageIndex = 0;
  final List<Widget> _tabScreens = [];

  @override
  void initState() {
    super.initState();
    _tabScreens
      ..add(const ProfileTab())
      ..add(const EditProfileTab());
  }

  // the default method called to render widgets to the screen
  @override
  Widget build(BuildContext context) {
    // the layout of a screen is created using the scaffold widget
    return Scaffold(
      appBar: AppBar(
        title: const Text("Auto-login platform"),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<UserProvider>().logoutUser();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.exit_to_app,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: _tabScreens.elementAt(_currentPageIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentPageIndex,
          onTap: (index) {
            setState(() {
              _currentPageIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: "Edit profile",
            )
          ]),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
        // create the builder and get the userprovider
        builder: (_, userProvider, __) {
      final User user = userProvider.user!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                user.profilepicture,
              ),
              radius: 60.0,
            ),
          ),
          const SizedBox(
            height: 16.0,
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Full name"),
                  const SizedBox(
                    height: 4.0,
                  ),
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 16.0,
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Email"),
                  const SizedBox(
                    height: 4.0,
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 16.0,
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Location"),
                  const SizedBox(
                    height: 4.0,
                  ),
                  Text(
                    user.location,
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 16.0,
          ),
        ],
      );
    });
  }
}

class EditProfileTab extends StatefulWidget {
  const EditProfileTab({Key? key}) : super(key: key);

  @override
  State<EditProfileTab> createState() => _EditProfileTabState();
}

class _EditProfileTabState extends State<EditProfileTab> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _location;
  bool _isLoading = false;

  @override
  void initState() {
    final user = context.read<UserProvider>().user!;
    _name = TextEditingController(text: user.name);
    _email = TextEditingController(text: user.email);
    _location = TextEditingController(text: user.location);
    super.initState();
  }

  //we dispose the text controllers to avoid memory leaks
  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _email.dispose();
    _location.dispose();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 24.0),
        const Text(
          "Update your profile",
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
          controller: _location,
          decoration: const InputDecoration(
            labelText: "Location",
            hintText: "Enter your location here",
          ),
        ),
        const SizedBox(height: 48.0),
        ElevatedButton(
          onPressed: () async {
            // check if user filled in the textfield
            final name = _name.value.text;
            final email = _email.value.text;
            final location = _location.value.text;
            if (email.isEmpty || location.isEmpty || name.isEmpty) {
              _showSnackbar("All fields are required");
              return;
            }
            setState(() => _isLoading = true);
            try {
              // login user and get response message
              final result = await context
                  .read<UserProvider>()
                  .updateUserData(name, email, location);
              _showSnackbar(result);
            } catch (e) {
              _showSnackbar("Check your internet connection and try again");
              debugPrint("$e");
            }
            setState(() => _isLoading = false);
          },
          child: _isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                    Colors.white,
                  ),
                )
              : const Text("Submit"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50.0),
          ),
        )
      ],
    );
  }
}
