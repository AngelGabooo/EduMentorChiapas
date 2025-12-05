import 'package:flutter/material.dart';

class ProgressProvider extends ChangeNotifier {
  int _totalPoints = 0;
  int _completedGames = 0;
  int _streakDays = 0;
  DateTime? _lastPlayDate;
  String _currentLevel = 'Fácil';
  final int _totalGames = 50;
  final List<String> _completedGamesHistory = [];
  double _totalStudyHours = 0.0;
  DateTime? _studySessionStart;
  bool _isStudying = false;
  Map<String, double> _weeklyStudyHours = {
    'Lun': 0.0,
    'Mar': 0.0,
    'Mié': 0.0,
    'Jue': 0.0,
    'Vie': 0.0,
    'Sáb': 0.0,
    'Dom': 0.0,
  };

  int get totalPoints => _totalPoints;
  int get completedGames => _completedGames;
  int get streakDays => _streakDays;
  String get currentLevel => _currentLevel;
  double get progressPercentage => (_completedGames / _totalGames) * 100;
  int get totalLessons => _totalGames;
  int get completedLessons => _completedGames;
  List<String> get completedGamesHistory => _completedGamesHistory;
  double get totalStudyHours => _totalStudyHours;
  bool get isStudying => _isStudying;
  Map<String, double> get weeklyStudyHours => _weeklyStudyHours;
  int get exercisesCompleted => _completedGames * 10;

  void startStudySession() {
    if (!_isStudying) {
      _studySessionStart = DateTime.now();
      _isStudying = true;
      notifyListeners();
    }
  }

  void endStudySession() {
    if (_isStudying && _studySessionStart != null) {
      final now = DateTime.now();
      final duration = now.difference(_studySessionStart!);
      final hours = duration.inMinutes / 60.0;
      _totalStudyHours += hours;
      final currentDay = _getCurrentDayAbbreviation();
      _weeklyStudyHours[currentDay] = _weeklyStudyHours[currentDay]! + hours;
      _isStudying = false;
      _studySessionStart = null;
      notifyListeners();
    }
  }

  void addPoints(int points) {
    _totalPoints += points;
    notifyListeners();
  }

  void completeGame(String gameTitle) {
    _completedGames++;
    _completedGamesHistory.add(gameTitle);
    if (_completedGamesHistory.length > 50) {
      _completedGamesHistory.removeAt(0);
    }
    _updateLevel();
    _updateStreak();
    notifyListeners();
  }

  void _updateLevel() {
    if (_completedGames < 16) {
      _currentLevel = 'Fácil';
    } else if (_completedGames < 40) {
      _currentLevel = 'Medio';
    } else {
      _currentLevel = 'Avanzado';
    }
  }

  void _updateStreak() {
    final today = DateTime.now();
    if (_lastPlayDate == null || _lastPlayDate!.day != today.day) {
      if (_lastPlayDate != null && _lastPlayDate!.difference(today).inDays == -1) {
        _streakDays++;
      } else {
        _streakDays = 1;
      }
      _lastPlayDate = today;
    }
  }

  String _getCurrentDayAbbreviation() {
    final now = DateTime.now();
    switch (now.weekday) {
      case 1: return 'Lun';
      case 2: return 'Mar';
      case 3: return 'Mié';
      case 4: return 'Jue';
      case 5: return 'Vie';
      case 6: return 'Sáb';
      case 7: return 'Dom';
      default: return 'Lun';
    }
  }

  Map<String, dynamic> getRecentActivity() {
    return {
      'studyHours': _totalStudyHours,
      'exercisesCompleted': exercisesCompleted,
      'currentStreak': _streakDays,
      'lastActivity': _isStudying ? 'Estudiando ahora' : _getLastActivityMessage(),
    };
  }

  List<Map<String, dynamic>> getWeeklyActivity() {
    return [
      {'day': 'Lun', 'hours': _weeklyStudyHours['Lun']!},
      {'day': 'Mar', 'hours': _weeklyStudyHours['Mar']!},
      {'day': 'Mié', 'hours': _weeklyStudyHours['Mié']!},
      {'day': 'Jue', 'hours': _weeklyStudyHours['Jue']!},
      {'day': 'Vie', 'hours': _weeklyStudyHours['Vie']!},
      {'day': 'Sáb', 'hours': _weeklyStudyHours['Sáb']!},
      {'day': 'Dom', 'hours': _weeklyStudyHours['Dom']!},
    ];
  }

  String _getLastActivityMessage() {
    if (_lastPlayDate != null) {
      final now = DateTime.now();
      final difference = now.difference(_lastPlayDate!);
      if (difference.inMinutes < 60) {
        return 'Hoy - ${difference.inMinutes} min de estudio';
      } else if (difference.inHours < 24) {
        return 'Hoy - ${difference.inHours} horas de estudio';
      } else {
        return 'Hace ${difference.inDays} días';
      }
    }
    return 'Sin actividad reciente';
  }

  void resetProgress() {
    _totalPoints = 0;
    _completedGames = 0;
    _streakDays = 0;
    _currentLevel = 'Fácil';
    _lastPlayDate = null;
    _completedGamesHistory.clear();
    _totalStudyHours = 0.0;
    _studySessionStart = null;
    _isStudying = false;
    _weeklyStudyHours = {
      'Lun': 0.0,
      'Mar': 0.0,
      'Mié': 0.0,
      'Jue': 0.0,
      'Vie': 0.0,
      'Sáb': 0.0,
      'Dom': 0.0,
    };
    notifyListeners();
  }


  Future<void> loadProgress() async {
    resetProgress();
    notifyListeners();
  }
}