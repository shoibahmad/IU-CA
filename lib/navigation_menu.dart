import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iu_ca/urlredirect.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    UrlRedirectScreen(),
    ProfilePage(),
    AdminPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 11, 32, 43),
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.user),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.setting),
            label: 'Admin',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home'),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile'),
    );
  }
}

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Admin'),
    );
  }
}
