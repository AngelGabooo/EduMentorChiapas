// domain/models/student_grade_model.dart
enum PeriodType { semestre, cuatrimestre }

class StudentPartialGrades {
  final String studentEmail;
  double parcial1;
  double parcial2;
  double parcial3;

  StudentPartialGrades({
    required this.studentEmail,
    this.parcial1 = 0.0,
    this.parcial2 = 0.0,
    this.parcial3 = 0.0,
  });

  double get promedio => (parcial1 + parcial2 + parcial3) / 3;

  bool get aprobado => promedio >= 70;

  Map<String, dynamic> toJson() => {
    'studentEmail': studentEmail,
    'parcial1': parcial1,
    'parcial2': parcial2,
    'parcial3': parcial3,
  };

  factory StudentPartialGrades.fromJson(Map<String, dynamic> json) {
    return StudentPartialGrades(
      studentEmail: json['studentEmail'] ?? '',
      parcial1: (json['parcial1'] ?? 0.0).toDouble(),
      parcial2: (json['parcial2'] ?? 0.0).toDouble(),
      parcial3: (json['parcial3'] ?? 0.0).toDouble(),
    );
  }

  StudentPartialGrades copyWith({
    double? parcial1,
    double? parcial2,
    double? parcial3,
  }) {
    return StudentPartialGrades(
      studentEmail: studentEmail,
      parcial1: parcial1 ?? this.parcial1,
      parcial2: parcial2 ?? this.parcial2,
      parcial3: parcial3 ?? this.parcial3,
    );
  }
}