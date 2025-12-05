// student/presentation/pages/student_classes_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../teacher/domain/models/class_model.dart';
import '../../../../config/theme/app_theme.dart';
import '../widgets/student_class_card.dart';
import '../../../teacher/presentation/pages/class_detail_page.dart';

class StudentClassesPage extends StatefulWidget {
  const StudentClassesPage({super.key});

  @override
  State<StudentClassesPage> createState() => _StudentClassesPageState();
}

class _StudentClassesPageState extends State<StudentClassesPage> {
  List<ClassModel> _classes = [];
  String _studentEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _studentEmail = prefs.getString('email') ?? '';

    final classesJson = prefs.getString('studentClasses_$_studentEmail') ?? '[]';
    final List<dynamic> classesList = json.decode(classesJson);

    setState(() {
      _classes = classesList.map((json) => ClassModel.fromJson(json)).toList();
      _isLoading = false;
    });
  }

  Future<void> _saveStudentClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final classesJson = json.encode(_classes.map((c) => c.toJson()).toList());
    await prefs.setString('studentClasses_$_studentEmail', classesJson);
  }

  // MÉTODO PARA SALIR DE UNA CLASE
  Future<void> _leaveClass(int index) async {
    final classToLeave = _classes[index];
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salir de la clase'),
        content: Text(
          '¿Estás seguro de que quieres salir de "${classToLeave.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _classes.removeAt(index);
      });
      await _saveStudentClasses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Has salido de ${classToLeave.name}'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _joinClass() {
    final codeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Unirse a una Clase',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    // CORREGIDO: era "IOError" → debe ser "onSurface"
                    icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa el código de acceso proporcionado por tu profesor',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: 'Código de Acceso',
                  hintText: 'Ej: ABC123',
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.vpn_key, color: AppTheme.primaryColor),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                ),
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final code = codeController.text.trim().toUpperCase();
                    if (code.isNotEmpty) {
                      Navigator.pop(context);
                      _validateAndJoinClass(code);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Unirse a la Clase',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BUSCA LA CLASE REAL POR CÓDIGO DE ACCESO
  Future<void> _validateAndJoinClass(String accessCode) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    ClassModel? foundClass;

    for (String key in keys) {
      if (key.startsWith('teacherClasses_')) {
        final classesJson = prefs.getString(key) ?? '[]';
        final List<dynamic> classesList = json.decode(classesJson);

        for (var jsonClass in classesList) {
          final classModel = ClassModel.fromJson(jsonClass as Map<String, dynamic>);
          if (classModel.accessCode.toUpperCase() == accessCode) {
            foundClass = classModel;
            break;
          }
        }
        if (foundClass != null) break;
      }
    }

    if (foundClass != null) {
      if (_classes.any((c) => c.id == foundClass!.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ya estás inscrito en esta clase'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }

      // CORREGIDO: copyWith no tiene parámetro 'students', así que creamos una copia manual
      final enrolledClass = ClassModel(
        id: foundClass.id,
        name: foundClass.name,
        subject: foundClass.subject,
        accessCode: foundClass.accessCode,
        students: List<String>.from(foundClass.students)..add(_studentEmail), // Aquí sí se agrega
        teacherEmail: foundClass.teacherEmail,
        createdAt: foundClass.createdAt,
        description: foundClass.description,
        section: foundClass.section,
        room: foundClass.room,
      );

      setState(() {
        _classes.add(enrolledClass);
      });
      await _saveStudentClasses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Te has unido a "${enrolledClass.name}" exitosamente!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: 'Ver clase',
              textColor: Colors.white,
              onPressed: () => _navigateToClass(enrolledClass),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Código inválido. Verifica e intenta de nuevo.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _navigateToClass(ClassModel classModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassDetailPage(classModel: classModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Mis Clases'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _classes.isEmpty
          ? _buildEmptyState()
          : _buildClassesGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: _joinClass,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_rounded),
        tooltip: 'Unirse a Clase',
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cargando tus clases...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesGrid() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              Text(
                'Tus Clases',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _classes.length.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _classes.length,
              itemBuilder: (context, index) {
                final clase = _classes[index];
                return StudentClassCard(
                  classModel: clase,
                  onTap: () => _navigateToClass(clase),
                  onLeaveClass: () => _leaveClass(index),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_rounded,
                size: 50,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Aún no tienes clases',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Únete a una clase usando un código de acceso proporcionado por tu profesor',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _joinClass,
              icon: const Icon(Icons.vpn_key_rounded),
              label: const Text('Unirse con Código'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}