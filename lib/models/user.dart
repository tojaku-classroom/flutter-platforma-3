class User {
  final String username;
  final String passwordHash;

  const User({required this.username, required this.passwordHash});

  // Objekt pretvaramo u JSON zapis (serijalizacija)
  Map<String, dynamic> toJson() => {
    'username': username,
    'passwordHash': passwordHash,
  };

  // JSON zapis s diska (SharedPreferences) pretvaramo nazad u objekt
  factory User.fromJson(Map<String, dynamic> json) => User(
    username: json['username'] as String,
    passwordHash: json['passwordHash'] as String,
  );
}
