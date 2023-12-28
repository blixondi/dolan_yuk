class Jadwal {
  int id;
  String nama;
  String tanggal;
  String jam;
  String lokasi;
  String alamat;
  String gambar;
  int minimalMember;
  int currentMember;

  Jadwal({
    required this.id,
    required this.nama,
    required this.tanggal,
    required this.jam,
    required this.lokasi,
    required this.alamat,
    required this.gambar,
    required this.minimalMember,
    required this.currentMember,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      id: json['id'] as int,
      nama: json['nama'] as String,
      tanggal: json['tanggal'] as String,
      jam: json['jam'] as String,
      lokasi: json['lokasi'] as String,
      alamat: json['alamat'] as String,
      gambar: json['gambar'] as String,
      minimalMember: json['minimal_member'] as int,
      currentMember: json['currentMember'] as int,
    );
  }
}
