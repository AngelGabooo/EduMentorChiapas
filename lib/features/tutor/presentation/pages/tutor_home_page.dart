// features/tutor/presentation/pages/tutor_home_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../widgets/tutor_home_card.dart';
import '../../../teacher/domain/models/class_model.dart'; // ← Necesario para ClassModel

enum PeriodType { semestre, cuatrimestre }

// ← TU MODELO ORIGINAL (NO LO CAMBIAMOS)
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

  Map<String, dynamic> toJson() => {
    'studentEmail': studentEmail,
    'subject': subject,
    'classId': classId,
    'parcial1': parcial1,
    'parcial2': parcial2,
    'parcial3': parcial3,
  };

  factory StudentPartialGrades.fromJson(Map<String, dynamic> json) {
    return StudentPartialGrades(
      studentEmail: json['studentEmail'] ?? '',
      subject: json['subject'] ?? 'Sin materia',
      classId: json['classId'] ?? '',
      parcial1: (json['parcial1'] ?? 0.0).toDouble(),
      parcial2: (json['parcial2'] ?? 0.0).toDouble(),
      parcial3: (json['parcial3'] ?? 0.0).toDouble(),
    );
  }
}

class TutorHomePage extends StatefulWidget {
  const TutorHomePage({super.key});

  @override
  State<TutorHomePage> createState() => _TutorHomePageState();
}

