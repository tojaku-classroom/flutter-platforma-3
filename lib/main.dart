import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calculator_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Potrebno zbog upotrebe asinkronih operacija
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final provider = CalculatorProvider();
        provider.loadHistory();
        provider.loadTemplates(); // Paralelno učitavamo i predloške izračuna
        return provider;
      },
      child: MaterialApp(
        title: 'Moja prva Flutter aplikacija',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomeScreen(),
      ),
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

  Future<void> _openTemplates() async {
    final template = await Navigator.push<CalculationTemplate>(
      context,
      MaterialPageRoute(builder: (context) => const TemplatesScreen()),
    );

    if (template == null) return;

    _number1.text = template.num1.toString();
    _number2.text = template.num2.toString();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecondScreen(
          number1: template.num1,
          number2: template.num2,
          initialOperation: template.operation,
        ),
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
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: _openTemplates,
                    label: const Text('Predlošci'),
                    icon: const Icon(Icons.bookmark_outline),
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
  final String initialOperation;

  const SecondScreen({
    super.key,
    required this.number1,
    required this.number2,
    this.initialOperation = 'Zbrajanje',
  });

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  late String _selectedOperation = 'Zbrajanje';

  @override
  void initState() {
    super.initState();
    _selectedOperation = widget.initialOperation;
  }

  double _calculateResult() {
    // Dohvaćanje našeg providera bez pretplate na promjene
    final provider = Provider.of<CalculatorProvider>(context, listen: false);
    // Dodavanje novog izračuna u povijest
    provider.addCalculation(widget.number1, widget.number2, _selectedOperation);

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
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final provider = Provider.of<CalculatorProvider>(
                  context,
                  listen: false,
                );
                await provider.addTemplate(
                  widget.number1,
                  widget.number2,
                  _selectedOperation,
                );

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Predložak je spremljen')),
                );
              },
              label: const Text('Spremi kao predložak'),
              icon: const Icon(Icons.bookmark_add_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  void _showItemDeleteDialog(
    BuildContext context,
    CalculatorProvider provider,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Brisanje izračuna'),
          content: const Text(
            'Jeste li sigurni da želite obrisat ovaj izračun?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Odustani'),
            ),
            TextButton(
              onPressed: () {
                provider.deleteCalculation(index);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Izračun je obrisan'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Obriši'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Povijest izračuna')),
      body: Consumer<CalculatorProvider>(
        builder: (context, value, child) {
          if (value.isEmpty) {
            return const Center(
              child: Text(
                'Trenutno nema izračuna u povijesti',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: value.count,
            itemBuilder: (context, index) {
              final reversedIndex = value.count - 1 - index;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${reversedIndex + 1}')),
                  title: Text(
                    value.history[reversedIndex],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      _showItemDeleteDialog(context, value, reversedIndex);
                    },
                    icon: const Icon(Icons.delete_outlined, color: Colors.red),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<CalculatorProvider>(
        builder: (context, value, child) {
          if (value.isEmpty) return const SizedBox.shrink();

          return FloatingActionButton(
            onPressed: () {
              value.clearHistory();
            },
            child: const Icon(Icons.delete),
          );
        },
      ),
    );
  }
}

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Predlošci')),
      body: Consumer<CalculatorProvider>(
        builder: (context, value, child) {
          if (value.templatesIsEmpty) {
            return const Center(
              child: Text(
                'Trenutno nema spremljenih predložaka',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: value.templatesCount,
            itemBuilder: (context, index) {
              final reversedIndex = value.templatesCount - 1 - index;
              final template = value.templates[reversedIndex];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.bookmark_outline),
                  title: Text(template.displayLabel),
                  subtitle: Text('Operacija: ${template.operation}'),
                  onTap: () {
                    Navigator.pop(context, template);
                  },
                  trailing: IconButton(
                    onPressed: () {
                      value.deleteTemplate(reversedIndex);
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<CalculatorProvider>(
        builder: (context, value, child) {
          if (value.templatesIsEmpty) return const SizedBox.shrink();

          return FloatingActionButton(
            onPressed: () {
              value.clearTemplates();
            },
            child: const Icon(Icons.delete_sweep_outlined),
          );
        },
      ),
    );
  }
}
