class ProfileEntity {
  final String? id;
  final String userId;
  final DateTime birthDate;
  final EducationLevel educationLevel;
  final String currentGrade;
  final String municipality;
  final String schoolName;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileEntity({
    this.id,
    required this.userId,
    required this.birthDate,
    required this.educationLevel,
    required this.currentGrade,
    required this.municipality,
    required this.schoolName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Método para calcular la edad
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

enum EducationLevel {
  primary('Primaria'),
  secondary('Secundaria'),
  highSchool('Preparatoria'),
  university('Universidad');

  const EducationLevel(this.displayName);
  final String displayName;

  static EducationLevel fromString(String value) {
    return EducationLevel.values.firstWhere(
          (e) => e.displayName == value,
      orElse: () => EducationLevel.primary,
    );
  }
}