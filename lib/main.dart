import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moja prva Flutter aplikacija',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _number1 = TextEditingController();
  final TextEditingController _number2 = TextEditingController();
  bool dataOk = false;

  void showMessage(BuildContext context) {
    String message = '';
    if (_number1.text.isEmpty || _number2.text.isEmpty) {
      message = 'Molimo unesite oba broja';
    } else if (double.tryParse(_number1.text) == null ||
        double.tryParse(_number2.text) == null) {
      message = 'Molimo unesite valjane brojeve';
    } else {
      dataOk = true;
      message = 'Brojevi su ispravni';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moja prva Flutter aplikacija')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _number1,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Unesite prvi broj',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _number2,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Unesite drugi broj',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showMessage(context),
              child: const Text('Provjeri podatke'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (!dataOk) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Provjerite podatke'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.fixed,
                    ),
                  );
                  return;
                }
                dataOk = false;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SecondScreen(
                      number1: double.parse(_number1.text),
                      number2: double.parse(_number2.text),
                    ),
                  ),
                );
              },
              child: const Text('Idi na drugu stranicu'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  final double number1;
  final double number2;

  const SecondScreen({super.key, required this.number1, required this.number2});

  @override
  Widget build(BuildContext context) {
    double sum = number1 + number2;

    return Scaffold(
      appBar: AppBar(title: const Text('Druga Stranica')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Rezultat', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            Text(
              '$sum',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Nazad'),
            ),
          ],
        ),
      ),
    );
  }
}
