import 'package:flutter/material.dart';
import 'package:flutter_platforma_3/providers/auth_provider.dart';
import 'package:flutter_platforma_3/providers/journal_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatDate(DateTime date) =>
      '${date.day}.${date.month}.${date.year}.';

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final username = context.watch<AuthProvider>().currentUser?.username ?? '';
    final entries = context.watch<JournalProvider>().entries;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dobrodošli, $username'),
        actions: [
          IconButton(
            tooltip: 'Odjava',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: entries.isEmpty ? const Placeholder() : const Placeholder(),
    );
  }
}
