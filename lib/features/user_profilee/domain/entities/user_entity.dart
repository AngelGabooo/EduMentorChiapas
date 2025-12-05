class UserEntity {
  final String name;
  final String avatar;
  final int level;
  final int points;
  final String language;
  final String educationLevel;
  final String community;
  final List<String> favoriteSubjects;
  final Map<String, dynamic> recentActivity;
  final List<Map<String, dynamic>> weeklyActivity;

  UserEntity({
    required this.name,
    required this.avatar,
    required this.level,
    required this.points,
    required this.language,
    required this.educationLevel,
    required this.community,
    required this.favoriteSubjects,
    required this.recentActivity,
    required this.weeklyActivity,
  });

  // Método para crear una copia con nuevos valores (útil para edición)
  UserEntity copyWith({
    String? name,
    String? avatar,
    String? language,
    String? educationLevel,
    List<String>? favoriteSubjects,
  }) {
    return UserEntity(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      level: level,
      points: points,
      language: language ?? this.language,
      educationLevel: educationLevel ?? this.educationLevel,
      community: community,
      favoriteSubjects: favoriteSubjects ?? this.favoriteSubjects,
      recentActivity: recentActivity,
      weeklyActivity: weeklyActivity,
    );
  }
}