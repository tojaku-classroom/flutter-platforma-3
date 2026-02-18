import 'package:flutter/material.dart';

List<String> calculationHistory = [];

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
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                    label: const Text('Povijest izračuna'),
                    icon: const Icon(Icons.history),
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

class SecondScreen extends StatefulWidget {
  final double number1;
  final double number2;

  const SecondScreen({super.key, required this.number1, required this.number2});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  String _selectedOperation = 'Zbrajanje';

  double _calculateResult() {
    final entry = '${widget.number1}, ${widget.number2}, $_selectedOperation';
    calculationHistory.add(entry);

    switch (_selectedOperation) {
      case 'Zbrajanje':
        return widget.number1 + widget.number2;
      case 'Oduzimanje':
        return widget.number1 - widget.number2;
      case 'Množenje':
        return widget.number1 * widget.number2;
      case 'Dijeljenje':
        return widget.number2 != 0 ? widget.number1 / widget.number2 : 0;
      default:
        return widget.number1 + widget.number2;
    }
  }

  Widget _buildResultItem(String label, double value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        const SizedBox(height: 8),
        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Druga Stranica')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Rezultat', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildResultItem('Broj 1', widget.number1),
                const SizedBox(width: 48),
                _buildResultItem('Broj 2', widget.number2),
              ],
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedOperation,
                items: const [
                  DropdownMenuItem(value: 'Zbrajanje', child: Text('Zbroj')),
                  DropdownMenuItem(value: 'Oduzimanje', child: Text('Razlika')),
                  DropdownMenuItem(value: 'Množenje', child: Text('Umnožak')),
                  DropdownMenuItem(
                    value: 'Dijeljenje',
                    child: Text('Količnik'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedOperation = value ?? 'Zbrajanje';
                  });
                },
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildResultItem(_selectedOperation, _calculateResult()),
            ),
            const SizedBox(height: 32),
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

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Povijest izračuna')),
      body: calculationHistory.isEmpty
          ? const Center(
              child: Text(
                'Trenutno nema izračuna u povijest',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: calculationHistory.length,
              itemBuilder: (context, index) {
                final reversedIndex = calculationHistory.length - 1 - index;
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${reversedIndex + 1}')),
                    title: Text(calculationHistory[reversedIndex]),
                    trailing: const Icon(Icons.calculate),
                  ),
                );
              },
            ),
      floatingActionButton: calculationHistory.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                calculationHistory.clear();
                (context as Element).markNeedsBuild();
              },
              child: const Icon(Icons.delete),
            )
          : null,
    );
  }
}
