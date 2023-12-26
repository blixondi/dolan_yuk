// ignore_for_file: prefer_const_constructors

import 'package:dolan_yuk/screen/cari.dart';
import 'package:dolan_yuk/screen/jadwal.dart';
import 'package:dolan_yuk/screen/profiles.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dolan_yuk/screen/login.dart';

String activeUser = "";
String activeEmail = "";
String activePhoto = "";
int activeUserId = 0;

GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

Future<Map<String, dynamic>> getUserData() async {
  final prefs = await SharedPreferences.getInstance();
  String full_name = prefs.getString("full_name") ?? '';
  String email = prefs.getString("email") ?? '';
  int user_id = prefs.getInt("user_id") ?? 0;
  String image = prefs.getString("user_image") ?? '';
  return {
    'full_name': full_name,
    'email': email,
    'user_id': user_id,
    'image': image
  };
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  getUserData().then((Map<String, dynamic> result) {
    if (result['full_name'] == '') {
      runApp(MyLogin());
    } else {
      activeUser = result['full_name'];
      activeEmail = result['email'];
      activeUserId = result['user_id'];
      activePhoto = result['image'];
      runApp(const MainApp());
    }
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'jadwal': (context) => Jadwal_Screen(),
        'cari': (context) => Cari(),
        'profil': (context) => Profiles(),
      },
      title: 'Dolan Yuk',
      home: const MyHomePage(title: 'Dolan Yuk'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _screen = [Jadwal_Screen(), Cari(), Profiles()];

  void doLogout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("email");
    prefs.remove("user_id");
    prefs.remove("full_name");
    main();
  }

  @override
  Widget build(BuildContext context) {
    Drawer ourDrawer() {
      return Drawer(
        elevation: 16.0,
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
                accountName: Text(activeUser),
                accountEmail: Text(activeEmail),
                currentAccountPicture:
                    CircleAvatar(backgroundImage: NetworkImage(activePhoto))),
            ListTile(
              title: Text("Jadwal"),
              leading: Icon(Icons.calendar_month_rounded),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                  toggleDrawer();
                });
              },
            ),
            ListTile(
              title: Text("Cari"),
              leading: Icon(Icons.search),
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                  toggleDrawer();
                });
              },
            ),
            ListTile(
              title: Text("Profil"),
              leading: Icon(Icons.person),
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                  toggleDrawer();
                });
              },
            ),
            ListTile(
              title: Text("Logout"),
              leading: Icon(Icons.logout),
              onTap: () {
                doLogout();
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: ourDrawer(),
      appBar: AppBar(backgroundColor: Colors.red, title: Text("DolanYuk")),
      body: _screen[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        fixedColor: Colors.deepOrange,
        items: const [
          BottomNavigationBarItem(
            label: "Jadwal",
            icon: Icon(Icons.calendar_month_rounded),
          ),
          BottomNavigationBarItem(
            label: "Cari",
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            label: "Profil",
            icon: Icon(Icons.person),
          ),
        ],
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  toggleDrawer() async {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openEndDrawer();
    } else {
      _scaffoldKey.currentState!.openDrawer();
    }
  }
}
