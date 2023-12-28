// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:dolan_yuk/class/jadwal.dart';
import 'package:dolan_yuk/screen/tambah_jadwal.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Jadwal_Screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _JadwalState();
}

class _JadwalState extends State<Jadwal_Screen> {
  List<Jadwal> jadwals = [];
  int user_id = 0;
  String temp = "";

  @override
  void initState() {
    super.initState();
    fetchDataAndPopulateJadwals();
  }

  fetchDataAndPopulateJadwals() async {
    await getUserId(); // Wait for user ID retrieval
    await bacaData(); // Fetch data and populate jadwals list
  }

  getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getInt("user_id") ?? 0;
    });
  }

  Future<String> fetchData() async {
    final response = await http.post(
      Uri.parse(
          "https://ubaya.me/flutter/160420033/dolanyuk_api/get_jadwal.php"),
      body: {'user_id': user_id.toString()},
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaData() async {
    jadwals.clear();
    try {
      final data = await fetchData();
      Map<String, dynamic> json = jsonDecode(data);
      if (json['data'] != null) {
        List<dynamic> jsonData = json['data'];
        jadwals = jsonData.map((item) => Jadwal.fromJson(item)).toList();
        setState(() {
          temp = jadwals.isNotEmpty ? jadwals[0].nama : ''; // Update temp
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
      // Handle the error
    }
  }

  Widget listJadwal(jadwals) {
    if (jadwals.isNotEmpty) {
      return ListView.builder(
          itemCount: jadwals.length,
          itemBuilder: (BuildContext cxt, int index) {
            return Card(
                child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: Image.network(jadwals[index].gambar),
                  ),
                  Text(jadwals[index].nama),
                  Text(jadwals[index].tanggal),
                  Text(jadwals[index].jam),
                  OutlinedButton(
                    onPressed: () {},
                    child:
                        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      Icon(Icons.person),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                          "${jadwals[index].currentMember} / ${jadwals[index].minimalMember} orang")
                    ]),
                  ),
                  Text(jadwals[index].lokasi),
                  Text(jadwals[index].alamat),
                  ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[Icon(Icons.login), Text('Join')],
                      ))
                ],
              ),
            ));
          });
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
            child: Center(
              child: Text('Jadwal main masih kosong nih'),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
            child: Center(
              child: Text('Cari konco main atau bikin jadwal baru aja'),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => TambahJadwal()));
        },
        child: Icon(Icons.edit),
        backgroundColor: Colors.deepOrange,
      ),
      body: jadwals.isEmpty
          ? Center(
              child: listJadwal(jadwals),
            )
          : Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  child: listJadwal(jadwals)),
            ),
    );
  }
}
