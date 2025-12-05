class ClassModel {
  final String id;
  final String name;
  final String subject;
  final String accessCode;
  final List<String> students;
  final String teacherEmail;
  final DateTime createdAt;
  final String? description;
  final String? section;
  final String? room;

  ClassModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.accessCode,
    this.students = const [],
    required this.teacherEmail,
    required this.createdAt,
    this.description,
    this.section,
    this.room,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'accessCode': accessCode,
      'students': students,
      'teacherEmail': teacherEmail,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'section': section,
      'room': room,
    };
  }

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      subject: json['subject'] ?? '',
      accessCode: json['accessCode'] ?? '',
      students: List<String>.from(json['students'] ?? []),
      teacherEmail: json['teacherEmail'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      description: json['description'],
      section: json['section'],
      room: json['room'],
    );
  }

  ClassModel copyWith({
    String? name,
    String? subject,
    String? description,
    String? section,
    String? room,
  }) {
    return ClassModel(
      id: id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      accessCode: accessCode,
      students: students,
      teacherEmail: teacherEmail,
      createdAt: createdAt,
      description: description ?? this.description,
      section: section ?? this.section,
      room: room ?? this.room,
    );
  }
}

// domain/models/class_model.dart (reemplaza la clase ClassMaterial)

enum ClassMaterialType {
  document,
  assignment,
  announcement,
  link,
  video,
}

class ClassMaterial {
  final String id;
  final String classId;
  final String title;
  final String description;
  final ClassMaterialType type;
  final String? filePath;      // <-- CAMBIO: ahora es ruta local
  final String? fileName;
  final String? fileType;
  final DateTime createdAt;
  final String createdBy;

  ClassMaterial({
    required this.id,
    required this.classId,
    required this.title,
    required this.description,
    required this.type,
    this.filePath,
    this.fileName,
    this.fileType,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'classId': classId,
    'title': title,
    'description': description,
    'type': type.toString().split('.').last,
    'filePath': filePath,
    'fileName': fileName,
    'fileType': fileType,
    'createdAt': createdAt.toIso8601String(),
    'createdBy': createdBy,
  };

  factory ClassMaterial.fromJson(Map<String, dynamic> json) {
    return ClassMaterial(
      id: json['id'] ?? '',
      classId: json['classId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: ClassMaterialType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'],
        orElse: () => ClassMaterialType.document,
      ),
      filePath: json['filePath'],
      fileName: json['fileName'],
      fileType: json['fileType'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      createdBy: json['createdBy'] ?? '',
    );
  }
}