class _TutorHomePageState extends State<TutorHomePage> with SingleTickerProviderStateMixin {
  String hijoNombre = "Tu hijo/a";
  String hijoEdad = "";
  String hijoEmail = "";
  List<StudentPartialGrades> calificacionesPorMateria = [];
  Map<String, PeriodType> periodosPorClase = {};
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _cargarDatos();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ← CÓDIGO 100% CORREGIDO: ahora sí ve las calificaciones del profesor
  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      hijoNombre = prefs.getString('hijo_nombre') ?? "Tu hijo/a";
      hijoEdad = prefs.getString('hijo_edad') ?? "";
      hijoEmail = prefs.getString('hijo_email') ?? "";
      isLoading = true;
      calificacionesPorMateria.clear();
      periodosPorClase.clear();
    });

    if (hijoEmail.isEmpty) {
      setState(() => isLoading = false);
      _animationController.forward();
      return;
    }

    try {
      final keys = prefs.getKeys();

      for (String key in keys) {
        if (key.startsWith('teacherClasses_') || key.startsWith('studentClasses_')) {
          final classesJson = prefs.getString(key) ?? '[]';
          final List<dynamic> classesList = json.decode(classesJson);

          for (var classJson in classesList) {
            final classModel = ClassModel.fromJson(classJson as Map<String, dynamic>);
            if (!classModel.students.contains(hijoEmail)) continue;

            final classId = classModel.id;
            final subject = classModel.subject;

            // Cargar periodo
            final periodStr = prefs.getString('periodType_$classId') ?? 'cuatrimestre';
            final periodType = periodStr == 'semestre' ? PeriodType.semestre : PeriodType.cuatrimestre;
            periodosPorClase[classId] = periodType;

            // Cargar calificaciones del profesor (solo tienen studentEmail)
            final gradesJson = prefs.getString('partialGrades_$classId') ?? '[]';
            final List<dynamic> gradesList = json.decode(gradesJson);

            final gradeFromProfesor = gradesList
                .map((e) => Map<String, dynamic>.from(e))
                .firstWhere(
                  (g) => g['studentEmail'] == hijoEmail,
              orElse: () => {'studentEmail': hijoEmail, 'parcial1': 0.0, 'parcial2': 0.0, 'parcial3': 0.0},
            );

            // Crear el objeto con materia y clase
            final calificacion = StudentPartialGrades(
              studentEmail: hijoEmail,
              subject: subject,
              classId: classId,
              parcial1: (gradeFromProfesor['parcial1'] ?? 0.0).toDouble(),
              parcial2: (gradeFromProfesor['parcial2'] ?? 0.0).toDouble(),
              parcial3: (gradeFromProfesor['parcial3'] ?? 0.0).toDouble(),
            );

            calificacionesPorMateria.add(calificacion);
          }
        }
      }
    } catch (e) {
      print("Error cargando calificaciones del tutor: $e");
    }

    setState(() => isLoading = false);
    _animationController.forward();
  }

  double get promedioGeneral {
    final conCalificaciones = calificacionesPorMateria.where((g) => g.tieneCalificaciones);
    if (conCalificaciones.isEmpty) return 0.0;
    return conCalificaciones.map((g) => g.promedio).reduce((a, b) => a + b) / conCalificaciones.length;
  }

  bool get tieneCalificaciones => calificacionesPorMateria.any((g) => g.tieneCalificaciones);

  Future<void> _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove('current_user_email'),
      prefs.remove('email'),
      prefs.remove('role'),
      prefs.remove('full_name'),
      prefs.remove('hashed_password'),
      prefs.remove('hijo_nombre'),
      prefs.remove('hijo_edad'),
      prefs.remove('hijo_email'),
      prefs.remove('tutor_telefono'),
      prefs.remove('profileCompleted'),
    ]);
    if (mounted) {
      context.go('/login');
    }
  }

  void _mostrarContactoMaestro() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContactoMaestroBottomSheet(hijoNombre: hijoNombre),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarContactoMaestro,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.chat_rounded),
        label: const Text("Contactar Maestro"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 240.0,
              floating: false,
              pinned: true,
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colors.primary, colors.primaryContainer],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: colors.onPrimary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: colors.onPrimary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bienvenido/a,",
                                style: TextStyle(
                                  color: colors.onPrimary.withOpacity(0.9),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                hijoNombre,
                                style: TextStyle(
                                  color: colors.onPrimary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Progreso Académico",
                                style: TextStyle(
                                  color: colors.onPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.onPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.refresh_rounded, size: 20),
                  ),
                  onPressed: _cargarDatos,
                  tooltip: "Actualizar",
                ),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.onPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.more_vert_rounded, size: 20),
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text("Cerrar sesión"),
                          content: const Text("¿Estás seguro de que deseas salir?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _cerrarSesion();
                              },
                              child: const Text("Salir", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.red),
                          const SizedBox(width: 12),
                          const Text("Cerrar sesión"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
        body: isLoading
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Cargando datos...", style: TextStyle(color: Colors.grey)),
            ],
          ),
        )
            : FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _cargarDatos,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TutorHomeCard(
                        hijoNombre: hijoNombre,
                        hijoEdad: hijoEdad,
                        promedio: tieneCalificaciones ? promedioGeneral : null,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Calificaciones por Materia",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.school_rounded, size: 16, color: colors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  "${calificacionesPorMateria.length} materia${calificacionesPorMateria.length == 1 ? '' : 's'}",
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final calificacion = calificacionesPorMateria[index];
                        return SlideTransition(
                          position: _slideAnimation,
                          child: _MateriaConParcialesCard(calificacion: calificacion),
                        );
                      },
                      childCount: calificacionesPorMateria.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// NUEVO CARD: Muestra los 3 parciales
class _MateriaConParcialesCard extends StatelessWidget {
  final StudentPartialGrades calificacion;
  const _MateriaConParcialesCard({required this.calificacion});

