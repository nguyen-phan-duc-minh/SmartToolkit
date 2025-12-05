import 'package:flutter/material.dart';

class TipCalculatorScreen extends StatefulWidget {
  const TipCalculatorScreen({super.key});

  @override
  State<TipCalculatorScreen> createState() => _TipCalculatorScreenState();
}

class _TipCalculatorScreenState extends State<TipCalculatorScreen> {
  final TextEditingController _billController = TextEditingController();
  double _tipPercentage = 15.0;
  int _numberOfPeople = 1;

  double get _billAmount => double.tryParse(_billController.text) ?? 0.0;
  double get _tipAmount => (_billAmount * _tipPercentage) / 100;
  double get _totalAmount => _billAmount + _tipAmount;
  double get _perPersonAmount => _totalAmount / _numberOfPeople;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tip Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _billController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Bill Amount',
                        prefixText: '\$',
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
                    _buildResultRow('Bill Amount:', '\$${_billAmount.toStringAsFixed(2)}'),
                    _buildResultRow('Tip Amount:', '\$${_tipAmount.toStringAsFixed(2)}'),
                    _buildResultRow('Total Amount:', '\$${_totalAmount.toStringAsFixed(2)}'),
                    const Divider(),
                    _buildResultRow('Per Person:', '\$${_perPersonAmount.toStringAsFixed(2)}', isTotal: true),
                  ],
                ),
              ),
            ),
          ],
        ),
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
}