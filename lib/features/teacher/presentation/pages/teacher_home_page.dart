import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../../domain/models/class_model.dart';
import '../../../../config/theme/app_theme.dart';
import 'class_detail_page.dart';
import 'teacher_profile_dashboard.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ClassModel> _classes = [];
  String _teacherEmail = '';
  String _teacherName = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _teacherEmail = prefs.getString('email') ?? '';
    _teacherName = prefs.getString('full_name') ?? 'Profesor';
    final classesJson = prefs.getString('teacherClasses_${_teacherEmail}') ?? '[]';
    final List<dynamic> classesList = json.decode(classesJson);
    setState(() {
      _classes = classesList.map((json) => ClassModel.fromJson(json)).toList();
    });
  }

  Future<void> _saveClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final classesJson = json.encode(_classes.map((c) => c.toJson()).toList());
    await prefs.setString('teacherClasses_${_teacherEmail}', classesJson);
  }

  // Navegar al perfil del maestro
  void _navigateToProfile() {
    context.push('/teacher-profile-dashboard');
  }

  // CORREGIDO AL 100%: Cerrar sesión limpiando TODAS las claves críticas
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();

    // Limpiamos absolutamente todo lo relacionado con la sesión
    await Future.wait([
      prefs.remove('email'),
      prefs.remove('full_name'),
      prefs.remove('role'),
      prefs.remove('userType'),
      prefs.remove('current_user_email'), // CLAVE: esta línea evita que el redirect se vuelva loco
      prefs.remove('profileCompleted'),
    ]);

    // Opcional: limpiar también las clases locales si quieres
    // await prefs.remove('teacherClasses_${_teacherEmail}');

    if (mounted) {
      // Va directo al login sin pasar por redirect que pueda leer datos viejos
      context.go('/login');
    }
  }

  // Diálogo de confirmación para cerrar sesión
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _createClass() {
    final nameController = TextEditingController();
    final subjectController = TextEditingController();
    final sectionController = TextEditingController();
    final roomController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedSubject;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Crear Nueva Clase',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildModernTextField(
                        controller: nameController,
                        label: 'Nombre de la clase',
                        icon: Icons.class_,
                        hint: 'Ej: Matemáticas Avanzadas',
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        value: selectedSubject,
                        label: 'Materia',
                        items: [
                          'Matemáticas',
                          'Español',
                          'Ciencias',
                          'Historia',
                          'Geografía',
                          'Inglés',
                          'Arte',
                          'Música',
                          'Educación Física',
                          'Computación',
                          'Física',
                          'Química',
                          'Biología',
                          'Filosofía',
                          'Economía'
                        ],
                        onChanged: (value) => setState(() => selectedSubject = value),
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: sectionController,
                        label: 'Sección (opcional)',
                        icon: Icons.group,
                        hint: 'Ej: A, B, 1ro A',
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: roomController,
                        label: 'Aula (opcional)',
                        icon: Icons.room,
                        hint: 'Ej: Aula 101',
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: descriptionController,
                        label: 'Descripción (opcional)',
                        icon: Icons.description,
                        hint: 'Describe el propósito de esta clase',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && selectedSubject != null) {
                      final newClass = ClassModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        subject: selectedSubject!,
                        accessCode: _generateAccessCode(),
                        students: [],
                        teacherEmail: _teacherEmail,
                        createdAt: DateTime.now(),
                        section: sectionController.text.isNotEmpty ? sectionController.text : null,
                        room: roomController.text.isNotEmpty ? roomController.text : null,
                        description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                      );
                      setState(() => _classes.add(newClass));
                      _saveClasses();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('¡Clase creada exitosamente!'),
                              const SizedBox(height: 4),
                              Text(
                                'Código de acceso: ${newClass.accessCode}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          backgroundColor: AppTheme.primaryColor,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Crear Clase',
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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: Icon(icon, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                hint: const Text('Selecciona una materia'),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _generateAccessCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(Random().nextInt(chars.length))));
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
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 160,
              floating: true,
              pinned: true,
              backgroundColor: theme.appBarTheme.backgroundColor,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: _navigateToProfile,
                  tooltip: 'Mi Perfil',
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: _showLogoutDialog,
                  tooltip: 'Cerrar Sesión',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Mis Clases',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [AppTheme.darkSurfaceColor, AppTheme.darkBackgroundColor]
                          : [AppTheme.primaryColor.withOpacity(0.1), AppTheme.accentColor.withOpacity(0.1)],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, bottom: 16),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Hola, $_teacherName',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: theme.cardColor,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                    indicatorColor: AppTheme.primaryColor,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Mis Clases'),
                      Tab(text: 'Alumnos'),
                      Tab(text: 'Calificaciones'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildClassesTab(),
            _buildStudentsTab(),
            _buildGradesTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createClass,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Crear Clase',
      ),
    );
  }

  Widget _buildClassesTab() {
    if (_classes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.class_,
        title: 'Aún no tienes clases',
        subtitle: 'Crea tu primera clase para comenzar',
        buttonText: 'Crear Clase',
        onPressed: _createClass,
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _classes.length,
      itemBuilder: (context, index) {
        final clase = _classes[index];
        return _buildClassCard(clase);
      },
    );
  }

  Widget _buildClassCard(ClassModel clase) {
    final theme = Theme.of(context);
    final randomColor = _getRandomColor();
    return GestureDetector(
      onTap: () => _navigateToClass(clase),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: randomColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    clase.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    clase.subject,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  if (clase.section != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Sección ${clase.section!}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${clase.students.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          clase.accessCode,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsTab() {
    final allStudents = _classes.expand((clase) => clase.students).toSet().toList();
    if (allStudents.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people,
        title: 'No hay alumnos inscritos',
        subtitle: 'Los alumnos aparecerán aquí cuando se unan a tus clases',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allStudents.length,
      itemBuilder: (context, index) {
        final student = allStudents[index];
        final studentClasses = _classes.where((clase) => clase.students.contains(student)).toList();
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: AppTheme.primaryColor,
              ),
            ),
            title: Text(
              student,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Inscrito en ${studentClasses.length} clase(s)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradesTab() {
    return _buildEmptyState(
      icon: Icons.grade,
      title: 'Sistema de Calificaciones',
      subtitle: 'Próximamente podrás gestionar calificaciones aquí',
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(buttonText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getRandomColor() {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];
    return colors[Random().nextInt(colors.length)];
  }
}