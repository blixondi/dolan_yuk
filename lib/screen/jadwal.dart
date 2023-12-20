import 'package:flutter/material.dart';

class Jadwal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _JadwalState();
}

class _JadwalState extends State<Jadwal> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Jadwal'),
        ),
        body: Center(child: Text("Jadwal")));
  }
}
