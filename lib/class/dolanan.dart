class Dolanan {
  int id;
  String nama;
  int minimal_member;

  Dolanan({
    required this.id,
    required this.nama,
    required this.minimal_member,
  });
  factory Dolanan.fromJson(Map<String, dynamic> json) {
    return Dolanan(
      id: json['id'] as int,
      minimal_member: json['minimal_member'] as int,
      nama: json['nama'] as String,
    );
  }
}