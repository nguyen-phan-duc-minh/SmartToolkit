import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    // Format with commas
    final formatter = NumberFormat('#,###', 'en_US');
    String formatted = formatter.format(int.parse(digitsOnly));

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class TipCalculatorScreen extends StatefulWidget {
  const TipCalculatorScreen({super.key});

  @override
  State<TipCalculatorScreen> createState() => _TipCalculatorScreenState();
}

class _TipCalculatorScreenState extends State<TipCalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Currency list
  static const List<Currency> currencies = [
    Currency(code: 'USD', symbol: '\$', name: 'US Dollar'),
    Currency(code: 'EUR', symbol: '€', name: 'Euro'),
    Currency(code: 'GBP', symbol: '£', name: 'British Pound'),
    Currency(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    Currency(code: 'VND', symbol: '₫', name: 'Vietnamese Dong'),
    Currency(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
    Currency(code: 'KRW', symbol: '₩', name: 'South Korean Won'),
    Currency(code: 'THB', symbol: '฿', name: 'Thai Baht'),
    Currency(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar'),
    Currency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
    Currency(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
    Currency(code: 'CHF', symbol: 'Fr', name: 'Swiss Franc'),
  ];
  
  // Tip Calculator state
  final TextEditingController _billController = TextEditingController();
  double _tipPercentage = 15.0;
  int _numberOfPeople = 1;
  Currency _selectedCurrency = currencies[0];

  double get _billAmount {
    final text = _billController.text.replaceAll(',', '');
    return double.tryParse(text) ?? 0.0;
  }
  double get _tipAmount => (_billAmount * _tipPercentage) / 100;
  double get _totalAmount => _billAmount + _tipAmount;
  double get _perPersonAmount => _totalAmount / _numberOfPeople;
  
  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '${_selectedCurrency.symbol}${formatter.format(amount)}';
  }
  
  // BMI Calculator state
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  double _bmi = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _calculateBMI() {
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;
    
    if (height > 0 && weight > 0) {
      setState(() {
        _bmi = weight / ((height / 100) * (height / 100));
      });
    }
  }

  String _getBMICategory() {
    if (_bmi < 18.5) return 'Underweight';
    if (_bmi < 25) return 'Normal';
    if (_bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor() {
    if (_bmi < 18.5) return Colors.blue;
    if (_bmi < 25) return Colors.green;
    if (_bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _billController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculators'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tip Calculator', icon: Icon(Icons.monetization_on)),
            Tab(text: 'BMI Calculator', icon: Icon(Icons.monitor_weight)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTipCalculatorTab(),
          _buildBMICalculatorTab(),
        ],
      ),
    );
  }

  Widget _buildTipCalculatorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Currency:'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButton<Currency>(
                            value: _selectedCurrency,
                            isExpanded: true,
                            items: currencies.map((currency) {
                              return DropdownMenuItem<Currency>(
                                value: currency,
                                child: Text('${currency.symbol} ${currency.code} - ${currency.name}'),
                              );
                            }).toList(),
                            onChanged: (Currency? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedCurrency = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _billController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CurrencyInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Bill Amount',
                        prefixText: '${_selectedCurrency.symbol} ',
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 20),
                    Text('Tip: ${_tipPercentage.toInt()}%'),
                    Slider(
                      value: _tipPercentage,
                      min: 0,
                      max: 50,
                      divisions: 50,
                      onChanged: (value) => setState(() => _tipPercentage = value),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text('Number of People:'),
                        const Spacer(),
                        IconButton(
                          onPressed: _numberOfPeople > 1 ? () => setState(() => _numberOfPeople--) : null,
                          icon: const Icon(Icons.remove),
                        ),
                        Text('$_numberOfPeople'),
                        IconButton(
                          onPressed: () => setState(() => _numberOfPeople++),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildResultRow('Bill Amount:', _formatCurrency(_billAmount)),
                    _buildResultRow('Tip Amount:', _formatCurrency(_tipAmount)),
                    _buildResultRow('Total Amount:', _formatCurrency(_totalAmount)),
                    const Divider(),
                    _buildResultRow('Per Person:', _formatCurrency(_perPersonAmount), isTotal: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildBMICalculatorTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                    ),
                    onChanged: (_) => _calculateBMI(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                    ),
                    onChanged: (_) => _calculateBMI(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_bmi > 0) ...[
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'BMI Result',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _bmi.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: _getBMIColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getBMICategory(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getBMIColor(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getBMIColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'BMI Categories',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          _buildBMIRange('< 18.5', 'Underweight', Colors.blue),
                          _buildBMIRange('18.5 - 24.9', 'Normal', Colors.green),
                          _buildBMIRange('25.0 - 29.9', 'Overweight', Colors.orange),
                          _buildBMIRange('≥ 30.0', 'Obese', Colors.red),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildBMIRange(String range, String category, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$range: ',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}