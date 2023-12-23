// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:dolan_yuk/screen/tambah_jadwal.dart';
import 'package:flutter/material.dart';

class Jadwal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _JadwalState();
}

class _JadwalState extends State<Jadwal> {
  List<Jadwal> jadwals = [];

  @override
  void initState() {
    super.initState();
  }

  Widget listJadwal(jadwals) {
    if (jadwals.isNotEmpty) {
      return Text('aaaaa');
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
          : SingleChildScrollView(
              child: listJadwal(jadwals),
            ),
    );
  }
}
