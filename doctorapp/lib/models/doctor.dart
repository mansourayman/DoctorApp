class Doctor {
  final int id;
  final Map user;
  final String? specialization;
  final String? bio;
  final double? averageRating;

  Doctor({
    required this.id,
    required this.user,
    this.specialization,
    this.bio,
    this.averageRating,
  });

  factory Doctor.fromJson(Map<String, dynamic> j) => Doctor(
    id: j['id'],
    user: j['user'] ?? {},
    specialization: j['specialization'],
    bio: j['bio'],
    averageRating: (j['average_rating'] != null)
        ? double.tryParse(j['average_rating'].toString())
        : 0.0,
  );
}
