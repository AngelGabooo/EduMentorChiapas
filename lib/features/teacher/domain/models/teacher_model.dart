class TeacherModel {
  final String email;
  final String password;
  final String name;
  final List<String> subjects;
  final List<String> languages;
  final String registrationNumber;
  final String userType;

  TeacherModel({
    required this.email,
    required this.password,
    required this.name,
    required this.subjects,
    required this.languages,
    required this.registrationNumber,
    this.userType = 'teacher',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'subjects': subjects,
      'languages': languages,
      'registrationNumber': registrationNumber,
      'userType': userType,
    };
  }

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      name: json['name'] ?? '',
      subjects: List<String>.from(json['subjects'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      registrationNumber: json['registrationNumber'] ?? '',
      userType: json['userType'] ?? 'teacher',
    );
  }
}