  Color _getColor(double nota) {
    if (nota >= 9.0) return Colors.green;
    if (nota >= 8.0) return Colors.blue;
    if (nota >= 7.0) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tieneCal = calificacion.tieneCalificaciones;
    final promedio = calificacion.promedio;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: tieneCal
                            ? [_getColor(promedio), _getColor(promedio).withOpacity(0.7)]
                            : [Colors.grey, Colors.grey.shade400],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          calificacion.subject,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tieneCal ? "Promedio: ${promedio.toStringAsFixed(1)}" : "Sin calificaciones aún",
                          style: TextStyle(
                            color: tieneCal ? _getColor(promedio) : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (tieneCal)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: _getColor(promedio),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: _getColor(promedio).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Text(
                        promedio.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (!tieneCal)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.onSurface.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_empty_rounded, color: colors.onSurface.withOpacity(0.6)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "El maestro aún no ha registrado las calificaciones de esta materia.",
                          style: TextStyle(color: colors.onSurface.withOpacity(0.8), fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _buildParcialRow("1er Parcial", calificacion.parcial1),
                _buildParcialRow("2do Parcial", calificacion.parcial2),
                _buildParcialRow("3er Parcial", calificacion.parcial3),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Promedio Final", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      promedio.toStringAsFixed(1),
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _getColor(promedio)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParcialRow(String label, double nota) {
    final color = _getColor(nota);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
            child: LinearProgressIndicator(
              value: nota / 10,
              backgroundColor: Colors.grey[300],
              color: color,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: Text(
              nota == 0 ? "—" : nota.toStringAsFixed(1),
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// EL RESTO DEL CÓDIGO QUEDA 100% IGUAL (sin tocar nada)
class _SubjectCard extends StatelessWidget {
  final String subject;
  final double grade;
  final int index;
  const _SubjectCard({
    required this.subject,
    required this.grade,
    required this.index,
  });
  Color _getGradeColor(double grade) {
    if (grade >= 9.5) return Colors.green;
    if (grade >= 9.0) return Colors.blue;
    if (grade >= 8.0) return Colors.orange;
    if (grade >= 7.0) return Colors.orangeAccent;
    return Colors.red;
  }
  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case "Matemáticas":
        return Icons.calculate_rounded;
      case "Español":
        return Icons.menu_book_rounded;
      case "Ciencias":
        return Icons.science_rounded;
      case "Historia":
        return Icons.history_edu_rounded;
      case "Inglés":
        return Icons.language_rounded;
      case "Educación Física":
        return Icons.sports_soccer_rounded;
      case "Arte":
        return Icons.palette_rounded;
      case "Música":
        return Icons.music_note_rounded;
      default:
        return Icons.school_rounded;
    }
  }
  String _getGradeLabel(double grade) {
    if (grade >= 9.5) return "Excelente";
    if (grade >= 9.0) return "Muy Bueno";
    if (grade >= 8.0) return "Bueno";
    if (grade >= 7.0) return "Regular";
    return "Necesita Mejorar";
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        elevation: 3,
        shadowColor: colors.shadow.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getGradeColor(grade).withOpacity(0.15),
                      _getGradeColor(grade).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getSubjectIcon(subject),
                  color: _getGradeColor(grade),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getGradeLabel(grade),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: colors.onSurface.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        Container(
                          height: 6,
                          width: (grade / 10) * (MediaQuery.of(context).size.width - 200),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getGradeColor(grade),
                                _getGradeColor(grade).withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getGradeColor(grade),
                      _getGradeColor(grade).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _getGradeColor(grade).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  grade.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactoMaestroBottomSheet extends StatelessWidget {
  final String hijoNombre;
  const ContactoMaestroBottomSheet({super.key, required this.hijoNombre});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Contactar al Maestro",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colors.onSurface.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary.withOpacity(0.05), colors.primary.withOpacity(0.02)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.primary.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [colors.primary, colors.primaryContainer]),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: colors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Icon(Icons.person_rounded, color: colors.onPrimary, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Profesor Asignado", style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withOpacity(0.8))),
                          const SizedBox(height: 6),
                          Text("Maestro Ejemplo", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.email_rounded, size: 16, color: colors.primary),
                              const SizedBox(width: 6),
                              Text("maestro.ejemplo@escuela.com", style: theme.textTheme.bodyMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        launchUrl(Uri.parse("mailto:maestro.ejemplo@escuela.com?subject=Consulta sobre $hijoNombre&body=Hola profesor,%0A%0AMi hijo/a es $hijoNombre y me gustaría hablar sobre..."));
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.email_rounded),
                      label: const Text("Enviar Correo"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: colors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        launchUrl(Uri.parse("tel:+1234567890"));
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.phone_rounded),
                      label: const Text("Llamar"),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
            ],
          ),
        ),
      ),
    );
  }
}