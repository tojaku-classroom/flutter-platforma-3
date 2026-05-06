import 'package:flutter/material.dart';
import 'package:flutter_platforma_3/providers/auth_provider.dart';
import 'package:flutter_platforma_3/providers/journal_provider.dart';
import 'package:flutter_platforma_3/screens/home_screen.dart';
import 'package:flutter_platforma_3/screens/login_screen.dart';
import 'package:flutter_platforma_3/screens/new_entry_screen.dart';
import 'package:flutter_platforma_3/screens/register_screen.dart';
import 'package:flutter_platforma_3/screens/view_entry_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Potrebno zbog upotrebe asinkronih operacija

  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;

  const MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProxyProvider<AuthProvider, JournalProvider>(
          create: (_) => JournalProvider(),
          update: (_, auth, journal) {
            journal!.setUser(auth.currentUser?.username);
            return journal;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Osobni dnevnik',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        initialRoute: authProvider.isLoggedIn ? '/home' : '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
          '/new-entry': (_) => const NewEntryScreen(),
          '/entry': (_) => const ViewEntryScreen(),
        },
      ),
    );
  }
}
