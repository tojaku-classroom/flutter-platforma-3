import 'package:flutter/material.dart';
import '../models/journal_entry.dart';

class ViewEntryScreen extends StatelessWidget {
  const ViewEntryScreen({super.key});

  String _formatDate(DateTime date) =>
      '${date.day}.${date.month}.${date.year}.'
      ' u ${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final entry = ModalRoute.of(context)!.settings.arguments as JournalEntry;

    return Scaffold(
      appBar: AppBar(title: const Text('Unos u dnevnik')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(entry.createdAt),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              entry.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(entry.body, style: const TextStyle(fontSize: 16, height: 1.6)),
          ],
        ),
      ),
    );
  }
}
