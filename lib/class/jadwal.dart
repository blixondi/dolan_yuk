class Jadwal {
  int id;
  int dolanan_id;
  String tanggal;
  String jam;
  String lokasi;

  Jadwal(
      {required this.id,
      required this.dolanan_id,
      required this.tanggal,
      required this.jam,
      required this.lokasi});
  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
        id: json['id'] as int,
        dolanan_id: json['dolanan_id'] as int,
        tanggal: json['tanggal'] as String,
        jam: json['jam'] as String,
        lokasi: json['lokasi'] as String);
  }
}

//List<Jadwal> jadwals = [];
