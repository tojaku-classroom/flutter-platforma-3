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
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _number1 = TextEditingController();
  final TextEditingController _number2 = TextEditingController();

  bool dataOk = false;

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      // Test 1
      return 'Molimo unesite broj';
    }
    if (double.tryParse(value) == null) {
      // Test 2
      return 'Molimo unesite ispravan broj';
    }
    return null; // Svi testovi uspješni
  }

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moja prva Flutter aplikacija')),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _number1,
                keyboardType: TextInputType.number,
                validator: _validateNumber,
                decoration: const InputDecoration(
                  hintText: 'Unesite prvi broj',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _number2,
                keyboardType: TextInputType.number,
                validator: _validateNumber,
                decoration: const InputDecoration(
                  hintText: 'Unesite drugi broj',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SecondScreen(
                              number1: double.parse(_number1.text),
                              number2: double.parse(_number2.text),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Pošalji'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () {
                      _formKey.currentState?.reset();
                      showMessage(context, 'Obrazac je očišćen');
                    },
                    child: const Text('Očisti'),
                  ),
                ],
              ),
            ],
          ),
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
