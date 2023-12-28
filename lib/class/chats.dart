class Chats {
  int id;
  int user_id;
  int jadwal_id;
  String nama;
  String pesan;
  String jam;
  String photo;

  Chats({
    required this.id,
    required this.user_id,
    required this.jadwal_id,
    required this.nama,
    required this.pesan,
    required this.jam,
    required this.photo,
  });
  factory Chats.fromJson(Map<String, dynamic> json) {
    return Chats(
      id: json['id'] as int,
      user_id: json['user_id'] as int,
      jadwal_id: json['jadwal_id'] as int,
      nama: json['full_name'] as String,
      pesan: json['pesan'] as String,
      jam: json['jam'] as String,
      photo: json['image'] as String,
    );
  }
}
