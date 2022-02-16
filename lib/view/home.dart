import 'package:flutter/material.dart';

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
            onPressed: () {},
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
    return const Center(
      child: Text("Profile"),
    );
  }
}

class EditProfileTab extends StatelessWidget {
  const EditProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Edit Profile"),
    );
  }
}
