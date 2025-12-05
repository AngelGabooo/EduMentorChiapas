import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/models/class_model.dart';
import '../../../../config/theme/app_theme.dart';

class ClassDetailPage extends StatefulWidget {
  final ClassModel classModel;

  const ClassDetailPage({super.key, required this.classModel});

  @override
  State<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ClassMaterial> _materials = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMaterials();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMaterials() async {
    final prefs = await SharedPreferences.getInstance();
    final materialsJson = prefs.getString('classMaterials_${widget.classModel.id}') ?? '[]';
    final List<dynamic> materialsList = json.decode(materialsJson);
    setState(() {
      _materials = materialsList.map((json) => ClassMaterial.fromJson(json)).toList();
    });
  }

  Future<void> _saveMaterials() async {
    final prefs = await SharedPreferences.getInstance();
    final materialsJson = json.encode(_materials.map((m) => m.toJson()).toList());
    await prefs.setString('classMaterials_${widget.classModel.id}', materialsJson);
  }

  void _addMaterial() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMaterialSheet(
        onMaterialAdded: (material) {
          setState(() => _materials.insert(0, material));
          _saveMaterials();
        },
        classId: widget.classModel.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final randomColor = _getClassColor(widget.classModel.name);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: true,
              pinned: true,
              backgroundColor: randomColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.classModel.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  color: randomColor,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.classModel.subject,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        if (widget.classModel.section != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Sección ${widget.classModel.section!}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Código: ${widget.classModel.accessCode}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
                      Tab(text: 'Muro'),
                      Tab(text: 'Personas'),
                      Tab(text: 'Contenido'),
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
            _buildWallTab(),
            _buildPeopleTab(),
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

  Widget _buildWallTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _materials.length,
      itemBuilder: (context, index) {
        final material = _materials[index];
        return _buildMaterialCard(material);
      },
    );
  }

  Widget _buildMaterialCard(ClassMaterial material) {
    final theme = Theme.of(context);
    final icon = _getMaterialIcon(material.type as MaterialType);

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
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(material.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              material.description,
              style: theme.textTheme.bodyMedium,
            ),
            if (material.fileUrl != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_file,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Archivo adjunto',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Icon(
                      Icons.download,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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
                Text(
                  'Profesor',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  title: Text(widget.classModel.teacherEmail),
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
                    Text(
                      'Alumnos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.classModel.students.length}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (widget.classModel.students.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No hay alumnos inscritos aún',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...widget.classModel.students.map((student) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    title: Text(student),
                    subtitle: const Text('Alumno'),
                  )).toList(),
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
          _buildInfoItem('Materia', widget.classModel.subject),
          if (widget.classModel.section != null)
            _buildInfoItem('Sección', widget.classModel.section!),
          if (widget.classModel.room != null)
            _buildInfoItem('Aula', widget.classModel.room!),
          _buildInfoItem('Código de acceso', widget.classModel.accessCode),
          _buildInfoItem('Creada', _formatDate(widget.classModel.createdAt)),
        ]),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Materiales de Clase',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_materials.length} materiales compartidos',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
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
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMaterialIcon(MaterialType type) {
    switch (type) {
      case MaterialType.document:
        return Icons.description;
      case MaterialType.assignment:
        return Icons.assignment;
      case MaterialType.announcement:
        return Icons.announcement;
      case MaterialType.link:
        return Icons.link;
      case MaterialType.video:
        return Icons.video_library;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
}

// Widget para agregar materiales (simplificado)
class AddMaterialSheet extends StatelessWidget {
  final Function(ClassMaterial) onMaterialAdded;
  final String classId;

  const AddMaterialSheet({super.key, required this.onMaterialAdded, required this.classId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
          children: [
            Text(
              'Agregar Material',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Aquí irían los campos para agregar material
            Expanded(
              child: Center(
                child: Text(
                  'Funcionalidad de agregar material\n(Próximamente)',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}