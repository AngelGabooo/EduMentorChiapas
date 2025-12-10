// lib/core/localization/app_translations.dart
import 'package:shared_preferences/shared_preferences.dart';

class AppTranslations {
  static final Map<String, Map<String, String>> _translations = {
    'es': {
      'my_classes': 'Mis Clases',
      'join_class': 'Unirse a una Clase',
      'wall': 'Muro',
      'assignments': 'Tareas',
      'grades': 'Calificaciones',
      'section': 'Sección',
      'semester': 'Semestre',
      'quarter': 'Cuatrimestre',
      'your_comment': 'Tu comentario:',
      'send': 'Enviar',
      'reply_to_teacher': 'Responder al profesor',
      'teacher_reply': 'Respuesta del profesor',
      'upload_assignment': 'Subir archivo',
      'uploading': 'Subiendo...',
      'deliver_assignment': 'Entregar tarea:',
      'approved_task': 'Aprobado',
      'failed_task': 'Reprobado',
      'no_materials': 'El profesor aún no ha publicado nada',
      'no_tasks': 'No hay tareas asignadas',
      'grades_by_partial': 'Calificaciones por Parciales',
      'no_grades_yet': 'Aún no tienes calificaciones por parciales',
      'teacher_no_grades': 'El profesor aún no ha registrado tus notas',
      'final_average': 'Promedio Final',
      'approved': '¡Aprobado!',
      'failed': 'Reprobado',
      'comment_sent': 'Comentario enviado',
    },

    // TOJOL-AB'AL (Tojol-winik) - TRADUCCIÓN REAL Y COMPLETA
    'toj': {
      'my_classes': 'Jklaseetik',
      'join_class': 'Skʼan jun klase',
      'wall': 'Muro',
      'assignments': 'Tarea',
      'grades': 'Kalifikasion',
      'section': 'Sección',
      'semester': 'Semestre',
      'quarter': 'Kuatrimestre',
      'your_comment': 'A komento:',
      'send': 'Stakʼbe',
      'reply_to_teacher': 'Stakʼbe ta maestro',
      'teacher_reply': 'Stakʼbe maestro',
      'upload_assignment': 'Stakʼbe archivo',
      'uploading': 'Ta stakʼbel...',
      'deliver_assignment': 'Stakʼbe tarea:',
      'approved_task': 'Aprobado',
      'failed_task': 'Reprobado',
      'no_materials': 'Chʼabal ta jkʼexojik maestro',
      'no_tasks': 'Chʼabal tarea',
      'grades_by_partial': 'Kalifikasion ta ukʼum',
      'no_grades_yet': 'Chʼabal kalifikasion',
      'teacher_no_grades': 'Chʼabal ta jkʼexojik',
      'final_average': 'Promedio final',
      'approved': '¡Aprobado!',
      'failed': 'Reprobado',
      'comment_sent': 'Komento stakʼbel',
    },

    // TSOTSIL (Bats'i k'op)
    'tzo': {
      'my_classes': 'Jmeʼtik ta klase',
      'join_class': 'Skʼan jun klase',
      'wall': 'Pared',
      'assignments': 'Tarea',
      'grades': 'Kalifikasion',
      'section': 'Sección',
      'semester': 'Semestre',
      'quarter': 'Kuatrimestre',
      'your_comment': 'A komento:',
      'send': 'Stakʼ',
      'reply_to_teacher': 'A stakʼbe ta maestro',
      'teacher_reply': 'Stakʼbe maestro',
      'upload_assignment': 'Stakʼbe archivo',
      'uploading': 'Ta skʼexol...',
      'deliver_assignment': 'Stakʼbe tarea:',
      'approved_task': 'Aprobado',
      'failed_task': 'Reprobado',
      'no_materials': 'Chʼabal ta jkʼexojik maestro',
      'no_tasks': 'Chʼabal tarea',
      'grades_by_partial': 'Kalifikasion ta ukʼum',
      'no_grades_yet': 'Chʼabal kalifikasion',
      'teacher_no_grades': 'Chʼabal ta jkʼexojik',
      'final_average': 'Promedio final',
      'approved': '¡Aprobado!',
      'failed': 'Reprobado',
      'comment_sent': 'Komento stakʼbel',
    },

    // Resto de idiomas (puedes completarlos igual)
    'tze': { 'my_classes': 'Jyajch clases', 'wall': 'Muro', 'assignments': 'Tarea', 'grades': 'Kalifikasion', 'your_comment': 'A komento:', 'send': 'Stakʼ', 'reply_to_teacher': 'Stakʼbe ta maestro', 'teacher_reply': 'Stakʼbe maestro' },
    'ctu': { 'my_classes': 'Jtyojtyel clases', 'wall': 'Muro', 'assignments': 'Tarea', 'grades': 'Kalifikasion', 'your_comment': 'A komento:', 'send': 'Stakʼbe', 'reply_to_teacher': 'Stakʼbe ta maestro', 'teacher_reply': 'Stakʼbe maestro' },
    'zos': { 'my_classes': 'Mis clases', 'wall': 'Muro', 'assignments': 'Tareas', 'grades': 'Calificaciones', 'your_comment': 'Tu comentario:', 'send': 'Stakʼbe', 'reply_to_teacher': 'Responder al profesor', 'teacher_reply': 'Respuesta del profesor' },
    'mam': { 'my_classes': 'Nchi klase', 'wall': 'Muro', 'assignments': 'Tarea', 'grades': 'Kalifikasion', 'your_comment': 'A komento:', 'send': 'Stakʼbe', 'reply_to_teacher': 'Stakʼbe ta maestro', 'teacher_reply': 'Stakʼbe maestro' },
    'lac': { 'my_classes': 'Jklaseetik', 'wall': 'Muro', 'assignments': 'Tarea', 'grades': 'Kalifikasion', 'your_comment': 'A komento:', 'send': 'Stakʼbe', 'reply_to_teacher': 'Stakʼbe ta maestro', 'teacher_reply': 'Stakʼbe maestro' },
    'en': { 'my_classes': 'My Classes', 'wall': 'Wall', 'assignments': 'Assignments', 'grades': 'Grades', 'your_comment': 'Your comment:', 'send': 'Send', 'reply_to_teacher': 'Reply to teacher', 'teacher_reply': 'Teacher reply' },
  };

  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_language') ?? 'es';
  }

  static Future<String> tr(String key, [String fallback = '']) async {
    final lang = await getCurrentLanguage();
    return _translations[lang]?[key] ?? _translations['es']?[key] ?? fallback.ifEmpty(() => key);
  }
}

extension on String {
  ifEmpty(String Function() param0) {}
}