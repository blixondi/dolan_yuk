// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';

import 'package:dolan_yuk/class/chats.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class Chat_Screen extends StatefulWidget {
  int id_jadwal;

  Chat_Screen({required this.id_jadwal});

  @override
  State<StatefulWidget> createState() => _ChatState();
}

int new_chat = 0;

class _ChatState extends State<Chat_Screen> {
  final TextEditingController sendController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<Chats> chats = [];
  int user_id = 0;
  String nama_user = "";
  String user_image = "";
  bool trigger_untuk_scroll = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    fetchDataAndPopulateChats();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      bacaData();
    });
    Timer(Duration(milliseconds: 500), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    });
  }

  fetchDataAndPopulateChats() async {
    await getUser();
    await bacaData();
  }

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getInt("user_id") ?? 0;
      nama_user = prefs.getString("full_name") ?? "";
      user_image = prefs.getString("user_image") ?? "";
    });
  }

  Future<String> fetchData() async {
    final response = await http.post(
      Uri.parse("https://ubaya.me/flutter/160420033/dolanyuk_api/get_chat.php"),
      body: {'id_jadwal': widget.id_jadwal.toString()},
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaData() async {
    // chats.clear();
    try {
      final data = await fetchData();
      Map<String, dynamic> json = jsonDecode(data);
      if (json['data'] != null) {
        setState(() {
          List<dynamic> jsonData = json['data'];
          var temp = jsonData.map((item) => Chats.fromJson(item)).toList();
          if (chats.length != temp.length &&
              scrollController.position.pixels <=
                  scrollController.position.maxScrollExtent) {
            trigger_untuk_scroll = true;
            new_chat += temp.length - chats.length;
            for (var i = chats.length; i < temp.length; i++) {
              chats.add(temp[i]);
            }
          }
          //ketika posisinya sudah dipaling bawah, dan ada chat yang masuk, dia otomatis scroll ke paling bawah lagi
          //kenapa ga else if? karena kalau pakai else if, ketika load data di awal, fab nya bakal muncul karena layar belum discroll sampai paling bawah
          if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent) {
            new_chat = 0;
            trigger_untuk_scroll = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              scrollController
                  .jumpTo(scrollController.position.maxScrollExtent);
            });
          }
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
      // Handle the error
    }
  }

  Widget makeChat(int index) {
    bool isMe = false;
    if (chats[index].user_id == user_id) {
      isMe = true;
    }
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isMe ? Colors.blue : Colors.green;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Container(
              margin: const EdgeInsets.only(right: 16.0, left: 16.0),
              child: CircleAvatar(
                child: Image(image: NetworkImage(chats[index].photo)),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: alignment,
              children: [
                Text(chats[index].nama,
                    style: Theme.of(context).textTheme.subtitle1),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      topLeft:
                          isMe ? Radius.circular(16.0) : Radius.circular(0.0),
                      topRight:
                          isMe ? Radius.circular(0.0) : Radius.circular(16.0),
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
                  ),
                  child: Text(
                    "${chats[index].pesan}\n${chats[index].jam}",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (isMe)
            Container(
              margin: const EdgeInsets.only(right: 16.0, left: 16.0),
              child: CircleAvatar(
                child: Image(image: NetworkImage(chats[index].photo)),
              ),
            ),
        ],
      ),
    );
  }

  void kirimChat(String text) async {
    final response = await http.post(
        Uri.parse(
            "https://ubaya.me/flutter/160420033/dolanyuk_api/add_chat.php"),
        body: {
          'user_id': user_id.toString(),
          'jadwal_id': widget.id_jadwal.toString(),
          'pesan': sendController.text,
          'jam': DateTime.now().toString().substring(0, 19),
        });
    if (response.statusCode == 200) {
      print("berhasil");
      setState(() {
        // bacaData();
        chats.add(Chats(
            user_id: user_id,
            jadwal_id: widget.id_jadwal,
            nama: nama_user,
            pesan: sendController.text,
            jam: DateTime.now().toString().substring(0, 19),
            photo: user_image));
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
      //ini ada lagi karena kalau cuma pake yang diatas, mentoknya cuma di 1 chat sebelum yang terakhir (bukan yang betul betul paling bawah)
      Timer(Duration(milliseconds: 300), () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        });
      });
    }
    sendController.clear();
  }

  @override
  Widget build(BuildContext context) {
    //willpopscope itu kode untuk tombol back di app bar
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Party Chat"),
          ),
          floatingActionButton: SizedBox(
              width: 150,
              child: trigger_untuk_scroll
                  ? FloatingActionButton(
                      onPressed: () {
                        trigger_untuk_scroll = false;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          scrollController.jumpTo(
                              scrollController.position.maxScrollExtent);
                        });
                        //ini ada lagi karena kalau cuma pake yang diatas, mentoknya cuma di 1 chat sebelum yang terakhir (bukan yang betul betul paling bawah)
                        Timer(Duration(milliseconds: 300), () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            scrollController.jumpTo(
                                scrollController.position.maxScrollExtent);
                          });
                        });
                      },
                      backgroundColor: Colors.green,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.arrow_downward),
                          SizedBox(
                            width: 8,
                          ),
                          Text('$new_chat New Chat')
                        ],
                      ),
                    )
                  : null),
          body: Column(
            children: [
              Flexible(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: chats.length,
                  itemBuilder: (_, int index) => makeChat(index),
                ),
              ),
              Divider(height: 1.0),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: IconTheme(
                  data: IconThemeData(color: Colors.blue),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Flexible(
                          child: TextField(
                            controller: sendController,
                            onSubmitted: kirimChat,
                            decoration: InputDecoration.collapsed(
                              hintText: "Type your message",
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () => kirimChat(sendController.text),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        onWillPop: () async {
          //karena diawal menggunakan timer.periodic untuk refresh chat, pada saat tombol back dipencet, timer auto refreshnya dimatikan.
          timer.cancel();
          return true;
        });
  }
}
