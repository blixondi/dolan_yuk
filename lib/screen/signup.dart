// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<StatefulWidget> createState() => SignupState();
}

class SignupState extends State<Signup> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String fullName = "";
  String password = "";
  String repeatPassword = "";

  final ButtonStyle SignUpBtnStyle =
      ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange);

  void register() async {
    final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160420033/dolanyuk_api/signup.php"),
        body: {'email': email, 'full_name': fullName, 'password': password});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (mounted) {
          showDialog<String>(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: Text(
                      'Berhasil',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: Text('Akun telah berhasil dibuat, silahkan login'),
                    actions: <Widget>[
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text('OK')),
                    ],
                  ));
        }
      } else {
        if (mounted) {
          showDialog<String>(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: Text(
                      'Gagal',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                        'Email sudah terpakai, silahkan gunakan email lain'),
                    actions: <Widget>[
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OK')),
                    ],
                  ));
        }
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
              child: Text(
                "Sign Up",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
              child: Text(
                  "Sebelum nikmatin fasilitas DolanYuk, bikin akun dulu yuk!"),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
              child: Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                          ),
                          onChanged: (value) {
                            email = value;
                          },
                          validator: (value) {
                            if (!EmailValidator.validate(email)) {
                              return 'Masukkan email yang benar';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nama Lengkap',
                          ),
                          onChanged: (value) {
                            fullName = value;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Nama lengkap tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: TextFormField(
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                          ),
                          onChanged: (value) {
                            password = value;
                          },
                          validator: (value) {
                            if (value!.isEmpty || value.length < 8) {
                              return 'Password tidak boleh kosong dan minimal 8 karakter';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: TextFormField(
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Ulangi Password',
                          ),
                          onChanged: (value) {
                            repeatPassword = value;
                          },
                          validator: (value) {
                            if (value != password) {
                              return 'Password tidak sama';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Kembali',
                                )),
                            ElevatedButton(
                                style: SignUpBtnStyle,
                                onPressed: () {
                                  if (formKey.currentState != null &&
                                      !formKey.currentState!.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Harap isian diperbaiki')));
                                  } else {
                                    register();
                                  }
                                },
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(color: Colors.white),
                                )),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    ));
  }
}
