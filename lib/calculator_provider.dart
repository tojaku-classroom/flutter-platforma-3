import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculationTemplate {
  final double num1;
  final double num2;
  final String operation;

  const CalculationTemplate({
    required this.num1,
    required this.num2,
    required this.operation,
  });

  Map<String, dynamic> toJson() {
    return {'num1': num1, 'num2': num2, 'operation': operation};
  }

  factory CalculationTemplate.fromJson(Map<String, dynamic> json) {
    return CalculationTemplate(
      num1: (json['num1'] as num?)?.toDouble() ?? 0,
      num2: (json['num2'] as num?)?.toDouble() ?? 0,
      operation: json['operation'] as String? ?? 'Zbrajanje',
    );
  }

  String get displayLabel {
    String operatorSymbol;
    switch (operation) {
      case 'Zbrajanje':
        operatorSymbol = '+';
        break;

      case 'Oduzimanje':
        operatorSymbol = '-';
        break;

      case 'Množenje':
        operatorSymbol = '×';
        break;

      case 'Dijeljenje':
        operatorSymbol = '/';
        break;

      default:
        operatorSymbol = '+';
    }

    return '${num1.toStringAsFixed(2)} $operatorSymbol ${num2.toStringAsFixed(2)}';
  }
}

class CalculatorProvider extends ChangeNotifier {
  // Glavna lista za spremanje povijesti izračuna
  List<String> _history = [];
  List<CalculationTemplate> _templates = [];

  // Getter za pristup listi povijesti
  List<String> get history => _history;

  // Ključ za spremanje povijesti u spremištu (Shared Preferences)
  static const String _storageKey = 'calculation_history';
  static const String _templateStorageKey = 'calculation_templates';

  // Učitavanje povijesti iz spremišta npr. kada se pokrene aplikacija
  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _history = prefs.getStringList(_storageKey) ?? [];
    notifyListeners(); // Obavijesti sve koji slušaju (widgeti) da su se podaci promijenili
  }

  // Dodavanje novog izračuna u povijest
  Future<void> addCalculation(
    double num1,
    double num2,
    String operation,
  ) async {
    // Upis u povijest (radna memorija)

    double result;
    String operatorSymbol;

    switch (operation) {
      case 'Zbrajanje':
        result = num1 + num2;
        operatorSymbol = '+';
        break;
      case 'Oduzimanje':
        result = num1 - num2;
        operatorSymbol = '-';
        break;
      case 'Množenje':
        result = num1 * num2;
        operatorSymbol = '×';
        break;
      case 'Dijeljenje':
        result = num1 / num2;
        operatorSymbol = '÷';
        break;
      default:
        result = num1 + num2;
        operatorSymbol = '+';
    }

    final entry =
        '${num1.toStringAsFixed(2)} $operatorSymbol ${num2.toStringAsFixed(2)} = ${result.toStringAsFixed(2)}';
    _history.add(entry);

    // Upis na 'disk' (trajnu memoriju), tj. Shared Preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _history);

    notifyListeners(); // Obavijest svima o promjeni
  }

  Future<void> clearHistory() async {
    _history.clear(); // Brisanje povijesti u radnoj memoriji

    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_storageKey); // Brisanje povjesti u trajnoj memoriji

    notifyListeners(); // Obavijest svima
  }

  Future<void> deleteCalculation(int index) async {
    if (index >= 0 && index < _history.length) {
      _history.removeAt(index);

      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList(_storageKey, _history);

      notifyListeners();
    }
  }

  // ----------------------------------------------------------------------------------- //
  // ----------------------- Metode vezane uz predloške izračuna ----------------------- //
  // ----------------------------------------------------------------------------------- //

  Future<void> loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final rawTemplates = prefs.getStringList(_templateStorageKey) ?? [];

    _templates = rawTemplates.map((value) {
      // Uzimamo sirovi JSON zapis s diska (SharedPreferences) kao 'value'
      try {
        final json =
            jsonDecode(value)
                as Map<
                  String,
                  dynamic
                >; // Naš sirovi zapis je JSON string koji pretvaramo u JSON objekt
        return CalculationTemplate.fromJson(
          json,
        ); // Uzimamo JSON objekt i dajemo ga CalculationTemplate factory metodi da stvori predložak izračuna
      } catch (_) {
        // Ako se sirovi JSON string ne može dekodirati, kao backup stvaramo prazan predložak iračuna
        return const CalculationTemplate(
          num1: 0,
          num2: 0,
          operation: 'Zbrajanje',
        );
      }
    }).toList();

    notifyListeners();
  }

  Future<void> _saveTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    // U sljedećoj liniji, pretvaramo listu predložaka izračuna prvo u JSON objekte, nakon toga
    // JSON objekte 'enkodiramo' u JSON stringove, te ih onda spremamo kao stringove na disk
    // koristeći SharedPreferences
    final rawTemplates = _templates.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_templateStorageKey, rawTemplates);
  }

  Future<void> addTemplate(double num1, double num2, String operation) async {
    _templates.add(
      CalculationTemplate(num1: num1, num2: num2, operation: operation),
    );

    await _saveTemplates();
    notifyListeners();
  }

  Future<void> deleteTemplate(int index) async {
    if (index >= 0 && index < _templates.length) {
      _templates.removeAt(index);

      await _saveTemplates();
      notifyListeners();
    }
  }

  Future<void> clearTemplates() async {
    _templates.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_templateStorageKey);

    notifyListeners();
  }

  // Pomoćne 'stvari'
  bool get isEmpty => _history.isEmpty;
  int get count => _history.length;
  List<CalculationTemplate> get templates => _templates;
  bool get templatesIsEmpty => _templates.isEmpty;
  int get templatesCount => _templates.length;
}
