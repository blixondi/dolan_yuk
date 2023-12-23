// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'dart:convert';
import 'package:dolan_yuk/class/dolanan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TambahJadwal extends StatefulWidget {
  const TambahJadwal({super.key});

  @override
  State<StatefulWidget> createState() => TambahJadwalState();
}

class TambahJadwalState extends State<TambahJadwal> {
  int user_id = 0;
  int selectedDolanan = 0;

  Widget comboDolanan = Text('tambah genre');

  @override
  void initState() {
    super.initState();
    getUserId();
    setState(() {
      generateComboBox();
    });
  }

  void getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getInt("user_id") ?? 0;
    });
  }

  Future fetchDolanan() async {
    Map json;
    final response = await http.get(Uri.parse(
        'https://ubaya.me/flutter/160420033/dolanyuk_api/get_dolanan.php'));
    if (response.statusCode == 200) {
      json = jsonDecode(response.body);
      return json['data'];
    } else {
      throw Exception('Failed to read API');
    }
  }

  void generateComboBox() {
    List<Dolanan> dolanans;
    var data = fetchDolanan();
    data.then((value) {
      dolanans = List<Dolanan>.from(value.map((i) {
        return Dolanan.fromJson(i);
      }));
      comboDolanan = DropdownButton(
          dropdownColor: Colors.grey[100],
          hint: Text("Pilih Dolanan"),
          isDense: false,
          items: dolanans.map((e) {
            return DropdownMenuItem(
              child: Column(children: <Widget>[
                Text(e.nama, overflow: TextOverflow.visible),
              ]),
              value: e.id,
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedDolanan = value!;
            });
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buat Jadwal"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [Text(user_id.toString()), comboDolanan],
        ),
      ),
    );
  }
}
