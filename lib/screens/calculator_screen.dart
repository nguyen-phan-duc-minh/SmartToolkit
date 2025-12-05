import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';

  String _operation = '';
  double _operand = 0;
  bool _waitingForOperand = false;

  void _inputDigit(String digit) {
    setState(() {
      if (_waitingForOperand) {
        _display = digit;
        _waitingForOperand = false;
      } else {
        _display = _display == '0' ? digit : _display + digit;
      }
    });
  }

  void _inputDecimal() {
    setState(() {
      if (_waitingForOperand) {
        _display = '0.';
        _waitingForOperand = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _expression = '';
      _operation = '';
      _operand = 0;
      _waitingForOperand = false;
    });
  }

  void _performOperation(String nextOperation) {
    double inputValue = double.tryParse(_display) ?? 0;

    setState(() {
      if (_operation.isNotEmpty && !_waitingForOperand) {
        double currentResult = _calculate(_operand, inputValue, _operation);
        _display = _formatNumber(currentResult);
        _operand = currentResult;
      } else {
        _operand = inputValue;
      }

      _waitingForOperand = true;
      _operation = nextOperation;
      _expression = '${_formatNumber(_operand)} $_operation';
    });
  }

  double _calculate(double operand1, double operand2, String operation) {
    switch (operation) {
      case '+':
        return operand1 + operand2;
      case '-':
        return operand1 - operand2;
      case '×':
        return operand1 * operand2;
      case '÷':
        return operand2 != 0 ? operand1 / operand2 : 0;
      case '%':
        return operand1 % operand2;
      default:
        return operand2;
    }
  }

  void _calculateResult() {
    double inputValue = double.tryParse(_display) ?? 0;

    setState(() {
      if (_operation.isNotEmpty) {
        double currentResult = _calculate(_operand, inputValue, _operation);
        _display = _formatNumber(currentResult);
        _expression =
            '${_formatNumber(_operand)} $_operation ${_formatNumber(inputValue)} =';
        _operation = '';
        _operand = 0;
        _waitingForOperand = true;
      }
    });
  }

  String _formatNumber(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    } else {
      return number.toString();
    }
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    double flex = 1,
  }) {
    return Expanded(
      flex: flex.toInt(),
      child: Container(
        height: 70,
        margin: const EdgeInsets.all(2),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                backgroundColor ?? Theme.of(context).colorScheme.surface,
            foregroundColor:
                textColor ?? Theme.of(context).colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive layout for different screen sizes
            final isLargeScreen = constraints.maxWidth > 600;
            final padding = isLargeScreen ? 32.0 : 16.0;

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              _expression,
                              style: TextStyle(
                                fontSize: 18,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              _display,
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildButton(
                                text: 'C',
                                onPressed: _clear,
                                backgroundColor: colorScheme.errorContainer,
                                textColor: colorScheme.onErrorContainer,
                              ),
                              _buildButton(
                                text: '±',
                                onPressed: () {
                                  setState(() {
                                    if (_display != '0') {
                                      if (_display.startsWith('-')) {
                                        _display = _display.substring(1);
                                      } else {
                                        _display = '-$_display';
                                      }
                                    }
                                  });
                                },
                                backgroundColor: colorScheme.secondaryContainer,
                                textColor: colorScheme.onSecondaryContainer,
                              ),
                              _buildButton(
                                text: '%',
                                onPressed: () => _performOperation('%'),
                                backgroundColor: colorScheme.secondaryContainer,
                                textColor: colorScheme.onSecondaryContainer,
                              ),
                              _buildButton(
                                text: '÷',
                                onPressed: () => _performOperation('÷'),
                                backgroundColor: colorScheme.primaryContainer,
                                textColor: colorScheme.onPrimaryContainer,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildButton(
                                text: '7',
                                onPressed: () => _inputDigit('7'),
                              ),
                              _buildButton(
                                text: '8',
                                onPressed: () => _inputDigit('8'),
                              ),
                              _buildButton(
                                text: '9',
                                onPressed: () => _inputDigit('9'),
                              ),
                              _buildButton(
                                text: '×',
                                onPressed: () => _performOperation('×'),
                                backgroundColor: colorScheme.primaryContainer,
                                textColor: colorScheme.onPrimaryContainer,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildButton(
                                text: '4',
                                onPressed: () => _inputDigit('4'),
                              ),
                              _buildButton(
                                text: '5',
                                onPressed: () => _inputDigit('5'),
                              ),
                              _buildButton(
                                text: '6',
                                onPressed: () => _inputDigit('6'),
                              ),
                              _buildButton(
                                text: '-',
                                onPressed: () => _performOperation('-'),
                                backgroundColor: colorScheme.primaryContainer,
                                textColor: colorScheme.onPrimaryContainer,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildButton(
                                text: '1',
                                onPressed: () => _inputDigit('1'),
                              ),
                              _buildButton(
                                text: '2',
                                onPressed: () => _inputDigit('2'),
                              ),
                              _buildButton(
                                text: '3',
                                onPressed: () => _inputDigit('3'),
                              ),
                              _buildButton(
                                text: '+',
                                onPressed: () => _performOperation('+'),
                                backgroundColor: colorScheme.primaryContainer,
                                textColor: colorScheme.onPrimaryContainer,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildButton(
                                text: '0',
                                onPressed: () => _inputDigit('0'),
                                flex: 2,
                              ),
                              _buildButton(text: '.', onPressed: _inputDecimal),
                              _buildButton(
                                text: '=',
                                onPressed: _calculateResult,
                                backgroundColor: colorScheme.primary,
                                textColor: colorScheme.onPrimary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
