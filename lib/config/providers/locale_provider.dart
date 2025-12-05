import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  final List<Map<String, String>> supportedLanguages = [
    {
      'code': 'es',
      'name': 'Español',
      'nativeName': 'Español',
      'description': 'Idioma oficial de México'
    },
    {
      'code': 'tzo',
      'name': 'Tsotsil',
      'nativeName': 'Bats\'i k\'op',
      'description': 'Lengua maya de los Altos de Chiapas'
    },
    {
      'code': 'tze',
      'name': 'Tseltal',
      'nativeName': 'Kop o winik atel',
      'description': 'Lengua maya de los Altos de Chiapas'
    },
    {
      'code': 'ctu',
      'name': 'Ch\'ol',
      'nativeName': 'Lak ty\'añ',
      'description': 'Lengua maya del norte de Chiapas'
    },
    {
      'code': 'zos',
      'name': 'Zoque',
      'nativeName': 'O\'de püt',
      'description': 'Lengua mixe-zoque de Chiapas'
    },
    {
      'code': 'toj',
      'name': 'Tojol-ab\'al',
      'nativeName': 'Tojol-winik',
      'description': 'Lengua maya de la región fronteriza'
    },
    {
      'code': 'mam',
      'name': 'Mam',
      'nativeName': 'Qyool',
      'description': 'Lengua maya de la región Soconusco'
    },
    {
      'code': 'lac',
      'name': 'Lacandón',
      'nativeName': 'Hach t\'an',
      'description': 'Lengua maya de la selva lacandona'
    },
    {
      'code': 'en',
      'name': 'Inglés',
      'nativeName': 'English',
      'description': 'Idioma internacional'
    },
  ];

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');

    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);

    notifyListeners();
  }

  Future<void> clearLocale() async {
    _locale = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('language_code');
    notifyListeners();
  }

  String getLanguageName(String code) {
    return supportedLanguages
        .firstWhere((lang) => lang['code'] == code,
        orElse: () => supportedLanguages.first)['name']!;
  }

  String getNativeName(String code) {
    return supportedLanguages
        .firstWhere((lang) => lang['code'] == code,
        orElse: () => supportedLanguages.first)['nativeName']!;
  }
}