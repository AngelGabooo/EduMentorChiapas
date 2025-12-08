import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyectoedumentor/core/constants/app_constants.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import 'package:proyectoedumentor/features/chat/domain/models/chat_message.dart';
import 'package:proyectoedumentor/features/chat/domain/models/chat_history.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_history_drawer.dart';
import '../widgets/message_bubble.dart';
import 'dart:math'; // Para random en respuestas variables

// AÑADIDO: Import del servicio Gemini (no borra nada, solo se agrega)
import 'package:proyectoedumentor/core/services/gemini_service.dart';

// AÑADIDOS: Para historial local y UUID
import 'package:proyectoedumentor/core/services/chat_storage_service.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _currentTopic = ''; // Nueva: Memoria del tema actual para contexto

  // AÑADIDO: Instancia del servicio Gemini (se agrega aquí, no borra nada)
  final GeminiService _geminiService = GeminiService();

  // AÑADIDO: Servicio de almacenamiento local y generador de ID
  final ChatStorageService _storageService = ChatStorageService();
  final Uuid _uuid = const Uuid();

  // ID del chat actual (null si no hay uno activo)
  String? _currentChatId;

  // Historial dinámico (se carga desde local)
  List<ChatHistory> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistoryAndCurrentChat();
  }

  Future<void> _loadHistoryAndCurrentChat() async {
    final history = await _storageService.loadChatHistory();
    final currentId = await _storageService.getCurrentChatId();

    setState(() {
      _chatHistory = history;
      _currentChatId = currentId;
    });

    if (_currentChatId != null) {
      final savedMessages = await _storageService.loadMessages(_currentChatId!);
      setState(() {
        _messages = savedMessages;
      });
    }
  }

  Future<void> _ensureCurrentChat(String userMessage) async {
    if (_currentChatId != null) return;

    final newId = _uuid.v4();
    final title = userMessage.length > 30
        ? '${userMessage.substring(0, 30)}...'
        : userMessage;

    final newChat = ChatHistory(
      id: newId,
      title: title,
      lastMessage: userMessage,
      timestamp: DateTime.now(),
      messageCount: 1,
    );

    setState(() {
      _currentChatId = newId;
      _chatHistory.insert(0, newChat);
    });
  }

  Future<void> _updateCurrentChat(String lastMessage) async {
    if (_currentChatId == null) return;

    final updatedChat = ChatHistory(
      id: _currentChatId!,
      title: _chatHistory.firstWhere((c) => c.id == _currentChatId).title,
      lastMessage: lastMessage.length > 50 ? '${lastMessage.substring(0, 50)}...' : lastMessage,
      timestamp: DateTime.now(),
      messageCount: _messages.length,
    );

    final index = _chatHistory.indexWhere((c) => c.id == _currentChatId);
    if (index != -1) {
      setState(() {
        _chatHistory[index] = updatedChat;
        _chatHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    }

    await _storageService.saveChat(updatedChat, _messages);
  }

  // NUEVO: Borrar un chat individual
  Future<void> _deleteChat(String chatId) async {
    await _storageService.deleteChat(chatId);
    setState(() {
      _chatHistory.removeWhere((c) => c.id == chatId);
      if (_currentChatId == chatId) {
        _currentChatId = null;
        _messages.clear();
      }
    });
  }

  // NUEVO: Borrar todos los chats
  Future<void> _deleteAllChats() async {
    await _storageService.clearAll();
    setState(() {
      _chatHistory.clear();
      _currentChatId = null;
      _messages.clear();
    });
    _geminiService.limpiarHistorial();
  }

  void _openHistoryDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  // REEMPLAZADA: Esta función ahora usa Gemini REAL en lugar del fake
  void _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Si es el primer mensaje, crear chat nuevo
    await _ensureCurrentChat(message);

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();

    // USAMOS GEMINI DE VERDAD
    final respuesta = await _geminiService.enviarMensaje(message);

    setState(() {
      _messages.add(ChatMessage(
        text: respuesta,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
    });

    // Guardar en local
    await _updateCurrentChat(respuesta);
  }

  // TU FUNCIÓN ORIGINAL SE QUEDA TAL CUAL (no se borra, solo se deja como respaldo)
  String _generateAIResponse(String userMessage, List<ChatMessage> messages) {
    final lowerMessage = userMessage.toLowerCase();
    final random = Random();

    // Detectar y actualizar tema actual basado en keywords (con prioridad)
    if (lowerMessage.contains('matemática') || lowerMessage.contains('ecuación') ||
        lowerMessage.contains('álgebra') || lowerMessage.contains('cálculo') ||
        lowerMessage.contains('geometría') || lowerMessage.contains('estadística')) {
      _currentTopic = 'matemáticas';
    } else if (lowerMessage.contains('historia') || lowerMessage.contains('chiapas') ||
        lowerMessage.contains('originario') || lowerMessage.contains('pueblo') ||
        lowerMessage.contains('maya') || lowerMessage.contains('zapatista') ||
        lowerMessage.contains('tsotsil') || lowerMessage.contains('lacandón')) {
      _currentTopic = 'historia';
    } else if (lowerMessage.contains('español') || lowerMessage.contains('gramática') ||
        lowerMessage.contains('ortografía') || lowerMessage.contains('literatura')) {
      _currentTopic = 'español';
    } else if (lowerMessage.contains('ciencia') || lowerMessage.contains('biología') ||
        lowerMessage.contains('física') || lowerMessage.contains('química') ||
        lowerMessage.contains('sistema solar')) {
      _currentTopic = 'ciencias';
    }

    // Saludos: Más variables y referencia a tema si existe
    if (lowerMessage.contains('hola') || lowerMessage.contains('buenos días') ||
        lowerMessage.contains('buenas tardes') || lowerMessage.contains('buenas noches')) {
      final greetings = [
        '¡Hola! Soy tu asistente educativo de EduMentor AI. ¿En qué puedo ayudarte hoy? Puedo explicarte temas de matemáticas, ciencias, historia, español y más.',
        '¡Hola! Me alegra verte. Si seguimos con $_currentTopic, ¿qué duda tienes? O dime un nuevo tema.',
        '¡Buen día! ¿Listo para aprender? Cuéntame qué te interesa hoy.'
      ];
      return greetings[random.nextInt(greetings.length)];
    }

    // Follow-ups comunes (más conversacional)
    if (lowerMessage.contains('más') || lowerMessage.contains('explica') ||
        lowerMessage.contains('ejemplo') || lowerMessage.contains('paso')) {
      if (_currentTopic == 'matemáticas') {
        return 'Claro, veamos un ejemplo paso a paso. Supongamos la ecuación x² - 5x + 6 = 0. Factorizamos: (x-2)(x-3)=0, así que x=2 o x=3. ¿Quieres probar con tu ecuación específica?';
      } else if (_currentTopic == 'historia') {
        return 'Para profundizar en la historia de Chiapas, recuerda que es cuna de la civilización maya con sitios como Palenque. ¿Quieres detalles sobre un pueblo específico o la Rebelión Zapatista?';
      } else if (_currentTopic == 'español') {
        return 'Ejemplo de conjugación: "Yo corro, tú corres". Practiquemos: Conjuga "hablar" en presente. ¡Inténtalo!';
      } else if (_currentTopic == 'ciencias') {
        return 'Por ejemplo, en el sistema solar, Júpiter es el más grande con 79 lunas. ¿Quieres detalles sobre un planeta en particular?';
      }
      return '¡Genial pregunta de seguimiento! Basado en $_currentTopic, ¿puedes darme más detalles para explicarte mejor?';
    }

    // Temas específicos (con contexto si aplica)
    if (_currentTopic == 'matemáticas' || lowerMessage.contains('matemática') ||
        lowerMessage.contains('ecuación') || lowerMessage.contains('álgebra')) {
      final mathResponses = [
        'Puedo ayudarte con matemáticas. ¿Qué tipo de problema? Álgebra: resuelve ecuaciones. Geometría: teoremas. ¿Ejemplo con números?',
        'En álgebra, la clave es practicar. Si es cálculo, derivadas paso a paso. ¿Cuál es tu duda exacta?',
        '¡Matemáticas rockean! Si es estadística, media = suma / n. Cuéntame tu ejercicio.'
      ];
      return mathResponses[random.nextInt(mathResponses.length)];
    } else if (_currentTopic == 'español' || lowerMessage.contains('español') ||
        lowerMessage.contains('gramática')) {
      final spanishResponses = [
        '¡Vamos con español! Gramática: sujeto-verbo-acuerdo. Ejercicio: Corrige "Yo va a la escuela". (Respuesta: Yo voy)',
        'Literatura: Lee "Cien años de soledad". ¿Análisis o vocabulario?',
        'Ortografía: "Haber" vs "A ver". Practiquemos oraciones.'
      ];
      return spanishResponses[random.nextInt(spanishResponses.length)];
    } else if (_currentTopic == 'ciencias' || lowerMessage.contains('ciencia') ||
        lowerMessage.contains('biología')) {
      final scienceResponses = [
        'Ciencias: Biología - células procariotas vs eucariotas. ¿Pregunta específica?',
        'Física: Ley de Newton F=ma. Ejemplo: ¿Cuánta fuerza para acelerar un auto?',
        'Química: Tabla periódica, átomos. ¿Reacciones o elementos?'
      ];
      return scienceResponses[random.nextInt(scienceResponses.length)];
    } else if (lowerMessage.contains('gracias') || lowerMessage.contains('thank you')) {
      final thanksResponses = [
        '¡De nada! Estoy aquí para ayudarte. ¿Más sobre $_currentTopic o nuevo tema?',
        '¡Gracias a ti por preguntar! ¿Qué sigue en tu aprendizaje?',
        '¡Placer mío! Si necesitas repasar, solo di.'
      ];
      return thanksResponses[random.nextInt(thanksResponses.length)];
    }

    // EXPANSIÓN ESPECÍFICA PARA HISTORIA DE CHIAPAS Y PUEBLOS ORIGINARIOS
    if (_currentTopic == 'historia' || lowerMessage.contains('historia') ||
        lowerMessage.contains('chiapas') || lowerMessage.contains('maya') ||
        lowerMessage.contains('originario') || lowerMessage.contains('pueblo')) {

      // Subtema: Pueblos originarios generales
      if (lowerMessage.contains('pueblos') || lowerMessage.contains('originarios') || lowerMessage.contains('grupos')) {
        final generalResponses = [
          'Chiapas es hogar de 11 pueblos indígenas mayas y no mayas, como tsotsiles, tseltales, ch\'oles, zoques, tojolabales, mames y lacandones. Representan el 27% de la población estatal y mantienen lenguas, tradiciones y cosmovisiones únicas. ¿Quieres saber sobre uno en particular, como su cultura o historia migratoria desde Guatemala alrededor del 500 a.C.?',
          'Los pueblos originarios de Chiapas descienden de antiguas civilizaciones mayas. Viven en regiones como Los Altos, la Selva Lacandona y la Frontera Norte, practicando agricultura de maíz y rituales ancestrales. Un dato clave: su pluriculturalidad está protegida por la Constitución. ¿Qué aspecto te interesa más?',
          'Desde el periodo Formativo (2000 a.C.), Chiapas ha sido cuna de diversidad indígena. Hoy, grupos como los tsotsiles tejen textiles con lana de oveja, mientras los lacandones protegen la selva. ¡Es fascinante! ¿Empezamos con la historia prehispánica o moderna?'
        ];
        return generalResponses[random.nextInt(generalResponses.length)];
      }

      // Subtema: Tsotsiles (Tzotzil)
      if (lowerMessage.contains('tsotsil') || lowerMessage.contains('tzotzil')) {
        final tsotsilResponses = [
          'Los tsotsiles (o tzotziles, "bats\'il winik\'otik" en su lengua) son un pueblo maya en Los Altos de Chiapas, con unos 356,000 hablantes. Migraron de Guatemala ~500 a.C. y son famosos por sus textiles de lana, ponchos y rituales en San Juan Chamula, donde usan velas y limpias chamánicas. Su economía se basa en agricultura y artesanías. ¿Quieres ejemplos de sus fiestas o mitos?',
          'Cultura tsotsil: Creen en un mundo animado por deidades de la naturaleza. En Zinacantán, cultivan flores para exportar. Históricamente, resistieron la conquista española en 1524. ¡Son guardianes de tradiciones vivas! ¿Más sobre su lengua o migración?',
          'Dato curioso: Los tsotsiles organizan su vida en barrios con autoridades indígenas. Su calendario ritual guía siembras y ceremonias. Si visitas, prueba su pozol de maíz fermentado. ¿Qué más te intriga de ellos?'
        ];
        return tsotsilResponses[random.nextInt(tsotsilResponses.length)];
      }

      // Subtema: Tseltales (Tzeltal)
      if (lowerMessage.contains('tseltal') || lowerMessage.contains('tzeltal')) {
        final tseltalResponses = [
          'Los tseltales (o tzeltales, "winik atel") son mayas emparentados con los tsotsiles, habitan las Tierras Altas del Norte de Chiapas. Con ~300,000 personas, practican agricultura de milpa (maíz, frijol) y tejidos de algodón. Su historia incluye resistencia en la colonia y hoy defienden derechos territoriales. ¿Te interesa su música con marimbas o el conflicto de Bachajón?',
          'Cultura tseltal: Viven en comunidades autónomas con asambleas. Celebran el Carnaval con danzas prehispánicas. Migraron en el Posclásico maya (~900 d.C.). ¡Su biodiversidad cultural es rica! ¿Quieres detalles sobre su cosmovisión o economía?',
          'Los tseltales custodian selvas con café orgánico. Un sitio clave es Oventik, zona zapatista. ¿Más sobre su lengua maya-yucateca o tradiciones textiles?'
        ];
        return tseltalResponses[random.nextInt(tseltalResponses.length)];
      }

      // Subtema: Ch'oles (Choles)
      if (lowerMessage.contains('chol') || lowerMessage.contains('ch\'ol')) {
        final cholResponses = [
          'Los ch\'oles son un pueblo maya en la región norte de Chiapas, Tabasco y Campeche, con ~200,000 hablantes. Florecieron en el Clásico Maya (300-900 d.C.) en la cuenca del Usumacinta. Hoy, cultivan maíz en tierras tropicales y mantienen ceremonias con tamales y música. ¿Sabías que su nombre significa "gente de los ch\'oles" (pimiento)? ¿Más sobre su historia o artesanías?',
          'Historia ch\'ol: Resistieron la conquista y formaron cofradías religiosas. En Yajalón, preservan textiles con motivos geométricos. Su lengua es cholana maya. ¡Son vitales para la identidad chiapaneca! ¿Quieres ejemplos de sus mitos o economía?',
          'Los ch\'oles viven en rancherías con gobiernos cívico-religiosos. Celebran la Santa Cruz con danzas. ¿Interesado en su conexión con sitios mayas como Palenque?'
        ];
        return cholResponses[random.nextInt(cholResponses.length)];
      }

      // Subtema: Zoques
      if (lowerMessage.contains('zoque')) {
        final zoqueResponses = [
          'Los zoques son un pueblo no maya en el norte de Chiapas y parte de Oaxaca/Veracruz, con raíces en la cultura olmeca (~1500 a.C.). Tienen ~80,000 hablantes y son conocidos por su café y artesanías de barro. Históricamente, formaron señoríos precolombinos. ¿Quieres saber sobre su lengua mixe-zoque o fiestas como el Carnaval de Tapachula?',
          'Cultura zoque: Creen en nahuales (espíritus animales). En Malpaso, hay ruinas zoques. Resistieron la colonización con alianzas indígenas. ¡Su diversidad lingüística es única! ¿Más sobre migraciones o tradiciones?',
          'Dato: Los zoques practican la milpa itinerante. Su música incluye tambores y flautas. ¿Te gustaría un ejemplo de su poesía oral?'
        ];
        return zoqueResponses[random.nextInt(zoqueResponses.length)];
      }

      // Subtema: Tojolabales
      if (lowerMessage.contains('tojolabal') || lowerMessage.contains('tojolab')) {
        final tojolabalResponses = [
          'Los tojolabales son mayas en la Frontera Sur de Chiapas, cerca de Guatemala, con ~50,000 personas. Su nombre significa "gente de las milpas". Viven en comunidades con gobierno cívico-religioso y cultivan café. Historia: Migraron en el Posclásico y resistieron en la colonia. ¿Más sobre su lengua tojol-ab\'em o danzas?',
          'Cultura tojolabal: Celebran la Promesa de Mayo con procesiones. Preservan textiles con bordados. ¡Son clave en la diversidad chiapaneca! ¿Quieres detalles sobre su ecología o conflictos territoriales?',
          'Los tojolabales custodian bosques fronterizos. Un sitio: Comitán. ¿Interesado en su cosmovisión animista?'
        ];
        return tojolabalResponses[random.nextInt(tojolabalResponses.length)];
      }

      // Subtema: Mames
      if (lowerMessage.contains('mame')) {
        final mameResponses = [
          'Los mames son mayas en el occidente de Chiapas y Guatemala, con ~40,000 en Chiapas. Cultivan café y maíz en las sierras. Historia: Parte del ramo maya-mame, con asentamientos desde 1000 a.C. Famosos por su cerámica y fiestas patronales. ¿Sabías que su lengua es mameana? ¿Más sobre tradiciones o economía?',
          'Cultura mame: Viven en ejidos con asambleas. Celebran el Día de Muertos con ofrendas. Resistieron la conquista en 1530. ¡Su resiliencia es inspiradora! ¿Quieres ejemplos de su música o mitos?',
          'Los mames en Amatenango del Valle hacen figurillas de barro. ¿Te gustaría saber sobre su conexión guatemalteca?'
        ];
        return mameResponses[random.nextInt(mameResponses.length)];
      }

      // Subtema: Lacandones
      if (lowerMessage.contains('lacandón')) {
        final lacandonResponses = [
          'Los lacandones son descendientes directos de los mayas itzáes, habitan la Selva Lacandona con solo ~1,000 personas. Viven en caribales (rancherías) aisladas, cazan y cultivan. Historia: Sobrevivieron ocultos a la conquista hasta el s. XVIII. Preservan rituales con ofrendas a dioses mayas. ¿Más sobre su lengua yukateka o rol como guardianes de la biodiversidad?',
          'Cultura lacandona: Usan arcos y flechas, y su mitología incluye al dios Hachäkyum. Sitios como Nahá son sus comunidades. ¡Son los últimos mayas puros! ¿Quieres detalles sobre su selva o conflictos por deforestación?',
          'Dato: Los lacandones tatuaban su cuerpo en rituales. Hoy, promueven ecoturismo. ¿Interesado en su historia colonial?'
        ];
        return lacandonResponses[random.nextInt(lacandonResponses.length)];
      }

      // Subtema: Rebelión Zapatista
      if (lowerMessage.contains('zapatista') || lowerMessage.contains('ezln')) {
        final zapatistaResponses = [
          'La Rebelión Zapatista de 1994 fue un levantamiento indígena liderado por el EZLN (Ejército Zapatista de Liberación Nacional) el 1 de enero, coincidiendo con el TLCAN. Duró 12 días en Chiapas, demandando derechos indígenas, tierra y democracia. Terminó en cese al fuego, pero inspiró movimientos globales. Subcomandante Marcos fue su voz. ¿Quieres la cronología o su impacto actual?',
          '¡Un hito histórico! El EZLN tomó San Cristóbal de las Casas y otras cabeceras. Surgió de desigualdades en comunidades tseltales y tsotsiles. Hoy, hay juntas de buen gobierno autónomas. ¿Más sobre Marcos o los Acuerdos de San Andrés?',
          'La rebelión zapatista cuestionó el neoliberalismo y visibilizó a los pueblos originarios. Frase icónica: "¡Ya basta!". ¿Te interesa su ideología o documentales?'
        ];
        return zapatistaResponses[random.nextInt(zapatistaResponses.length)];
      }

      // Subtema: Civilización Maya y sitios arqueológicos
      if (lowerMessage.contains('maya') || lowerMessage.contains('palenque') || lowerMessage.contains('bonampak')) {
        final mayaResponses = [
          'La civilización maya en Chiapas floreció en el Clásico (250-900 d.C.), con ciudades-estado como Palenque (Bàak\'), hogar del rey Pakal y su tumba con inscripciones glíficas. Bonampak destaca por murales pintados de batallas y ceremonias (siglo VIII). Estos sitios muestran avances en astronomía y escritura. ¿Quieres explorar Yaxchilán o Toniná también?',
          'Chiapas es joya maya: Palenque, en la selva, tiene el Templo de las Inscripciones con 600 años de historia. Bonampak ("muros pintados") narra la vida real de un linaje real. Descubiertos en el s. XX, atraen miles. ¿Más sobre jeroglíficos o rituales?',
          'Los mayas chiapanecos construyeron pirámides alineadas con estrellas. En Bonampak, ves danzas y sacrificios en frescos. Historia: Colapsaron ~900 d.C. por sequías. ¿Te gustaría un tour virtual o mitos como el Popol Vuh?'
        ];
        return mayaResponses[random.nextInt(mayaResponses.length)];
      }

      // Respuestas generales de historia (si no es subtema específico)
      final historyResponses = [
        '¡Excelente! Chiapas: tsotsiles, tseltales, ch\'oles, etc. Cada uno con lenguas y culturas únicas. ¿Aspecto específico, como la herencia maya o la pluriculturalidad actual?',
        'Historia de Chiapas incluye la rebelión zapatista en 1994. ¿Quieres timeline o pueblos originarios?',
        'Los lacandones son guardianes de la selva. ¿Más sobre tradiciones o geografía?'
      ];
      return historyResponses[random.nextInt(historyResponses.length)];
    }

    // Off-topic o genérico: Sugerir tema y recordar contexto
    final genericResponses = [
      'Interesante: "$userMessage". Detecto que hablamos de $_currentTopic antes. ¿Quieres continuar ahí o cambiar a matemáticas/historia/etc.?',
      'Como asistente educativo, enfoco en aprendizaje. ¿Pregunta sobre ciencias, español o historia de Chiapas?',
      '¡Buena pregunta! Para responder mejor, dime el tema: ¿matemáticas, ciencias, etc.? O dame más detalles.'
    ];
    return genericResponses[random.nextInt(genericResponses.length)];
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _currentTopic = ''; // Reset tema al nuevo chat
      _currentChatId = null;
    });
    _geminiService.limpiarHistorial(); // Limpia el historial de Gemini
    _scaffoldKey.currentState?.closeEndDrawer();
  }

  Future<void> _loadChatHistory(String chatId) async {
    final messages = await _storageService.loadMessages(chatId);
    setState(() {
      _messages = messages;
      _currentChatId = chatId;
      _geminiService.limpiarHistorial();
    });
    _scaffoldKey.currentState?.closeEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Chat EduMentor AI',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: theme.colorScheme.primary),
            onPressed: _openHistoryDrawer,
            tooltip: 'Historial de chats',
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: ChatHistoryDrawer(
        chatHistory: _chatHistory,
        onChatSelected: _loadChatHistory,
        onNewChat: _startNewChat,
        onDeleteChat: _deleteChat, // NUEVO: Borrar individual
        onDeleteAll: _deleteAllChats, // NUEVO: Borrar todos
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(isDarkMode)
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: false,
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return MessageBubble(message: _messages[index]);
                } else {
                  return _buildTypingIndicator(isDarkMode);
                }
              },
            ),
          ),
          ChatInput(
            controller: _messageController,
            onSend: _sendMessage,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
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
                Icons.smart_toy_outlined,
                color: AppTheme.primaryColor,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'EduMentor AI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tu asistente educativo personal',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              '¿En qué puedo ayudarte hoy?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickQuestion('¿Cómo resuelvo ecuaciones?'),
                _buildQuickQuestion('Historia de Chiapas'),
                _buildQuickQuestion('Gramática en español'),
                _buildQuickQuestion('Sistema solar'),
                _buildQuickQuestion('Ejercicios de matemáticas'),
                _buildQuickQuestion('Pueblos originarios'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickQuestion(String question) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ActionChip(
      label: Text(question),
      onPressed: () => _sendMessage(question),
      backgroundColor: isDarkMode
          ? AppTheme.primaryColor.withOpacity(0.2)
          : AppTheme.primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'EduMentor AI está escribiendo',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 24,
            height: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTypingDot(),
                _buildTypingDot(),
                _buildTypingDot(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        shape: BoxShape.circle,
      ),
    );
  }
}