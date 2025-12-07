// student/presentation/pages/student_grade_detail_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../teacher/domain/models/class_model.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

enum PeriodType { semestre, cuatrimestre }

class StudentPartialGrades {
  final String studentEmail;
  final String subject;
  final String classId;
  double parcial1;
  double parcial2;
  double parcial3;

  StudentPartialGrades({
    required this.studentEmail,
    required this.subject,
    required this.classId,
    this.parcial1 = 0.0,
    this.parcial2 = 0.0,
    this.parcial3 = 0.0,
  });

  double get promedio => (parcial1 + parcial2 + parcial3) / 3;
  bool get tieneCalificaciones => parcial1 > 0 || parcial2 > 0 || parcial3 > 0;

  factory StudentPartialGrades.fromJson(Map<String, dynamic> json) {
    return StudentPartialGrades(
      studentEmail: json['studentEmail'] ?? '',
      subject: json['subject'] ?? '',
      classId: json['classId'] ?? '',
      parcial1: (json['parcial1'] ?? 0.0).toDouble(),
      parcial2: (json['parcial2'] ?? 0.0).toDouble(),
      parcial3: (json['parcial3'] ?? 0.0).toDouble(),
    );
  }
}

class StudentGradeDetailPage extends StatefulWidget {
  final ClassModel classModel;
  final String studentEmail;

  const StudentGradeDetailPage({super.key, required this.classModel, required this.studentEmail});

  @override
  State<StudentGradeDetailPage> createState() => _StudentGradeDetailPageState();
}

class _StudentGradeDetailPageState extends State<StudentGradeDetailPage> {
  StudentPartialGrades? _grade;
  PeriodType _periodType = PeriodType.cuatrimestre;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final periodStr = prefs.getString('periodType_${widget.classModel.id}') ?? 'cuatrimestre';
    _periodType = periodStr == 'semestre' ? PeriodType.semestre : PeriodType.cuatrimestre;

    final gradesJson = prefs.getString('partialGrades_${widget.classModel.id}') ?? '[]';
    final List<dynamic> list = json.decode(gradesJson);

    final found = list
        .map((e) => StudentPartialGrades.fromJson(e))
        .firstWhere(
          (g) => g.studentEmail == widget.studentEmail,
      orElse: () => StudentPartialGrades(
        studentEmail: widget.studentEmail,
        subject: widget.classModel.subject,
        classId: widget.classModel.id,
      ),
    );

    setState(() {
      _grade = found;
      _loading = false;
    });
  }

  Color _getColor(double nota) {
    if (nota >= 9.0) return Colors.green;
    if (nota >= 8.0) return Colors.blue;
    if (nota >= 7.0) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classModel.name),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text(widget.classModel.subject, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold))),
                const SizedBox(height: 12),
                Center(
                  child: Chip(
                    backgroundColor: _periodType == PeriodType.semestre ? Colors.blue.shade700 : Colors.green.shade700,
                    label: Text(
                      _periodType == PeriodType.semestre ? 'Semestre' : 'Cuatrimestre',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (_grade == null || !_grade!.tieneCalificaciones)
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.hourglass_empty_rounded, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text("Aún no tienes calificaciones", style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text("El profesor aún no ha registrado tus notas", style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  )
                else ...[
                  _buildPartial("1er Parcial", _grade!.parcial1),
                  _buildPartial("2do Parcial", _grade!.parcial2),
                  _buildPartial("3er Parcial", _grade!.parcial3),
                  const Divider(height: 40, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Promedio Final", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(
                        _grade!.promedio.toStringAsFixed(1),
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: _getColor(_grade!.promedio)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _grade!.promedio >= 7 ? "Aprobado" : "Reprobado",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _grade!.promedio >= 7 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPartial(String label, double nota) {
    final color = _getColor(nota);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, child: Text(nota == 0 ? "-" : nota.toStringAsFixed(1), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        trailing: LinearProgressIndicator(value: nota / 10, color: color, backgroundColor: Colors.grey[300]),
      ),
    );
  }
}