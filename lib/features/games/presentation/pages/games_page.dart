import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import 'package:proyectoedumentor/config/providers/progress_provider.dart';
import '../widgets/game_category_card.dart';
import '../widgets/language_selector.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  String selectedLanguage = 'Español';
  final List<String> languages = ['Español', 'English', 'Lacandón', 'Mam', 'Tojol-ab\'al', 'Zoque'];
  int _currentIndex = 1; // Juegos es el índice 1

  final List<Map<String, dynamic>> gameCategories = [
    {
      'id': 1,
      'title': 'Matemáticas Básicas',
      'description': 'Sumas, restas y operaciones simples',
      'icon': Icons.calculate,
      'color': const Color(0xFF3B82F6),
      'questionCount': 4,  // Actualizado a la cantidad real
      'difficulty': 'Fácil',
    },
    {
      'id': 2,
      'title': 'Vocabulario',
      'description': 'Aprende nuevas palabras y su significado',
      'icon': Icons.language,
      'color': const Color(0xFF10B981),
      'questionCount': 4,  // Actualizado
      'difficulty': 'Intermedio',
    },
    {
      'id': 3,
      'title': 'Gramática',
      'description': 'Reglas gramaticales y estructura de oraciones',
      'icon': Icons.edit_note,
      'color': const Color(0xFF8B5CF6),
      'questionCount': 4,  // Actualizado
      'difficulty': 'Avanzado',
    },
    {
      'id': 4,
      'title': 'Ciencias',
      'description': 'Preguntas sobre ciencia y naturaleza',
      'icon': Icons.science,
      'color': const Color(0xFFF59E0B),
      'questionCount': 4,  // Actualizado
      'difficulty': 'Intermedio',
    },
    {
      'id': 5,
      'title': 'Cultura General',
      'description': 'Conocimientos generales y curiosidades',
      'icon': Icons.public,
      'color': const Color(0xFFEF4444),
      'questionCount': 4,  // Actualizado
      'difficulty': 'Mixto',
    },
    {
      'id': 6,
      'title': 'Geografía',
      'description': 'Países, capitales y ubicaciones',
      'icon': Icons.map,
      'color': const Color(0xFF06D6A0),
      'questionCount': 4,  // Actualizado
      'difficulty': 'Intermedio',
    },
  ];

  // Mapa para mapear id de categoría a 'type' por idioma (exacto para coincidir)
  final Map<String, Map<int, String>> typeMap = {
    'Español': {
      1: 'matemáticas',
      2: 'vocabulario',
      3: 'gramática',
      4: 'ciencias',
      5: 'cultura general',
      6: 'geografía',
    },
    'English': {
      1: 'math',
      2: 'vocabulary',
      3: 'grammar',
      4: 'sciences',
      5: 'general knowledge',
      6: 'geography',
    },
    'Lacandón': {
      1: 'matemáticas',
      2: 'vocabulario',
      3: 'gramática',
      4: 'ciencias',
      5: 'cultura general',
      6: 'geografía',
    },
    'Mam': {
      1: 'matemáticas',
      2: 'vocabulario',
      3: 'gramática',
      4: 'ciencias',
      5: 'cultura general',
      6: 'geografía',
    },
    'Tojol-ab\'al': {
      1: 'matemáticas',
      2: 'vocabulario',
      3: 'gramática',
      4: 'ciencias',
      5: 'cultura general',
      6: 'geografía',
    },
    'Zoque': {
      1: 'matemáticas',
      2: 'vocabulario',
      3: 'gramática',
      4: 'ciencias',
      5: 'cultura general',
      6: 'geografía',
    },
  };

  final Map<String, List<Map<String, dynamic>>> languageQuestions = {
    'Español': [
      // Matemáticas Básicas (id:1, 4 preguntas solo de mates)
      {
        'question': '¿Cuánto es 15 + 27?',
        'type': 'matemáticas',
        'options': ['42', '32', '52', '37'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Cuánto es 50 - 18?',
        'type': 'matemáticas',
        'options': ['32', '68', '30', '35'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Cuánto es 6 × 4?',
        'type': 'matemáticas',
        'options': ['24', '20', '18', '28'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Cuánto es 36 ÷ 6?',
        'type': 'matemáticas',
        'options': ['6', '4', '12', '9'],
        'correctAnswer': 0,
      },
      // Vocabulario (id:2)
      {
        'question': '¿Cómo se dice "casa" en inglés?',
        'type': 'vocabulario',
        'options': ['House', 'Home', 'Building', 'Room'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Cómo se dice "perro" en inglés?',
        'type': 'vocabulario',
        'options': ['Dog', 'Cat', 'Bird', 'Fish'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Cómo se dice "libro" en inglés?',
        'type': 'vocabulario',
        'options': ['Book', 'Notebook', 'Paper', 'Pen'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Cómo se dice "agua" en inglés?',
        'type': 'vocabulario',
        'options': ['Water', 'Milk', 'Juice', 'Tea'],
        'correctAnswer': 0,
      },
      // Gramática (id:3)
      {
        'question': 'Completa: El niño _____ jugando. (está/es/tiene)',
        'type': 'gramática',
        'options': ['está', 'es', 'tiene', 'va'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Cuál es correcto? Yo _____ al cine. (voy/va/vamos)',
        'type': 'gramática',
        'options': ['voy', 'va', 'vamos', 'vas'],
        'correctAnswer': 0,
      },
      {
        'question': 'El plural de "gato" es:',
        'type': 'gramática',
        'options': ['gatos', 'gata', 'gaton', 'gat'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Qué verbo usar? Ella _____ un libro. (lee/lees/leo)',
        'type': 'gramática',
        'options': ['lee', 'lees', 'leo', 'leemos'],
        'correctAnswer': 0,
      },
      // Ciencias (id:4)
      {
        'question': '¿Qué planeta es el más grande del sistema solar?',
        'type': 'ciencias',
        'options': ['Júpiter', 'Tierra', 'Marte', 'Saturno'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Qué gas principal compone el aire?',
        'type': 'ciencias',
        'options': ['Nitrógeno', 'Oxígeno', 'Dióxido de carbono', 'Hidrógeno'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Cuántos huesos tiene un adulto humano?',
        'type': 'ciencias',
        'options': ['206', '150', '250', '300'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Qué animal es el más rápido en tierra?',
        'type': 'ciencias',
        'options': ['Guepardo', 'León', 'Caballo', 'Elefante'],
        'correctAnswer': 0,
      },
      // Cultura General (id:5)
      {
        'question': '¿Quién pintó la Mona Lisa?',
        'type': 'cultura general',
        'options': ['Leonardo da Vinci', 'Picasso', 'Van Gogh', 'Michelangelo'],
        'correctAnswer': 0,
      },
      {
        'question': '¿En qué año llegó Cristóbal Colón a América?',
        'type': 'cultura general',
        'options': ['1492', '1500', '1450', '1600'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Cuál es el idioma más hablado del mundo?',
        'type': 'cultura general',
        'options': ['Mandarín', 'Inglés', 'Español', 'Hindi'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Qué es la Torre Eiffel?',
        'type': 'cultura general',
        'options': ['Monumento en París', 'Castillo en España', 'Puente en Londres', 'Templo en Roma'],
        'correctAnswer': 0,
      },
      // Geografía (id:6)
      {
        'question': '¿Cuál es la capital de México?',
        'type': 'geografía',
        'options': ['Ciudad de México', 'Guadalajara', 'Monterrey', 'Cancún'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Qué océano está al oeste de México?',
        'type': 'geografía',
        'options': ['Pacífico', 'Atlántico', 'Índico', 'Ártico'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Cuál es el río más largo del mundo?',
        'type': 'geografía',
        'options': ['Nilo', 'Amazonas', 'Yangtsé', 'Misisipi'],
        'correctAnswer': 0,
      },
      {
        'question': '¿En qué continente está México?',
        'type': 'geografía',
        'options': ['América', 'Europa', 'África', 'Asia'],
        'correctAnswer': 0,
      },
    ],
    'English': [
      // Math (id:1, 4 pure math questions)
      {
        'question': 'What is 15 + 27?',
        'type': 'math',
        'options': ['42', '32', '52', '37'],
        'correctAnswer': 0,
      },
      {
        'question': 'What is 50 - 18?',
        'type': 'math',
        'options': ['32', '68', '30', '35'],
        'correctAnswer': 0,
      },
      {
        'question': 'What is 6 × 4?',
        'type': 'math',
        'options': ['24', '20', '18', '28'],
        'correctAnswer': 0,
      },
      {
        'question': 'What is 36 ÷ 6?',
        'type': 'math',
        'options': ['6', '4', '12', '9'],
        'correctAnswer': 0,
      },
      // Vocabulary (id:2, words in Spanish to English)
      {
        'question': 'How do you say "casa" in English?',
        'type': 'vocabulary',
        'options': ['House', 'Home', 'Building', 'Room'],
        'correctAnswer': 0,
      },
      {
        'question': 'How do you say "perro" in English?',
        'type': 'vocabulary',
        'options': ['Dog', 'Cat', 'Bird', 'Fish'],
        'correctAnswer': 0,
      },
      {
        'question': 'How do you say "libro" in English?',
        'type': 'vocabulary',
        'options': ['Book', 'Notebook', 'Paper', 'Pen'],
        'correctAnswer': 0,
      },
      {
        'question': 'How do you say "agua" in English?',
        'type': 'vocabulary',
        'options': ['Water', 'Milk', 'Juice', 'Tea'],
        'correctAnswer': 0,
      },
      // Grammar (id:3)
      {
        'question': 'Complete: The boy _____ playing. (is/are/has)',
        'type': 'grammar',
        'options': ['is', 'are', 'has', 'goes'],
        'correctAnswer': 0,
      },
      {
        'question': 'Which is correct? I _____ to the movies. (go/goes/going)',
        'type': 'grammar',
        'options': ['go', 'goes', 'going', 'went'],
        'correctAnswer': 0,
      },
      {
        'question': 'The plural of "cat" is:',
        'type': 'grammar',
        'options': ['cats', 'cata', 'caton', 'cat'],
        'correctAnswer': 0,
      },
      {
        'question': 'What verb to use? She _____ a book. (reads/read/readed)',
        'type': 'grammar',
        'options': ['reads', 'read', 'readed', 'reading'],
        'correctAnswer': 0,
      },
      // Sciences (id:4)
      {
        'question': 'What is the largest planet in the solar system?',
        'type': 'sciences',
        'options': ['Jupiter', 'Earth', 'Mars', 'Saturn'],
        'correctAnswer': 0,
      },
      {
        'question': 'What is the main gas in the air?',
        'type': 'sciences',
        'options': ['Nitrogen', 'Oxygen', 'Carbon dioxide', 'Hydrogen'],
        'correctAnswer': 0,
      },
      {
        'question': 'How many bones does an adult human have?',
        'type': 'sciences',
        'options': ['206', '150', '250', '300'],
        'correctAnswer': 0,
      },
      {
        'question': 'What is the fastest land animal?',
        'type': 'sciences',
        'options': ['Cheetah', 'Lion', 'Horse', 'Elephant'],
        'correctAnswer': 0,
      },
      // General Knowledge (id:5)
      {
        'question': 'Who painted the Mona Lisa?',
        'type': 'general knowledge',
        'options': ['Leonardo da Vinci', 'Picasso', 'Van Gogh', 'Michelangelo'],
        'correctAnswer': 0,
      },
      {
        'question': 'In what year did Christopher Columbus reach America?',
        'type': 'general knowledge',
        'options': ['1492', '1500', '1450', '1600'],
        'correctAnswer': 0,
      },
      {
        'question': 'What is the most spoken language in the world?',
        'type': 'general knowledge',
        'options': ['Mandarin', 'English', 'Spanish', 'Hindi'],
        'correctAnswer': 0,
      },
      {
        'question': 'What is the Eiffel Tower?',
        'type': 'general knowledge',
        'options': ['Monument in Paris', 'Castle in Spain', 'Bridge in London', 'Temple in Rome'],
        'correctAnswer': 0,
      },
      // Geography (id:6)
      {
        'question': 'What is the capital of Mexico?',
        'type': 'geography',
        'options': ['Mexico City', 'Guadalajara', 'Monterrey', 'Cancun'],
        'correctAnswer': 0,
      },
      {
        'question': 'What ocean is west of Mexico?',
        'type': 'geography',
        'options': ['Pacific', 'Atlantic', 'Indian', 'Arctic'],
        'correctAnswer': 0,
      },
      {
        'question': 'What is the longest river in the world?',
        'type': 'geography',
        'options': ['Nile', 'Amazon', 'Yangtze', 'Mississippi'],
        'correctAnswer': 0,
      },
      {
        'question': 'On which continent is Mexico?',
        'type': 'geography',
        'options': ['America', 'Europe', 'Africa', 'Asia'],
        'correctAnswer': 0,
      },
    ],
    'Lacandón': [
      // Matemáticas Básicas (id:1, 4 preguntas solo de mates)
      {
        'question': '¿Ba\'ax chéen 15 + 27?',
        'type': 'matemáticas',
        'options': ['42', '32', '52', '37'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Ba\'ax chéen 50 - 18?',
        'type': 'matemáticas',
        'options': ['32', '68', '30', '35'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Ba\'ax chéen 6 × 4?',
        'type': 'matemáticas',
        'options': ['24', '20', '18', '28'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Ba\'ax chéen 36 ÷ 6?',
        'type': 'matemáticas',
        'options': ['6', '4', '12', '9'],
        'correctAnswer': 0,
      },
      // Vocabulario (id:2)
      {
        'question': '¿Bix u k\'aaba\' "casa" le inglés?',
        'type': 'vocabulario',
        'options': ['House', 'Home', 'Building', 'Room'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Bix u k\'aaba\' "perro" le inglés?',
        'type': 'vocabulario',
        'options': ['Dog', 'Cat', 'Bird', 'Fish'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Bix u k\'aaba\' "libro" le inglés?',
        'type': 'vocabulario',
        'options': ['Book', 'Notebook', 'Paper', 'Pen'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Bix u k\'aaba\' "agua" le inglés?',
        'type': 'vocabulario',
        'options': ['Water', 'Milk', 'Juice', 'Tea'],
        'correctAnswer': 0,
      },
      // Gramática (id:3)
      {
        'question': 'Ts\'íib: Le ch\'úupal _____ k\'aay. (yáanal/táan/yéetel)',
        'type': 'gramática',
        'options': ['yáanal', 'táan', 'yéetel', 'bin'],
        'correctAnswer': 1,
      },
      {
        'question': '¿Máax ku páajtal? In _____ ti\' le teatro. (bin/ku bin/ka bin)',
        'type': 'gramática',
        'options': ['bin', 'ku bin', 'ka bin', 'ta bin'],
        'correctAnswer': 0,
      },
      {
        'question': 'Le múltiplo u "míis" leti\'e\'',
        'type': 'gramática',
        'options': ['míiso\'ob', 'míisa\'', 'míison', 'míis'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Ba\'ax jump\'éel verbo? Leti\' _____ jump\'éel wuj. (ku xook/k xook/ka xook)',
        'type': 'gramática',
        'options': ['ku xook', 'k xook', 'ka xook', 'ka xooko\'ob'],
        'correctAnswer': 0,
      },
      // Ciencias (id:4)
      {
        'question': '¿Máax u nojoch planeta ti\' le sistema solar?',
        'type': 'ciencias',
        'options': ['Júpiter', 'Tierra', 'Marte', 'Saturno'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Ba\'ax u gas principal le k\'i\'ik\'?',
        'type': 'ciencias',
        'options': ['Nitrógeno', 'Oxígeno', 'Dióxido de carbono', 'Hidrógeno'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Jach ja\'abil baakal ku suku\'un jump\'éel wíiniko\'ob?',
        'type': 'ciencias',
        'options': ['206', '150', '250', '300'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Máax u chich chíichilo\'ob ti\' lu\'um?',
        'type': 'ciencias',
        'options': ['Guepardo', 'León', 'Caballo', 'Elefante'],
        'correctAnswer': 0,
      },
      // Cultura General (id:5)
      {
        'question': '¿Máax tu ts\'íibtaj le Mona Lisa?',
        'type': 'cultura general',
        'options': ['Leonardo da Vinci', 'Picasso', 'Van Gogh', 'Michelangelo'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Tu\'ux ja\'abil Cristóbal Colón kuchij ti\' América?',
        'type': 'cultura general',
        'options': ['1492', '1500', '1450', '1600'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Máax u nojoch t\'aan ti\' le mundo?',
        'type': 'cultura general',
        'options': ['Mandarín', 'Inglés', 'Español', 'Hindi'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Ba\'ax le Torre Eiffel?',
        'type': 'cultura general',
        'options': ['Monumento ti\' París', 'Castillo ti\' España', 'Puente ti\' Londres', 'Templo ti\' Roma'],
        'correctAnswer': 0,
      },
      // Geografía (id:6)
      {
        'question': '¿Máax u noj kaajil México?',
        'type': 'geografía',
        'options': ['Ciudad de México', 'Guadalajara', 'Monterrey', 'Cancún'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Máax u océano yaan xno\'oha\' México?',
        'type': 'geografía',
        'options': ['Pacífico', 'Atlántico', 'Índico', 'Ártico'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Máax u nojoch ja\' ti\' le mundo?',
        'type': 'geografía',
        'options': ['Nilo', 'Amazonas', 'Yangtsé', 'Misisipi'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Tu\'ux continente yaan México?',
        'type': 'geografía',
        'options': ['América', 'Europa', 'África', 'Asia'],
        'correctAnswer': 0,
      },
    ],
    'Mam': [
      // Matemáticas Básicas (id:1, 4 preguntas solo de mates)
      {
        'question': '¿Jas 15 + 27?',
        'type': 'matemáticas',
        'options': ['42', '32', '52', '37'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Jas 50 - 18?',
        'type': 'matemáticas',
        'options': ['32', '68', '30', '35'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Jas 6 × 4?',
        'type': 'matemáticas',
        'options': ['24', '20', '18', '28'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Jas 36 ÷ 6?',
        'type': 'matemáticas',
        'options': ['6', '4', '12', '9'],
        'correctAnswer': 0,
      },
      // Vocabulario (id:2)
      {
        'question': '¿Jas t-xa\'n "casa" pa inglés?',
        'type': 'vocabulario',
        'options': ['House', 'Home', 'Building', 'Room'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Jas t-xa\'n "perro" pa inglés?',
        'type': 'vocabulario',
        'options': ['Dog', 'Cat', 'Bird', 'Fish'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Jas t-xa\'n "libro" pa inglés?',
        'type': 'vocabulario',
        'options': ['Book', 'Notebook', 'Paper', 'Pen'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Jas t-xa\'n "agua" pa inglés?',
        'type': 'vocabulario',
        'options': ['Water', 'Milk', 'Juice', 'Tea'],
        'correctAnswer': 0,
      },
      // Gramática (id:3)
      {
        'question': 'Tz\'ib\'aj: A Xhinh _____ tzaj. (oj/etal/q\'ij)',
        'type': 'gramática',
        'options': ['oj', 'etal', 'q\'ij', 'b\'en'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Achike nk\'ulub\'a? In _____ pa cine. (b\'en/nb\'en/qab\'en)',
        'type': 'gramática',
        'options': ['b\'en', 'nb\'en', 'qab\'en', 'tb\'en'],
        'correctAnswer': 0,
      },
      {
        'question': 'A ti\' "miis" q\'inaq',
        'type': 'gramática',
        'options': ['miis', 'miisa\'', 'miison', 'miisi\''],
        'correctAnswer': 3,
      },
      {
        'question': '¿Achike wujil? Xe\' _____ jun wuj. (nxaq\'/xaq\'/qxaq\')',
        'type': 'gramática',
        'options': ['nxaq\'', 'xaq\'', 'qxaq\'', 'txaq\''],
        'correctAnswer': 0,
      },
      // Ciencias (id:4)
      {
        'question': '¿Achike nima\' planeta pa sistema solar?',
        'type': 'ciencias',
        'options': ['Júpiter', 'Tierra', 'Marte', 'Saturno'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Achike nima\' gas pa ik\'?',
        'type': 'ciencias',
        'options': ['Nitrógeno', 'Oxígeno', 'Dióxido de carbono', 'Hidrógeno'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Jas b\'aq\'il k\'o pa jun winq?',
        'type': 'ciencias',
        'options': ['206', '150', '250', '300'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Achike chikop nima\' yab\'il pa ulew?',
        'type': 'ciencias',
        'options': ['Guepardo', 'León', 'Caballo', 'Elefante'],
        'correctAnswer': 0,
      },
      // Cultura General (id:5)
      {
        'question': '¿Achike xtz\'ib\'aj Mona Lisa?',
        'type': 'cultura general',
        'options': ['Leonardo da Vinci', 'Picasso', 'Van Gogh', 'Michelangelo'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Jas xq\'ij Cristóbal Colón xpe pa América?',
        'type': 'cultura general',
        'options': ['1492', '1500', '1450', '1600'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Achike nima\' tziji pa mundo?',
        'type': 'cultura general',
        'options': ['Mandarín', 'Inglés', 'Español', 'Hindi'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Achike Torre Eiffel?',
        'type': 'cultura general',
        'options': ['Monumento pa París', 'Castillo pa España', 'Puente pa Londres', 'Templo pa Roma'],
        'correctAnswer': 0,
      },
      // Geografía (id:6)
      {
        'question': '¿Achike nima\' tinamit México?',
        'type': 'geografía',
        'options': ['Ciudad de México', 'Guadalajara', 'Monterrey', 'Cancún'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Achike nima\' ja\' xikin México?',
        'type': 'geografía',
        'options': ['Pacífico', 'Atlántico', 'Índico', 'Ártico'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Achike nima\' ja\' pa mundo?',
        'type': 'geografía',
        'options': ['Nilo', 'Amazonas', 'Yangtsé', 'Misisipi'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Achike continente k\'o México?',
        'type': 'geografía',
        'options': ['América', 'Europa', 'África', 'Asia'],
        'correctAnswer': 0,
      },
    ],
    'Tojol-ab\'al': [
      // Matemáticas Básicas (id:1, 4 preguntas solo de mates)
      {
        'question': '¿Bajche\' 15 + 27?',
        'type': 'matemáticas',
        'options': ['42', '32', '52', '37'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Bajche\' 50 - 18?',
        'type': 'matemáticas',
        'options': ['32', '68', '30', '35'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Bajche\' 6 × 4?',
        'type': 'matemáticas',
        'options': ['24', '20', '18', '28'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Bajche\' 36 ÷ 6?',
        'type': 'matemáticas',
        'options': ['6', '4', '12', '9'],
        'correctAnswer': 0,
      },
      // Vocabulario (id:2)
      {
        'question': '¿Bajche\' "casa" ja\' inglés?',
        'type': 'vocabulario',
        'options': ['House', 'Home', 'Building', 'Room'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Bajche\' "perro" ja\' inglés?',
        'type': 'vocabulario',
        'options': ['Dog', 'Cat', 'Bird', 'Fish'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Bajche\' "libro" ja\' inglés?',
        'type': 'vocabulario',
        'options': ['Book', 'Notebook', 'Paper', 'Pen'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Bajche\' "agua" ja\' inglés?',
        'type': 'vocabulario',
        'options': ['Water', 'Milk', 'Juice', 'Tea'],
        'correctAnswer': 0,
      },
      // Gramática (id:3)
      {
        'question': 'Ch\'ayb\'aj: Ja\' winik _____ aj. (yaj/taj/k\'aj)',
        'type': 'gramática',
        'options': ['yaj', 'taj', 'k\'aj', 'b\'in'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach\'a yuj? In _____ ta cine. (b\'in/nb\'in/kb\'in)',
        'type': 'gramática',
        'options': ['b\'in', 'nb\'in', 'kb\'in', 'tb\'in'],
        'correctAnswer': 0,
      },
      {
        'question': 'Ja\' "miis" yujub\'il',
        'type': 'gramática',
        'options': ['miiso\'ob', 'miisa\'', 'miison', 'miis'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach\'a wuj? Xe\' _____ jun wuj. (nik\'an/ik\'an/kik\'an)',
        'type': 'gramática',
        'options': ['nik\'an', 'ik\'an', 'kik\'an', 'tik\'an'],
        'correctAnswer': 0,
      },
      // Ciencias (id:4)
      {
        'question': '¿Mach\'a nopil planeta ja\' sistema solar?',
        'type': 'ciencias',
        'options': ['Júpiter', 'Tierra', 'Marte', 'Saturno'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach\'a nopil gas ja\' ik\'?',
        'type': 'ciencias',
        'options': ['Nitrógeno', 'Oxígeno', 'Dióxido de carbono', 'Hidrógeno'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Bajche\' b\'aq\'il k\'an ja\' jun winik?',
        'type': 'ciencias',
        'options': ['206', '150', '250', '300'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach\'a chijom nopil yab\'il ja\' lum?',
        'type': 'ciencias',
        'options': ['Guepardo', 'León', 'Caballo', 'Elefante'],
        'correctAnswer': 0,
      },
      // Cultura General (id:5)
      {
        'question': '¿Mach\'a xtz\'ib\'aj Mona Lisa?',
        'type': 'cultura general',
        'options': ['Leonardo da Vinci', 'Picasso', 'Van Gogh', 'Michelangelo'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Bajche\' xq\'ij Cristóbal Colón xpe ja\' América?',
        'type': 'cultura general',
        'options': ['1492', '1500', '1450', '1600'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach\'a nopil tzij ja\' mundo?',
        'type': 'cultura general',
        'options': ['Mandarín', 'Inglés', 'Español', 'Hindi'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach\'a Torre Eiffel?',
        'type': 'cultura general',
        'options': ['Monumento ja\' París', 'Castillo ja\' España', 'Puente ja\' Londres', 'Templo ja\' Roma'],
        'correctAnswer': 0,
      },
      // Geografía (id:6)
      {
        'question': '¿Mach\'a nopil tinamit México?',
        'type': 'geografía',
        'options': ['Ciudad de México', 'Guadalajara', 'Monterrey', 'Cancún'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach\'a nopil ja\' xikin México?',
        'type': 'geografía',
        'options': ['Pacífico', 'Atlántico', 'Índico', 'Ártico'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach\'a nopil ja\' ja\' mundo?',
        'type': 'geografía',
        'options': ['Nilo', 'Amazonas', 'Yangtsé', 'Misisipi'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach\'a continente k\'an México?',
        'type': 'geografía',
        'options': ['América', 'Europa', 'África', 'Asia'],
        'correctAnswer': 0,
      },
    ],
    'Zoque': [
      // Matemáticas Básicas (id:1, 4 preguntas solo de mates)
      {
        'question': '¿Jama 15 + 27?',
        'type': 'matemáticas',
        'options': ['42', '32', '52', '37'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Jama 50 - 18?',
        'type': 'matemáticas',
        'options': ['32', '68', '30', '35'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Jama 6 × 4?',
        'type': 'matemáticas',
        'options': ['24', '20', '18', '28'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Jama 36 ÷ 6?',
        'type': 'matemáticas',
        'options': ['6', '4', '12', '9'],
        'correctAnswer': 0,
      },
      // Vocabulario (id:2)
      {
        'question': '¿Jama "casa" ga inglés?',
        'type': 'vocabulario',
        'options': ['House', 'Home', 'Building', 'Room'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Jama "perro" ga inglés?',
        'type': 'vocabulario',
        'options': ['Dog', 'Cat', 'Bird', 'Fish'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Jama "libro" ga inglés?',
        'type': 'vocabulario',
        'options': ['Book', 'Notebook', 'Paper', 'Pen'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Jama "agua" ga inglés?',
        'type': 'vocabulario',
        'options': ['Water', 'Milk', 'Juice', 'Tea'],
        'correctAnswer': 0,
      },
      // Gramática (id:3)
      {
        'question': 'Choyb\'aj: Ja\' tata _____ majki. (yaj/taj/k\'aj)',
        'type': 'gramática',
        'options': ['yaj', 'taj', 'k\'aj', 'wej'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach aj? In _____ ga cine. (wej/nwej/kwej)',
        'type': 'gramática',
        'options': ['wej', 'nwej', 'kwej', 'twej'],
        'correctAnswer': 0,
      },
      {
        'question': 'Ja\' "miso" choyb\'aj',
        'type': 'gramática',
        'options': ['misot', 'misa\'', 'mison', 'miso'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach wuj? Xe\' _____ jun wuj. (nuk\'a/uk\'a/kuk\'a)',
        'type': 'gramática',
        'options': ['nuk\'a', 'uk\'a', 'kuk\'a', 'tuk\'a'],
        'correctAnswer': 0,
      },
      // Ciencias (id:4)
      {
        'question': '¿Mach mok planeta ga sistema solar?',
        'type': 'ciencias',
        'options': ['Júpiter', 'Tierra', 'Marte', 'Saturno'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach mok gas ga yomo\'?',
        'type': 'ciencias',
        'options': ['Nitrógeno', 'Oxígeno', 'Dióxido de carbono', 'Hidrógeno'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Jama b\'aq\'il k\'aj ja\' jun winik?',
        'type': 'ciencias',
        'options': ['206', '150', '250', '300'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach choyo mok yab\'il ga lum?',
        'type': 'ciencias',
        'options': ['Guepardo', 'León', 'Caballo', 'Elefante'],
        'correctAnswer': 0,
      },
      // Cultura General (id:5)
      {
        'question': '¿Mach xtz\'ib\'aj Mona Lisa?',
        'type': 'cultura general',
        'options': ['Leonardo da Vinci', 'Picasso', 'Van Gogh', 'Michelangelo'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Jama xq\'ij Cristóbal Colón xpe ga América?',
        'type': 'cultura general',
        'options': ['1492', '1500', '1450', '1600'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach mok tzij ga mundo?',
        'type': 'cultura general',
        'options': ['Mandarín', 'Inglés', 'Español', 'Hindi'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach Torre Eiffel?',
        'type': 'cultura general',
        'options': ['Monumento ga París', 'Castillo ga España', 'Puente ga Londres', 'Templo ga Roma'],
        'correctAnswer': 0,
      },
      // Geografía (id:6)
      {
        'question': '¿Mach mok tinamit México?',
        'type': 'geografía',
        'options': ['Ciudad de México', 'Guadalajara', 'Monterrey', 'Cancún'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach mok ja\' xikin México?',
        'type': 'geografía',
        'options': ['Pacífico', 'Atlántico', 'Índico', 'Ártico'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach mok ja\' ga mundo?',
        'type': 'geografía',
        'options': ['Nilo', 'Amazonas', 'Yangtsé', 'Misisipi'],
        'correctAnswer': 0,
      },
      {
        'question': '¿Mach continente k\'aj México?',
        'type': 'geografía',
        'options': ['América', 'Europa', 'África', 'Asia'],
        'correctAnswer': 0,
      },
    ],
  };

  void _onLanguageChanged(String language) {
    setState(() {
      selectedLanguage = language;
    });
  }

  void _onGameSelected(Map<String, dynamic> game) {
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    progressProvider.notifyListeners();

    // Obtener el type esperado para este game y idioma
    String expectedType = typeMap[selectedLanguage]![game['id']] ?? 'matemáticas'; // Fallback por si acaso

    // Filtrar SOLO las preguntas de este type
    List<Map<String, dynamic>> allQuestions = _getQuestionsForLanguage(selectedLanguage);
    List<Map<String, dynamic>> filteredQuestions = allQuestions.where((q) => q['type'] == expectedType).toList();

    context.push('/game-play', extra: {
      'game': game,
      'language': selectedLanguage,
      'questions': filteredQuestions,  // Ahora solo las 4 del tema
      'gameId': game['id'],
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navegar a la pantalla correspondiente
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
      // Ya estamos en juegos
        break;
      case 2:
        context.go('/library');
        break;
      case 3:
        context.go('/process');
        break;
      case 4:
        context.go('/my-profile');
        break;
    }
  }

  List<Map<String, dynamic>> _getQuestionsForLanguage(String language) {
    return languageQuestions[language] ?? languageQuestions['Español']!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Juegos Educativos',
          style: theme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Selector de idioma
            LanguageSelector(
              selectedLanguage: selectedLanguage,
              languages: languages,
              onLanguageChanged: _onLanguageChanged,
            ),

            // Lista de juegos
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categorías de Juegos - $selectedLanguage',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selecciona una categoría para comenzar a jugar',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: gameCategories.length,
                        itemBuilder: (context, index) {
                          return GameCategoryCard(
                            game: gameCategories[index],
                            onTap: () => _onGameSelected(gameCategories[index]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar agregado
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.cardColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset_outlined),
            activeIcon: Icon(Icons.videogame_asset_rounded),
            label: 'Juegos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books_rounded),
            label: 'Biblioteca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline_outlined),
            activeIcon: Icon(Icons.timeline_rounded),
            label: 'Proceso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}