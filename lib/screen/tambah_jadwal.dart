// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'dart:convert';
import 'package:dolan_yuk/class/dolanan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TambahJadwal extends StatefulWidget {
  const TambahJadwal({super.key});

  @override
  State<StatefulWidget> createState() => TambahJadwalState();
}

class TambahJadwalState extends State<TambahJadwal> {
  final formKey = GlobalKey<FormState>();

  final ButtonStyle JadwalBtnStyle =
      ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange);

  int user_id = 0;
  int jadwal_id = 0;
  int selectedDolanan = 1;
  int minimalMember = 1;
  String nama_dolanan = "Dolan X";
  String lokasi = "";
  String alamat = "";

  TextEditingController _minimalMember = TextEditingController();
  TextEditingController tanggal = TextEditingController();
  TextEditingController jam = TextEditingController();

  void setValues(int v) {
    nama_dolanan = "Dolan ${dolanans[v - 1].nama}";
    minimalMember = dolanans[v - 1].minimal_member;
    _minimalMember.text = dolanans[v - 1].minimal_member.toString();
  }

  List<Dolanan> dolanans = [];

  Widget comboDolanan = Text('tambah genre');

  @override
  void initState() {
    super.initState();
    getUserId();
    fetchDolanan();
  }

  void addJadwal() async {
    final response = await http.post(
        Uri.parse(
            "https://ubaya.me/flutter/160420033/dolanyuk_api/add_jadwal.php"),
        body: {
          'nama': nama_dolanan,
          'dolanan_id': selectedDolanan.toString(),
          'tanggal': tanggal.text,
          'jam': jam.text,
          'lokasi': lokasi,
          'alamat': alamat,
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == "success") {
        jadwal_id = json['jadwal_id'];
        final response2 = await http.post(
            Uri.parse(
                "https://ubaya.me/flutter/160420033/dolanyuk_api/enroll_user.php"),
            body: {
              'user_id': user_id.toString(),
              'jadwal_id': jadwal_id.toString(),
              'role': "Host",
            });
        if (response2.statusCode == 200) {
          Map json2 = jsonDecode(response2.body);
          if (json2['result'] == "success") {
            if (mounted) {
              showDialog<String>(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title: Text(
                          'Berhasil',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                            'Berhasil buat jadwal, silahkan tunggu pemain untuk mendaftar'),
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
          }
        }
      }
    }
  }

  void getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getInt("user_id") ?? 0;
    });
  }

  void fetchDolanan() async {
    final response = await http.get(Uri.parse(
        'https://ubaya.me/flutter/160420033/dolanyuk_api/get_dolanan.php'));
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      List<dynamic> data = json['data'];
      setState(() {
        dolanans = data.map((item) => Dolanan.fromJson(item)).toList();
        setValues(selectedDolanan);
      });
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buat Jadwal"),
      ),
      body: SingleChildScrollView(
          child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
              child: Text('Bikin jadwal dolanmu yuk!'),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Tanggal Dolan',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today)),
                  controller: tanggal,
                  onTap: () {
                    showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2200))
                        .then((value) {
                      setState(() {
                        if (value != null) {
                          tanggal.text = value.toString().substring(0, 10);
                        } else {
                          tanggal.text =
                              DateTime.now().toString().substring(0, 10);
                        }
                      });
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Tanggal dolan harus diisi";
                    }
                    return null;
                  },
                )),
            Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Waktu Dolan',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.schedule)),
                  controller: jam,
                  onTap: () {
                    showTimePicker(
                            initialEntryMode: TimePickerEntryMode.dialOnly,
                            context: context,
                            initialTime: TimeOfDay.now())
                        .then((value) {
                      if (value != null) {
                        final formattedString =
                            '${value.hour}:${value.minute.toString().padLeft(2, '0')}:00';
                        setState(() {
                          jam.text = formattedString;
                        });
                      }
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Jam dolan harus diisi";
                    } else {
                      return null;
                    }
                  },
                )),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Lokasi Dolan',
                  hintText: 'contoh: Starbucks, McDonalds, Cafe Cozy',
                ),
                onChanged: (value) {
                  lokasi = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Lokasi wajib diisi';
                  } else {
                    return null;
                  }
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Alamat Dolan',
                ),
                onChanged: (value) {
                  alamat = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Alamat wajib diisi';
                  } else {
                    return null;
                  }
                },
              ),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Container(
                  
                  child: dolanans.isEmpty
                      ? CircularProgressIndicator()
                      : DropdownMenu(
                          label: Text('Dolan Utama'),
                          initialSelection: dolanans.first.id,
                          onSelected: (value) {
                            setState(() {
                              selectedDolanan = value!;
                              setValues(value);
                            });
                          },
                          dropdownMenuEntries: dolanans.map((e) {
                            return DropdownMenuEntry(
                                value: e.id, label: e.nama);
                          }).toList(),
                        ),
                )),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Minimal member',
                ),
                controller: _minimalMember,
                onChanged: (value) {
                  _minimalMember.text = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Minimal member wajib diisi';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      style: JadwalBtnStyle,
                      onPressed: () {
                        if (formKey.currentState != null &&
                            !formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Harap isian diperbaiki')));
                        } else {
                          addJadwal();
                        }
                      },
                      child: Text(
                        'Buat Jadwal',
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
