import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

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
      builder: (context) => _AddMaterialSheet(
        onMaterialAdded: (material) {
          setState(() => _materials.insert(0, material));
          _saveMaterials();
        },
        classId: widget.classModel.id,
        teacherEmail: widget.classModel.teacherEmail,
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
      case ClassMaterialType.document:
        return Icons.description;
      case ClassMaterialType.assignment:
        return Icons.assignment;
      case ClassMaterialType.announcement:
        return Icons.announcement;
      case ClassMaterialType.link:
        return Icons.link;
      case ClassMaterialType.video:
        return Icons.video_library;
    }
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
    final icon = _getMaterialIcon(material.type);

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
            if (material.description.isNotEmpty)
              Text(
                material.description,
                style: theme.textTheme.bodyMedium,
              ),
            // ARCHIVO ADJUNTO - AHORA DESDE RUTA LOCAL
            if (material.filePath != null && material.fileName != null)
              FutureBuilder<bool>(
                future: File(material.filePath!).exists(),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return InkWell(
                      onTap: () async {
                        final file = File(material.filePath!);
                        if (await file.exists()) {
                          await OpenFile.open(file.path);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Archivo no encontrado')),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.description, color: AppTheme.primaryColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                material.fileName!,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.open_in_new, color: AppTheme.primaryColor),
                          ],
                        ),
                      ),
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('Archivo no disponible', style: TextStyle(color: Colors.red)),
                  );
                },
              ),
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
                    child: Icon(Icons.person, color: AppTheme.primaryColor),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No hay alumnos inscritos aún',
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...widget.classModel.students.map((student) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Icon(Icons.person, size: 16, color: AppTheme.primaryColor),
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
          SizedBox(
            width: 120,
            child: Text('$label:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

// BOTTOM SHEET CON SUBIDA DE ARCHIVOS - AHORA GUARDA EN DISCO
class _AddMaterialSheet extends StatefulWidget {
  final Function(ClassMaterial) onMaterialAdded;
  final String classId;
  final String teacherEmail;

  const _AddMaterialSheet({
    required this.onMaterialAdded,
    required this.classId,
    required this.teacherEmail,
  });

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
      setState(() {
        _pickedFile = result.files.single;
      });
    }
  }

  Future<String?> _saveFileLocally(PlatformFile pickedFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
      final savePath = '${appDir.path}/class_files/$fileName';

      final directory = Directory('${appDir.path}/class_files');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es obligatorio')),
      );
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
      SnackBar(
        content: Text(fileName != null ? 'Publicado con archivo: $fileName' : 'Publicado correctamente'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Publicar en el Muro',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
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
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Título *',
              prefixIcon: const Icon(Icons.title),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Descripción (opcional)',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          _pickedFile == null
              ? OutlinedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.attach_file),
            label: const Text('Adjuntar archivo'),
          )
              : Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.description, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Expanded(child: Text(_pickedFile!.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                IconButton(
                  onPressed: () => setState(() => _pickedFile = null),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitMaterial,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Publicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}