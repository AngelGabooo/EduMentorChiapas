// student/presentation/pages/student_class_detail_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../../../teacher/domain/models/class_model.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/localization/app_translations.dart';

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
  bool get tieneCalificaciones => parcial1 > 0 || parcial2 > 0 || parcial3 > 0;

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
}

class StudentClassDetailPage extends StatefulWidget {
  final ClassModel classModel;
  final String studentEmail;

  const StudentClassDetailPage({super.key, required this.classModel, required this.studentEmail});

  @override
  State<StudentClassDetailPage> createState() => _StudentClassDetailPageState();
}

class _StudentClassDetailPageState extends State<StudentClassDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ClassMaterial> _materials = [];
  List<StudentPartialGrades> _grades = [];
  PeriodType _periodType = PeriodType.cuatrimestre;

  Map<String, String> _comments = {};
  Map<String, String> _submittedFiles = {};
  Map<String, double> _taskGrades = {};
  Map<String, Map<String, String>> _allComments = {};

  bool _isPickingFile = false;

  // Cache de traducciones
  Map<String, String> _t = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
    FilePicker.platform.clearTemporaryFiles();
    _loadTranslations();
  }

  // ← SE RECARGA AUTOMÁTICAMENTE CUANDO CAMBIA EL IDIOMA
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    final keys = [
      'wall', 'assignments', 'grades', 'section', 'semester', 'quarter',
      'your_comment', 'send', 'reply_to_teacher', 'teacher_reply',
      'upload_assignment', 'uploading', 'deliver_assignment', 'approved_task',
      'failed_task', 'no_materials', 'no_tasks', 'grades_by_partial',
      'no_grades_yet', 'teacher_no_grades', 'final_average', 'approved', 'failed',
      'not_delivered', 'comment_sent'
    ];

    Map<String, String> temp = {};
    for (String key in keys) {
      try {
        temp[key] = await AppTranslations.tr(key);
      } catch (e) {
        temp[key] = key;
      }
    }

    if (mounted) {
      setState(() {
        _t = temp;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadMaterials(),
      _loadGrades(),
      _loadPeriodType(),
      _loadStudentData(),
      _loadTaskGrades(),
      _loadAllComments(),
    ]).catchError((e) {
      // Evita que un error rompa todo
    });
    if (mounted) setState(() {});
  }

  Future<void> _loadMaterials() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString('classMaterials_${widget.classModel.id}');
    if (jsonStr == null) return;
    final List<dynamic> list = json.decode(jsonStr);
    setState(() {
      _materials = list.map((e) => ClassMaterial.fromJson(e)).toList();
    });
  }

  Future<void> _loadGrades() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString('partialGrades_${widget.classModel.id}');
    if (jsonStr == null) return;
    final List<dynamic> list = json.decode(jsonStr);
    setState(() {
      _grades = list.map((e) => StudentPartialGrades.fromJson(e)).toList();
    });
  }

  Future<void> _loadPeriodType() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('periodType_${widget.classModel.id}');
    setState(() {
      _periodType = saved == 'semestre' ? PeriodType.semestre : PeriodType.cuatrimestre;
    });
  }

  Future<void> _loadStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    final String commentsJson = prefs.getString('studentComments_${widget.classModel.id}_${widget.studentEmail}') ?? '{}';
    final String filesJson = prefs.getString('studentFiles_${widget.classModel.id}_${widget.studentEmail}') ?? '{}';

    setState(() {
      _comments = Map<String, String>.from(json.decode(commentsJson));
      _submittedFiles = Map<String, String>.from(json.decode(filesJson));
    });
  }

  Future<void> _loadTaskGrades() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, double> grades = {};

    for (final material in _materials) {
      if (material.type != ClassMaterialType.assignment) continue;
      final String key = 'task_grades_${widget.classModel.id}_${material.id}';
      final String? jsonStr = prefs.getString(key);
      if (jsonStr == null) continue;
      final Map<String, dynamic> map = json.decode(jsonStr);
      if (map.containsKey(widget.studentEmail)) {
        grades[material.id] = (map[widget.studentEmail] as num).toDouble();
      }
    }

    setState(() => _taskGrades = grades);
  }

  Future<void> _loadAllComments() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, Map<String, String>> all = {};

    for (final material in _materials) {
      final String key = 'comments_${widget.classModel.id}_${material.id}';
      final String? jsonStr = prefs.getString(key);
      if (jsonStr == null || jsonStr.isEmpty) continue;
      try {
        final Map<String, dynamic> map = json.decode(jsonStr);
        all[material.id] = map.map((k, v) => MapEntry(k, v.toString()));
      } catch (e) {
        // Evita el error JsonCodec
        continue;
      }
    }

    setState(() => _allComments = all);
  }

  Future<void> _saveStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('studentComments_${widget.classModel.id}_${widget.studentEmail}', json.encode(_comments));
    await prefs.setString('studentFiles_${widget.classModel.id}_${widget.studentEmail}', json.encode(_submittedFiles));
  }

  Future<void> _submitComment(String materialId, String comment) async {
    if (comment.trim().isEmpty) return;
    setState(() => _comments[materialId] = comment.trim());
    await _saveStudentData();

    final prefs = await SharedPreferences.getInstance();
    final String key = 'comments_${widget.classModel.id}_$materialId';
    final String current = prefs.getString(key) ?? '{}';
    final Map<String, dynamic> map = json.decode(current);
    map[widget.studentEmail] = comment.trim();
    await prefs.setString(key, json.encode(map));

    await _loadAllComments();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t['comment_sent'] ?? 'Comentario enviado'), backgroundColor: Colors.green),
      );
    }
  }

  void _replyToTeacher(String materialId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t['reply_to_teacher'] ?? 'Responder al profesor'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Escribe tu respuesta...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final reply = controller.text.trim();
              if (reply.isEmpty) return;
              await _submitComment(materialId, reply);
              Navigator.pop(context);
            },
            child: Text(_t['send'] ?? 'Enviar'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadAssignment(String materialId) async {
    if (_isPickingFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Espera a que termine la selección')),
      );
      return;
    }

    setState(() => _isPickingFile = true);

    try {
      await FilePicker.platform.clearTemporaryFiles();
      final result = await FilePicker.platform.pickFiles();

      if (!mounted) return;
      if (result == null || result.files.isEmpty || result.files.single.path == null) return;

      final file = result.files.single;
      final fileName = file.name;
      final appDir = await getApplicationDocumentsDirectory();
      final newPath = '${appDir.path}/student_submissions/${widget.classModel.id}_$materialId}_${widget.studentEmail}_$fileName';

      final dir = Directory('${appDir.path}/student_submissions');
      if (!await dir.exists()) await dir.create(recursive: true);

      await File(file.path!).copy(newPath);

      setState(() => _submittedFiles[materialId] = fileName);
      await _saveStudentData();

      final prefs = await SharedPreferences.getInstance();
      final key = 'submissions_${widget.classModel.id}_$materialId';
      final current = prefs.getString(key) ?? '{}';
      final Map<String, dynamic> map = json.decode(current);
      map[widget.studentEmail] = fileName;
      await prefs.setString(key, json.encode(map));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarea entregada: $fileName'), backgroundColor: Colors.blue),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  Color _getClassColor() {
    final colors = [AppTheme.primaryColor, Colors.purple, Colors.teal, Colors.orange];
    return colors[widget.classModel.name.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _getClassColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 320.0,
              floating: false,
              pinned: true,
              backgroundColor: color,
              elevation: 0,
              title: const SizedBox.shrink(),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withOpacity(0.95)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(widget.classModel.name, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text(widget.classModel.subject, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                          if (widget.classModel.section != null)
                            Text('${_t['section'] ?? 'Sección'} ${widget.classModel.section!}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 17)),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(14)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.vpn_key, size: 18, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(widget.classModel.accessCode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _periodType == PeriodType.semestre ? Colors.blue.shade700 : Colors.green.shade700,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  _periodType == PeriodType.semestre
                                      ? (_t['semester'] ?? 'Semestre')
                                      : (_t['quarter'] ?? 'Cuatrimestre'),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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
            ),
            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: AppTheme.primaryColor,
                  tabs: [
                    Tab(text: _t['wall'] ?? 'Muro'),
                    Tab(text: _t['assignments'] ?? 'Tareas'),
                    Tab(text: _t['grades'] ?? 'Calificaciones'),
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
            _buildWallTab(isDark),
            _buildAssignmentsTab(),
            _buildGradesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildWallTab(bool isDark) {
    if (_materials.isEmpty) {
      return Center(child: Text(_t['no_materials'] ?? "El profesor aún no ha publicado nada", style: const TextStyle(fontSize: 16, color: Colors.grey)));
    }

    String getInitial() {
      final namePart = widget.studentEmail.split('@').first;
      return namePart.isEmpty ? "A" : namePart[0].toUpperCase();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _materials.length,
      itemBuilder: (context, index) {
        final material = _materials[index];
        final myComment = _comments[material.id] ?? '';
        final fileName = _submittedFiles[material.id];
        final grade = _taskGrades[material.id] ?? 0.0;
        final commentController = TextEditingController(text: myComment);
        final allComments = _allComments[material.id] ?? {};

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_getIcon(material.type), color: _getColor(material.type)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(material.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text(material.type.toString().split('.').last.toUpperCase(), style: TextStyle(color: _getColor(material.type))),
                          Text("Publicado: ${_formatDate(material.createdAt)}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

                const Divider(),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_t['your_comment'] ?? "Tu comentario:", style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: "Escribe aquí tu comentario o duda...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send, color: AppTheme.primaryColor),
                          onPressed: () {
                            if (commentController.text.trim().isNotEmpty) {
                              _submitComment(material.id, commentController.text);
                              commentController.clear();
                            }
                          },
                        ),
                      ),
                      maxLines: 3,
                    ),

                    if (myComment.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppTheme.primaryColor,
                              child: Text(
                                getInitial(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Tú", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey[700])),
                                  const SizedBox(height: 4),
                                  Text(myComment, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (allComments.containsKey('teacher_reply_${widget.studentEmail}')) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(isDark ? 0.6 : 0.4)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.reply, size: 20, color: AppTheme.primaryColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_t['teacher_reply'] ?? "Respuesta del profesor", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                                  const SizedBox(height: 4),
                                  Text(allComments['teacher_reply_${widget.studentEmail}']!, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () => _replyToTeacher(material.id),
                                    icon: const Icon(Icons.reply, size: 16),
                                    label: Text(_t['reply_to_teacher'] ?? "Responder al profesor"),
                                    style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                if (material.type == ClassMaterialType.assignment) ...[
                  const SizedBox(height: 16),
                  Text(_t['deliver_assignment'] ?? "Entregar tarea:", style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (fileName != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.task_alt, color: Colors.green),
                          const SizedBox(width: 10),
                          Expanded(child: Text("Entregado: $fileName", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                          if (grade > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: grade >= 70 ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                grade.toStringAsFixed(1),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: _isPickingFile ? null : () => _uploadAssignment(material.id),
                      icon: _isPickingFile
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.upload),
                      label: Text(_isPickingFile ? (_t['uploading'] ?? "Subiendo...") : (_t['upload_assignment'] ?? "Subir archivo")),
                    ),
                  if (grade > 0 && fileName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                        child: Text(
                          grade >= 70 ? (_t['approved_task'] ?? "Aprobado") : (_t['failed_task'] ?? "Reprobado"),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: grade >= 70 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssignmentsTab() {
    final assignments = _materials.where((m) => m.type == ClassMaterialType.assignment).toList();
    if (assignments.isEmpty) return Center(child: Text(_t['no_tasks'] ?? "No hay tareas asignadas"));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, i) {
        final m = assignments[i];
        final entregado = _submittedFiles[m.id];
        final grade = _taskGrades[m.id] ?? 0.0;
        return Card(
          child: ListTile(
            leading: Icon(Icons.assignment, color: entregado != null ? Colors.green : Colors.grey),
            title: Text(m.title),
            subtitle: Text(entregado ?? (_t['not_delivered'] ?? "Sin entregar")),
            trailing: entregado != null
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (grade > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: grade >= 70 ? Colors.green : Colors.red, borderRadius: BorderRadius.circular(12)),
                    child: Text(grade.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                const Icon(Icons.check_circle, color: Colors.green),
              ],
            )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildGradesTab() {
    final myGrade = _grades.firstWhere(
          (g) => g.studentEmail == widget.studentEmail,
      orElse: () => StudentPartialGrades(studentEmail: widget.studentEmail),
    );
    final tareasEntregadas = _materials.where((m) => m.type == ClassMaterialType.assignment && _submittedFiles.containsKey(m.id)).toList();

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    Text(_t['grades_by_partial'] ?? "Calificaciones por Parciales", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    if (!myGrade.tieneCalificaciones)
                      Column(
                        children: [
                          Icon(Icons.hourglass_empty_rounded, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(_t['no_grades_yet'] ?? "Aún no tienes calificaciones por parciales", style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          Text(_t['teacher_no_grades'] ?? "El profesor aún no ha registrado tus notas", style: TextStyle(color: Colors.grey[600])),
                        ],
                      )
                    else ...[
                      _buildPartialGrade("1er Parcial", myGrade.parcial1),
                      _buildPartialGrade("2do Parcial", myGrade.parcial2),
                      _buildPartialGrade("3er Parcial", myGrade.parcial3),
                      const Divider(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_t['final_average'] ?? "Promedio Final", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text(
                            myGrade.promedio.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: myGrade.aprobado ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: myGrade.aprobado ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            myGrade.aprobado ? (_t['approved'] ?? "¡Aprobado!") : (_t['failed'] ?? "Reprobado"),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: myGrade.aprobado ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (tareasEntregadas.isNotEmpty)
              Column(
                children: [
                  Text("Calificaciones de Tareas", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...tareasEntregadas.map((material) {
                    final grade = _taskGrades[material.id] ?? 0.0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: grade >= 70 ? Colors.green : grade > 0 ? Colors.red : Colors.grey,
                          child: Text(grade > 0 ? grade.toStringAsFixed(1) : "--", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(material.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text("Entregado: ${_submittedFiles[material.id]}"),
                        trailing: Text(grade >= 70 ? (_t['approved_task'] ?? "Aprobado") : grade > 0 ? (_t['failed_task'] ?? "Reprobado") : "Sin calificar",
                            style: TextStyle(color: grade >= 70 ? Colors.green : grade > 0 ? Colors.red : Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ],
              )
            else if (myGrade.tieneCalificaciones)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      const Expanded(child: Text("No has entregado tareas o aún no han sido calificadas")),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartialGrade(String label, double nota) {
    final color = nota >= 70 ? Colors.green : Colors.red;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          radius: 28,
          child: Text(
            nota == 0 ? "—" : nota.toStringAsFixed(1),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        trailing: Icon(
          nota >= 70 ? Icons.check_circle : Icons.cancel,
          color: color,
          size: 32,
        ),
      ),
    );
  }

  IconData _getIcon(ClassMaterialType type) {
    switch (type) {
      case ClassMaterialType.announcement: return Icons.campaign;
      case ClassMaterialType.assignment: return Icons.assignment;
      case ClassMaterialType.document: return Icons.description;
      case ClassMaterialType.link: return Icons.link;
      case ClassMaterialType.video: return Icons.play_circle;
      default: return Icons.school;
    }
  }

  Color _getColor(ClassMaterialType type) {
    switch (type) {
      case ClassMaterialType.announcement: return Colors.orange;
      case ClassMaterialType.assignment: return Colors.purple;
      case ClassMaterialType.document: return Colors.blue;
      default: return AppTheme.primaryColor;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);
  @override double get minExtent => tabBar.preferredSize.height;
  @override double get maxExtent => tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Theme.of(context).cardColor, child: tabBar);
  }
  @override bool shouldRebuild(covariant SliverPersistentHeaderDelegate old) => false;
}