import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorProvider extends ChangeNotifier {
  // Glavna lista za spremanje povijesti izračuna
  List<String> _history = [];

  // Getter za pristup listi povijesti
  List<String> get history => _history;

  // Ključ za spremanje povijesti u spremištu (Shared Preferences)
  static const String _storageKey = 'calculation_history';

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
    final entry = '$num1, $num2, $operation';
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

  // Pomoćne "stvari"
  bool get isEmpty => _history.isEmpty;
  int get count => _history.length;
}
