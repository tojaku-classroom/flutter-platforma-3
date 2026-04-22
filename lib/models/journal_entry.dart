class JournalEntry {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;

  const JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'createdAt': createdAt.toIso8601String(),
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
