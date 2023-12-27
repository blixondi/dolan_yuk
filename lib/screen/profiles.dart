import 'dart:convert';
import 'package:dolan_yuk/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profiles extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  final TextEditingController full_name_cont = TextEditingController();
  final TextEditingController email_cont = TextEditingController();
  final TextEditingController user_image_cont = TextEditingController();

  @override
  void initState() {
    super.initState();
    get_data();
  }

  Future<String> profile_full_name() async {
    final prefs = await SharedPreferences.getInstance();
    String full_name = prefs.getString("full_name") ?? '';
    return full_name;
  }

  Future<String> profile_email() async {
    final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email") ?? '';
    return email;
  }

  Future<String> profile_user_image() async {
    final prefs = await SharedPreferences.getInstance();
    String user_image = prefs.getString("user_image") ?? '';
    return user_image;
  }

  void get_data() {
    profile_full_name().then((value) {
      setState(() {
        full_name_cont.text = value;
      });
    });
    profile_email().then((value) {
      setState(() {
        email_cont.text = value;
      });
    });
    profile_user_image().then((value) {
      setState(() {
        user_image_cont.text = value;
      });
    });
  }

  Future<void> UpdateUser() async {
    final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160420033/dolanyuk_api/update_user.php"),
        body: {'full_name': full_name_cont.text.toString(), 'user_image': user_image_cont.text.toString(), 'id': activeUserId.toString()});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        print("berhasil");
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("full_name", full_name_cont.text);
        prefs.setString("user_image", user_image_cont.text);
      } else {
        print("gagal");
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profiles'),
        ),
        body: Container(
            margin: const EdgeInsets.only(left: 15, right: 15),
            child: Center(
                child: Column(
              children: [
                CircleAvatar(
                    backgroundImage: NetworkImage(user_image_cont.text),
                    radius: 100),
                const SizedBox(height: 20),
                TextField(
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(), labelText: 'Full Name'),
                  controller: full_name_cont,
                  onChanged: (v) {
                    print(full_name_cont.text);
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(), labelText: 'Email'),
                  controller: email_cont,
                  enabled: false,
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(), labelText: 'Photo URL'),
                  controller: user_image_cont,
                  onSubmitted: (v) {
                    setState(() {
                      user_image_cont.text = v;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(onPressed: () {
                      UpdateUser();
                    }, child: const Text("Submit"))
                  ],
                ),
              ],
            ))));
  }
}
