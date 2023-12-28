// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:dolan_yuk/class/jadwal.dart';
import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:dolan_yuk/class/member.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Cari extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CariState();
}

class _CariState extends State<Cari> {
  List<Jadwal> jadwals = [];
  int user_id = 0;
  String temp = "";
  String cari = "";

  @override
  void initState() {
    super.initState();
    // getUserId();
    // bacaData();
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
            "https://ubaya.me/flutter/160420033/dolanyuk_api/cari_jadwal.php"),
        body: {'user_id': user_id.toString(), 'cari': cari});
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
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Image.network(
                      jadwals[index].gambar,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      height: 160,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(30, 10, 15, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          jadwals[index].nama,
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        Text(jadwals[index].tanggal),
                        Text(jadwals[index].jam),
                        OutlinedButton(
                          onPressed: () {
                            showMember(jadwals[index].id);
                          },
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
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
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 30, 10),
                    child: Row(
                      children: <Widget>[
                        Spacer(),
                        ElevatedButton(
                            onPressed: () {},
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.login),
                                Text('Join')
                              ],
                            ))
                      ],
                    ),
                  ),
                  Container(
                    height: 10,
                  )
                ],
              ),
            );
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

  //list di dalam dialog
  Future<List<Member>> getMember(int id_jadwal) async {
    List<Member> members = [];
    final response = await http.post(
      Uri.parse(
          "https://ubaya.me/flutter/160420033/dolanyuk_api/member_jadwal.php"),
      body: {'id_jadwal': id_jadwal.toString()},
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      List<dynamic> data = json['data'];
      members = data.map((item) => Member.fromJson(item)).toList();
      return members;
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget dialogList(List<Member> members) {
    var extra = "";
    return Container(
      width: double.maxFinite,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: members.length,
        itemBuilder: (BuildContext context, int index) {
          if (members[index].id == user_id) {
            extra = " (You)";
          } else {
            extra = "";
          }
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(members[index].image),
            ),
            title: Text(members[index].nama + extra),
            subtitle: Text(members[index].role),
          );
        },
      ),
    );
  }

  void showMember(int id_jadwal) {
    getMember(id_jadwal).then((members) {
      if (members.isNotEmpty) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text("Konco Dolanan"),
            content: dialogList(members),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Keren!'),
              ),
            ],
          ),
        );
      } else {
        print('Members empty');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            decoration: InputDecoration(
                hintText: 'Cari Dolanan...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0))),
            onChanged: (v) {
              setState(() {
                cari = v;
                bacaData();
              });
            },
          )),
      Expanded(
        child: jadwals.isEmpty
            ? Center(
                child: listJadwal(jadwals),
              )
            : Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: listJadwal(jadwals)),
              ),
      )
    ]));
  }
}
