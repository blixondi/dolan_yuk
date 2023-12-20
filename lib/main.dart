import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dolan_yuk/screen/login.dart';

String activeUser = "";

Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  String full_name = prefs.getString("full_name") ?? '';
  return full_name;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkUser().then((String result) {
    if (result == '') {
      runApp(MyLogin());
    } else {
      activeUser = result;
      runApp(const MainApp());
    }
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
