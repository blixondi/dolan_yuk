class Member {
  int id;
  String nama;
  String image;
  String role;

  Member({
    required this.id,
    required this.nama,
    required this.image,
    required this.role,
  });
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as int,
      nama: json['full_name'] as String,
      image: json['image'] as String,
      role: json['role'] as String,
    );
  }
}
