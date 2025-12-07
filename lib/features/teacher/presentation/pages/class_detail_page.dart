// features/teacher/presentation/pages/class_detail_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../domain/models/class_model.dart';
import '../../../../config/theme/app_theme.dart';

// ==================== MODELO DE CALIFICACIONES POR PARCIALES ====================
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

// ==================== TU CÓDIGO ORIGINAL + RESPUESTAS A COMENTARIOS ====================
class ClassDetailPage extends StatefulWidget {
  final ClassModel classModel;
  const ClassDetailPage({super.key, required this.classModel});
  @override
  State<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ClassMaterial> _materials = [];
  List<StudentPartialGrades> _grades = [];
  PeriodType _periodType = PeriodType.cuatrimestre;

  Map<String, Map<String, String>> _studentComments = {};
  Map<String, Map<String, String>> _studentSubmissions = {};
  Map<String, Map<String, double>> _taskGrades = {};

  late ClassModel _currentClassModel;

  String? _selectedStudentEmail;
  final TextEditingController _parcial1Controller = TextEditingController();
  final TextEditingController _parcial2Controller = TextEditingController();
  final TextEditingController _parcial3Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentClassModel = widget.classModel;
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _parcial1Controller.dispose();
    _parcial2Controller.dispose();
    _parcial3Controller.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadMaterials(),
      _loadPeriodType(),
      _loadGrades(),
      _loadStudentInteractions(),
      _updateEnrolledStudents(),
    ]);
  }

  Future<void> _updateEnrolledStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    Set<String> enrolledEmails = {};
    for (String key in keys) {
      if (key.startsWith('studentClasses_')) {
        final jsonStr = prefs.getString(key) ?? '[]';
        final List<dynamic> classes = json.decode(jsonStr);
        for (var c in classes) {
          final classModel = ClassModel.fromJson(c);
          if (classModel.id == _currentClassModel.id) {
            enrolledEmails.addAll(classModel.students);
          }
        }
      }
    }
    setState(() {
      _currentClassModel = _currentClassModel.copyWith(students: enrolledEmails.toList());
    });
  }

  Future<void> _loadMaterials() async {
    final prefs = await SharedPreferences.getInstance();
    final materialsJson = prefs.getString('classMaterials_${_currentClassModel.id}') ?? '[]';
    final List<dynamic> materialsList = json.decode(materialsJson);
    setState(() {
      _materials = materialsList.map((json) => ClassMaterial.fromJson(json)).toList();
    });
  }

  // CORREGIDO: error de flecha y paréntesis
  Future<void> _saveMaterials() async {
    final prefs = await SharedPreferences.getInstance();
    final materialsJson = json.encode(_materials.map((m) => m.toJson()).toList());
    await prefs.setString('classMaterials_${_currentClassModel.id}', materialsJson);
  }

  Future<void> _loadPeriodType() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('periodType_${_currentClassModel.id}');
    setState(() {
      _periodType = saved == 'semestre' ? PeriodType.semestre : PeriodType.cuatrimestre;
    });
  }

  Future<void> _savePeriodType(PeriodType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('periodType_${_currentClassModel.id}', type == PeriodType.semestre ? 'semestre' : 'cuatrimestre');
    setState(() => _periodType = type);
  }

  Future<void> _loadGrades() async {
    final prefs = await SharedPreferences.getInstance();
    final gradesJson = prefs.getString('partialGrades_${_currentClassModel.id}') ?? '[]';
    final List<dynamic> list = json.decode(gradesJson);
    setState(() {
      _grades = list.map((json) => StudentPartialGrades.fromJson(json)).toList();
      for (final student in _currentClassModel.students) {
        if (!_grades.any((g) => g.studentEmail == student)) {
          _grades.add(StudentPartialGrades(studentEmail: student));
        }
      }
    });
  }

  Future<void> _saveGrades() async {
    final prefs = await SharedPreferences.getInstance();
    final gradesJson = json.encode(_grades.map((g) => g.toJson()).toList());
    await prefs.setString('partialGrades_${_currentClassModel.id}', gradesJson);
  }

  void _updateGrade(String studentEmail, int parcial, double value) {
    final clamped = value.clamp(0.0, 100.0);
    setState(() {
      final index = _grades.indexWhere((g) => g.studentEmail == studentEmail);
      if (index != -1) {
        switch (parcial) {
          case 1:
            _grades[index] = _grades[index].copyWith(parcial1: clamped);
            break;
          case 2:
            _grades[index] = _grades[index].copyWith(parcial2: clamped);
            break;
          case 3:
            _grades[index] = _grades[index].copyWith(parcial3: clamped);
            break;
        }
        _saveGrades();
      }
    });
  }

  // CARGA TODOS LOS COMENTARIOS Y RESPUESTAS
  Future<void> _loadStudentInteractions() async {
    final prefs = await SharedPreferences.getInstance();
    _studentComments.clear();
    _studentSubmissions.clear();
    _taskGrades.clear();

    for (final material in _materials) {
      final String materialId = material.id;

      final commentsKey = 'comments_${_currentClassModel.id}_$materialId';
      final commentsJson = prefs.getString(commentsKey) ?? '{}';
      final Map<String, String> commentsMap = Map<String, String>.from(json.decode(commentsJson));

      final submissionsKey = 'submissions_${_currentClassModel.id}_$materialId';
      final submissionsJson = prefs.getString(submissionsKey) ?? '{}';
      final Map<String, String> submissionsMap = Map<String, String>.from(json.decode(submissionsJson));

      final gradesKey = 'task_grades_${_currentClassModel.id}_$materialId';
      final gradesJson = prefs.getString(gradesKey) ?? '{}';
      final Map<String, double> gradesMap = (json.decode(gradesJson) as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
      );

      setState(() {
        _studentComments[materialId] = commentsMap;
        _studentSubmissions[materialId] = submissionsMap;
        _taskGrades[materialId] = gradesMap;
      });
    }
  }

  Future<void> _saveTaskGrade(String materialId, String studentEmail, double grade) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'task_grades_${_currentClassModel.id}_$materialId';
    final current = _taskGrades[materialId] ?? {};
    current[studentEmail] = grade.clamp(0.0, 100.0);
    await prefs.setString(key, json.encode(current));
    setState(() => _taskGrades[materialId] = current);
  }

  // NUEVO: EL PROFESOR PUEDE RESPONDER A UN COMENTARIO
  void _replyToComment(String materialId, String studentEmail) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Responder a ${studentEmail.split('@').first}"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Escribe tu respuesta...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final reply = controller.text.trim();
              if (reply.isEmpty) return;

              final prefs = await SharedPreferences.getInstance();
              final key = 'comments_${_currentClassModel.id}_$materialId';
              final currentJson = prefs.getString(key) ?? '{}';
              final Map<String, dynamic> currentMap = json.decode(currentJson);

              currentMap['teacher_reply_$studentEmail'] = reply;

              await prefs.setString(key, json.encode(currentMap));

              setState(() {
                _studentComments[materialId]!['teacher_reply_$studentEmail'] = reply;
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Respuesta enviada"), backgroundColor: Colors.green),
              );
            },
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }

  void _addMaterial() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMaterialSheet(
        onMaterialAdded: (material) {
          setState(() {
            _materials.insert(0, material);
            _studentComments[material.id] = {};
            _studentSubmissions[material.id] = {};
            _taskGrades[material.id] = {};
          });
          _saveMaterials();
        },
        classId: _currentClassModel.id,
        teacherEmail: _currentClassModel.teacherEmail,
      ),
    );
  }

  Color _getClassColor(String className) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      Colors.purple,
      Colors.teal,
      Colors.orange,
      Colors.pink,
    ];
    final index = className.hashCode % colors.length;
    return colors[index];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _getMaterialIcon(ClassMaterialType type) {
    switch (type) {
      case ClassMaterialType.document: return Icons.description;
      case ClassMaterialType.assignment: return Icons.assignment;
      case ClassMaterialType.announcement: return Icons.announcement;
      case ClassMaterialType.link: return Icons.link;
      case ClassMaterialType.video: return Icons.video_library;
      default: return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final randomColor = _getClassColor(_currentClassModel.name);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: randomColor,
            elevation: 0,
            title: const SizedBox.shrink(),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [randomColor, randomColor.withOpacity(0.85)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 90, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        Text(
                        _currentClassModel.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentClassModel.subject,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_currentClassModel.section != null)
                  Text(
                'Sección ${_currentClassModel.section!}',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.vpn_key, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            _currentClassModel.accessCode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _periodType == PeriodType.semestre
                            ? Colors.blue.shade700
                            : Colors.green.shade700,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _periodType == PeriodType.semestre ? 'Semestre' : 'Cuatrimestre',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                ],
                ),
              ),
            ),
          ),
          ),
          actions: [
          IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: _showPeriodSelector,
          tooltip: 'Configurar periodo',
          ),
          ],
          ),
          SliverPersistentHeader(
          delegate: _SliverAppBarDelegate(
          TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          labelPadding: const EdgeInsets.symmetric(vertical: 14),
          tabs: const [
          Tab(text: 'Muro'),
          Tab(text: 'Personas'),
          Tab(text: 'Calificaciones'),
          Tab(text: 'Contenido'),
          ],
          ),
          ),
          pinned: true,
          ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildWallTab(),
            _buildPeopleTab(),
            _buildGradesTab(),
            _buildContentTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMaterial,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Agregar Material',
      ),
    );
  }

  // EL RESTO DEL CÓDIGO QUEDA 100% IGUAL (sin tocar nada más)
  void _showPeriodSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Periodo Académico'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<PeriodType>(
              title: const Text('Cuatrimestre'),
              value: PeriodType.cuatrimestre,
              groupValue: _periodType,
              onChanged: (val) {
                _savePeriodType(val!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<PeriodType>(
              title: const Text('Semestre'),
              value: PeriodType.semestre,
              groupValue: _periodType,
              onChanged: (val) {
                _savePeriodType(val!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  Widget _buildGradesTab() {
    if (_currentClassModel.students.isEmpty) {
      return const Center(child: Text('No hay alumnos inscritos', style: TextStyle(fontSize: 16, color: Colors.grey)));
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Seleccionar alumno", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedStudentEmail,
                    hint: const Text("Elige un alumno"),
                    items: _currentClassModel.students.map((email) {
                      return DropdownMenuItem(
                        value: email,
                        child: Text(email.split('@').first),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStudentEmail = value;
                        final grade = _grades.firstWhere(
                              (g) => g.studentEmail == value,
                          orElse: () => StudentPartialGrades(studentEmail: value!),
                        );
                        _parcial1Controller.text = grade.parcial1 > 0 ? grade.parcial1.toStringAsFixed(1) : '';
                        _parcial2Controller.text = grade.parcial2 > 0 ? grade.parcial2.toStringAsFixed(1) : '';
                        _parcial3Controller.text = grade.parcial3 > 0 ? grade.parcial3.toStringAsFixed(1) : '';
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_selectedStudentEmail != null) ...[
                    const Text("Calificaciones", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    _buildPartialInput("1er Parcial", _parcial1Controller, 1),
                    _buildPartialInput("2do Parcial", _parcial2Controller, 2),
                    _buildPartialInput("3er Parcial", _parcial3Controller, 3),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        final p1 = double.tryParse(_parcial1Controller.text) ?? 0.0;
                        final p2 = double.tryParse(_parcial2Controller.text) ?? 0.0;
                        final p3 = double.tryParse(_parcial3Controller.text) ?? 0.0;
                        _updateGrade(_selectedStudentEmail!, 1, p1);
                        _updateGrade(_selectedStudentEmail!, 2, p2);
                        _updateGrade(_selectedStudentEmail!, 3, p3);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Calificaciones guardadas"), backgroundColor: Colors.green),
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("Guardar calificaciones"),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _grades.length,
              itemBuilder: (context, index) {
                final grade = _grades[index];
                final name = grade.studentEmail.split('@').first;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: grade.aprobado ? Colors.green : Colors.red,
                      child: Text(grade.promedio.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(grade.studentEmail),
                    trailing: Text(grade.aprobado ? "Aprobado" : "Reprobado", style: TextStyle(color: grade.aprobado ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartialInput(String label, TextEditingController controller, int parcial) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: '0 - 100',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => controller.clear(),
          ),
        ),
      ),
    );
  }

  // === MURO CON RESPUESTAS DEL PROFESOR ===
  Widget _buildWallTab() {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _materials.length,
        itemBuilder: (context, index) {
          final material = _materials[index];
          final comments = _studentComments[material.id] ?? {};
          final submissions = _studentSubmissions[material.id] ?? {};
          final grades = _taskGrades[material.id] ?? {};

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Icon(_getMaterialIcon(material.type), size: 20, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(material.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            Text(_formatDate(material.createdAt), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (material.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(material.description),
                  ],
                  if (material.filePath != null && material.fileName != null)
                    FutureBuilder<bool>(
                      future: File(material.filePath!).exists(),
                      builder: (context, snapshot) => snapshot.data == true
                          ? ListTile(leading: const Icon(Icons.attachment), title: Text(material.fileName!), onTap: () => OpenFile.open(material.filePath!))
                          : const Text("Archivo no disponible", style: TextStyle(color: Colors.red)),
                    ),

                  // === COMENTARIOS CON RESPUESTA DEL PROFESOR ===
                  if (comments.isNotEmpty) ...[
                    const Divider(),
                    const Text("Comentarios:", style: TextStyle(fontWeight: FontWeight.bold)),
                    ...comments.entries.map((entry) {
                      final email = entry.key;
                      final comment = entry.value;

                      // Si es respuesta del profesor
                      if (email.startsWith('teacher_reply_')) {
                        final originalEmail = email.replaceFirst('teacher_reply_', '');
                        return Padding(
                          padding: const EdgeInsets.only(left: 40, top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.reply, size: 18, color: AppTheme.primaryColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Respuesta del profesor", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                                      const SizedBox(height: 4),
                                      Text(comment),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Comentario normal del alumno
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child: Text(email[0].toUpperCase(), style: TextStyle(color: Colors.grey[800])),
                        ),
                        title: Text(email.split('@').first, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(comment),
                        trailing: IconButton(
                          icon: const Icon(Icons.reply, color: AppTheme.primaryColor),
                          onPressed: () => _replyToComment(material.id, email),
                          tooltip: 'Responder',
                        ),
                      );
                    }).toList(),
                  ],

                  if (material.type == ClassMaterialType.assignment && submissions.isNotEmpty) ...[
                    const Divider(),
                    const Text("Tareas entregadas:", style: TextStyle(fontWeight: FontWeight.bold)),
                    ...submissions.entries.map((e) {
                      final studentEmail = e.key;
                      final fileName = e.value;
                      final currentGrade = grades[studentEmail] ?? 0.0;
                      return ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: Text(studentEmail.split('@').first),
                        subtitle: Text("Archivo: $fileName"),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              Text(currentGrade > 0 ? currentGrade.toStringAsFixed(1) : "--", style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () => _showGradeDialog(material.id, studentEmail, currentGrade),
                              ),
                            ],
                          ),
                        ),
                        onTap: () async {
                          final path = '${(await getApplicationDocumentsDirectory()).path}/student_submissions/${_currentClassModel.id}_${material.id}_${studentEmail}_$fileName';
                          final file = File(path);
                          if (await file.exists()) OpenFile.open(path);
                        },
                      );
                    }),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showGradeDialog(String materialId, String studentEmail, double currentGrade) {
    final controller = TextEditingController(text: currentGrade > 0 ? currentGrade.toStringAsFixed(1) : '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Calificar tarea"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Nota (0-100)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              final grade = double.tryParse(controller.text) ?? 0.0;
              _saveTaskGrade(materialId, studentEmail, grade);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Calificación guardada: $grade")));
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  Widget _buildPeopleTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profesor', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListTile(
                  leading: CircleAvatar(backgroundColor: AppTheme.primaryColor.withOpacity(0.1), child: Icon(Icons.person, color: AppTheme.primaryColor)),
                  title: Text(_currentClassModel.teacherEmail),
                  subtitle: const Text('Profesor'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Alumnos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('${_currentClassModel.students.length}', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_currentClassModel.students.isEmpty)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('No hay alumnos inscritos aún', textAlign: TextAlign.center))
                else
                  ..._currentClassModel.students.map((student) => ListTile(
                    leading: CircleAvatar(backgroundColor: AppTheme.primaryColor.withOpacity(0.1), child: Icon(Icons.person, size: 16, color: AppTheme.primaryColor)),
                    title: Text(student.split('@').first),
                    subtitle: Text(student),
                  )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard('Información de la Clase', [
          _buildInfoItem('Materia', _currentClassModel.subject),
          if (_currentClassModel.section != null) _buildInfoItem('Sección', _currentClassModel.section!),
          if (_currentClassModel.room != null) _buildInfoItem('Aula', _currentClassModel.room!),
          _buildInfoItem('Código de acceso', _currentClassModel.accessCode),
          _buildInfoItem('Creada', _formatDate(_currentClassModel.createdAt)),
        ]),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Materiales de Clase', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${_materials.length} materiales compartidos', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverAppBarDelegate(this.tabBar);
  @override double get minExtent => tabBar.preferredSize.height;
  @override double get maxExtent => tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Theme.of(context).cardColor, child: tabBar);
  }
  @override bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

class _AddMaterialSheet extends StatefulWidget {
  final Function(ClassMaterial) onMaterialAdded;
  final String classId;
  final String teacherEmail;
  const _AddMaterialSheet({required this.onMaterialAdded, required this.classId, required this.teacherEmail});
  @override
  State<_AddMaterialSheet> createState() => __AddMaterialSheetState();
}

class __AddMaterialSheetState extends State<_AddMaterialSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  ClassMaterialType _selectedType = ClassMaterialType.announcement;
  PlatformFile? _pickedFile;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() => _pickedFile = result.files.single);
    }
  }

  Future<String?> _saveFileLocally(PlatformFile pickedFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
      final savePath = '${appDir.path}/class_files/$fileName';
      final directory = Directory('${appDir.path}/class_files');
      if (!await directory.exists()) await directory.create(recursive: true);
      final file = File(pickedFile.path!);
      await file.copy(savePath);
      return savePath;
    } catch (e) {
      print("Error al guardar archivo: $e");
      return null;
    }
  }

  void _submitMaterial() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El título es obligatorio')));
      return;
    }
    setState(() => _isLoading = true);
    String? filePath;
    String? fileName;
    String? fileType;
    if (_pickedFile != null) {
      filePath = await _saveFileLocally(_pickedFile!);
      if (filePath != null) {
        fileName = _pickedFile!.name;
        fileType = _pickedFile!.extension;
      }
    }
    final newMaterial = ClassMaterial(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      classId: widget.classId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      filePath: filePath,
      fileName: fileName,
      fileType: fileType,
      createdAt: DateTime.now(),
      createdBy: widget.teacherEmail,
    );
    widget.onMaterialAdded(newMaterial);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(fileName != null ? 'Publicado con archivo: $fileName' : 'Publicado correctamente'), backgroundColor: Colors.green),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Text('Publicar en el Muro', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          Text('Tipo de publicación', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ClassMaterialType.values.map((type) {
              final isSelected = _selectedType == type;
              return ChoiceChip(
                label: Text({
                  ClassMaterialType.announcement: 'Anuncio',
                  ClassMaterialType.assignment: 'Tarea',
                  ClassMaterialType.document: 'Documento',
                  ClassMaterialType.link: 'Enlace',
                  ClassMaterialType.video: 'Video',
                }[type]!),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedType = type),
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Título *', prefixIcon: const Icon(Icons.title), border: const OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _descriptionController, maxLines: 4, decoration: const InputDecoration(labelText: 'Descripción (opcional)', border: OutlineInputBorder())),
          const SizedBox(height: 20),
          _pickedFile == null
              ? OutlinedButton.icon(onPressed: _pickFile, icon: const Icon(Icons.attach_file), label: const Text('Adjuntar archivo'))
              : Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [const Icon(Icons.description, color: AppTheme.primaryColor), const SizedBox(width: 12), Expanded(child: Text(_pickedFile!.name, style: const TextStyle(fontWeight: FontWeight.w600))), IconButton(onPressed: () => setState(() => _pickedFile = null), icon: const Icon(Icons.close))]),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitMaterial,
                  child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Publicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}