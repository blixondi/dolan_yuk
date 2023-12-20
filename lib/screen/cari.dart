import 'package:flutter/material.dart';

class Cari extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CariState();
}

class _CariState extends State<Cari> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Cari'),
        ),
        body: Center(child: Text("Cari")));
  }
}
