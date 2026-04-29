import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';

class JournalProvider extends ChangeNotifier {
  String? _username;
  List<JournalEntry> _entries = [];

  List<JournalEntry> get entries => _entries;

  String _storageKey(String username) => 'entries_$username';

  // Funkcija koja učitava upise dnevnika prema postavljenom korisničkom imenu
  // Poziva se automatski kada se promijeni AuthProvider (ProxyProvider)
  void setUser(String? username) {
    if (_username == username) return;
    _username = username;

    if (username != null) {
      _loadEntries(username);
    } else {
      _entries = [];
      notifyListeners();
    }
  }

  // Učitavanje upisa u dnevnik
  Future<void> _loadEntries(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey(username)) ?? [];

    _entries =
        raw
            .map(
              (e) =>
                  JournalEntry.fromJson(jsonDecode(e) as Map<String, dynamic>),
            )
            .toList()
          ..sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          ); // najnoviji prvi

    notifyListeners();
  }

  // Spremanje svih upisa na disk
  Future<void> _saveEntries() async {
    if (_username == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey(_username!),
      _entries.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  // Dodavanje jednog upisa i ažuriranje stanja
  Future<void> addEntry(String title, String body) async {
    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      body: body.trim(),
      createdAt: DateTime.now(),
    );

    _entries.insert(0, entry);
    await _saveEntries();

    notifyListeners();
  }

  // Brisanje jednog upisa i ažuriranje stanja
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _saveEntries();

    notifyListeners();
  }
}
