import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  static const _usersKey = 'users';
  static const _loggedInKey = 'logged_in_user';

  List<User> _users = [];
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  String _hashPasssword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  // Učitava korisnike i obnavlja sesiju pri pokretanju aplikacije
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final rawUsers = prefs.getStringList(_usersKey) ?? [];
    _users = rawUsers
        .map((e) => User.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();

    final savedUsername = prefs.getString(_loggedInKey);
    if (savedUsername != null) {
      final matches = _users.where((u) => u.username == savedUsername);
      _currentUser = matches.isEmpty ? null : matches.first;
    }
  }

  // Registracija novog korisnika na aplikaciju
  Future<String?> register(String username, String password) async {
    if (username.trim().isEmpty) return 'Korisničko ime ne smije biti prazno';
    if (password.length < 4) return 'Lozinka mora imati najmanje 4 znaka';

    final exists = _users.any((u) => u.username == username.trim());
    if (exists) return 'Korisnik s ovim imenom već postoji';

    final user = User(
      username: username.trim(),
      passwordHash: _hashPasssword(password),
    );
    _users.add(user);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _usersKey,
      _users.map((u) => jsonEncode(u.toJson())).toList(),
    );

    _currentUser = user;
    await prefs.setString(_loggedInKey, user.username);

    notifyListeners();
    return null;
  }

  // Prijava postojećeg korisnika
  Future<String?> login(String username, String password) async {
    final match = _users.where(
      (u) =>
          u.username == username.trim() &&
          u.passwordHash == _hashPasssword(password),
    );
    if (match.isEmpty) return 'Pogrešno korisničko ime ili lozinka';

    _currentUser = match.first;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loggedInKey, _currentUser!.username);

    notifyListeners();
    return null;
  }

  // Odjava korisnika
  Future<void> logout() async {
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);

    notifyListeners();
  }
}
