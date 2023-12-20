// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

// part of 'package:dolan_yuk/imports.dart';

import 'dart:convert';

import 'package:dolan_yuk/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MyLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DolanYuk Login',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
      ),
      home: Login(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  String email = "";
  String password = "";
  String errorLogin = "";

  final ButtonStyle loginBtnStyle =
      ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange);

  void doLogin() async {
    final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160420033/dolanyuk_api/login.php"),
        body: {'email': email, 'password': password});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("email", email);
        prefs.setString("full_name", json['full_name']);
        if (json['image'] != '') {
          prefs.setString("image", json['image']);
        }
        main();
      } else {
        setState(() {
          errorLogin = "Incorrect email/password";
        });
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            child: Container(
              width: 300,
              child: Column(
                children: [
                  Center(
                    child: Text(
                      "DolanYuk",
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          hintText: 'Your email'),
                      onChanged: (v) {
                        email = v;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    //padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          hintText: 'Your password'),
                      onChanged: (v) {
                        password = v;
                      },
                    ),
                  ),
                  if (errorLogin != "")
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        errorLogin,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                              onPressed: () {},
                              child: Text(
                                'Sign Up',
                              )),
                          SizedBox(
                            width: 5,
                          ),
                          ElevatedButton(
                              style: loginBtnStyle,
                              onPressed: () {
                                doLogin();
                              },
                              child: Text(
                                'Sign In',
                                style: TextStyle(color: Colors.white),
                              )),
                        ]),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    )));
  }
}
