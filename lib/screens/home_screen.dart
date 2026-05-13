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
      body: entries.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nema zapisanih unosa',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      entry.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(_formatDate(entry.createdAt)),
                    trailing: IconButton(
                      onPressed: () =>
                          context.read<JournalProvider>().deleteEntry(entry.id),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/entry',
                      arguments: entry,
                    ),
                  ),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemCount: entries.length,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/new-entry'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
