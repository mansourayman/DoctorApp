class User {
  final int id;
  final String fullName;
  final String email;

  User({required this.id, required this.fullName, required this.email});

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['id'],
    fullName: j['full_name'] ?? j['fullName'] ?? '',
    email: j['email'],
  );
}
