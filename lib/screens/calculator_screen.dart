import 'package:flutter/material.dart';
import 'dart:math' as math;

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  bool _shouldResetDisplay = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = _display;
    _controller.addListener(() {
      if (_controller.text != _display) {
        setState(() {
          _display = _controller.text;
          _expression = _controller.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    if (!mounted) return;
    setState(() {
      if (_shouldResetDisplay || _display == '0' || _display == 'Error') {
        _display = number;
        _expression = number;
        _controller.text = number;
        _shouldResetDisplay = false;
      } else {
        int cursorPos = _controller.selection.baseOffset;
        if (cursorPos < 0 || cursorPos > _display.length) cursorPos = _display.length;
        _display = _display.substring(0, cursorPos) + number + _display.substring(cursorPos);
        _expression = _display;
        _controller.text = _display;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: cursorPos + number.length),
        );
      }
    });
  }

  void _onOperationPressed(String op) {
    if (!mounted) return;
    setState(() {
      if (_display == 'Error') {
        _display = '0';
        _expression = '';
        _controller.text = '0';
      }
      if (_shouldResetDisplay) {
        _shouldResetDisplay = false;
      }
      int cursorPos = _controller.selection.baseOffset;
      if (cursorPos < 0 || cursorPos > _display.length) cursorPos = _display.length;
      _display = _display.substring(0, cursorPos) + op + _display.substring(cursorPos);
      _expression = _display;
      _controller.text = _display;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPos + op.length),
      );
    });
  }

  void _onParenthesisPressed(String paren) {
    if (!mounted) return;
    setState(() {
      if (_display == 'Error') {
        _display = paren;
        _expression = paren;
        _controller.text = paren;
      } else if (_shouldResetDisplay || _display == '0') {
        _display = paren;
        _expression = paren;
        _controller.text = paren;
        _shouldResetDisplay = false;
      } else {
        int cursorPos = _controller.selection.baseOffset;
        if (cursorPos < 0 || cursorPos > _display.length) cursorPos = _display.length;
        _display = _display.substring(0, cursorPos) + paren + _display.substring(cursorPos);
        _expression = _display;
        _controller.text = _display;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: cursorPos + paren.length),
        );
      }
    });
  }

  void _calculate() {
    if (_expression.isEmpty || _expression == '0') return;
    
    try {
      String expr = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('−', '-');
      
      final result = _evaluateExpression(expr);
      
      setState(() {
        _display = _formatResult(result);
        _expression = _display;
        _controller.text = _display;
        _shouldResetDisplay = true;
      });
    } catch (e) {
      setState(() {
        _display = 'Error';
        _controller.text = 'Error';
        _shouldResetDisplay = true;
      });
    }
  }

  double _evaluateExpression(String expr) {
    expr = expr.trim();
    
    // Handle parentheses
    while (expr.contains('(')) {
      int lastOpen = expr.lastIndexOf('(');
      int firstClose = expr.indexOf(')', lastOpen);
      if (firstClose == -1) throw Exception('Mismatched parentheses');
      
      String subExpr = expr.substring(lastOpen + 1, firstClose);
      double subResult = _evaluateExpression(subExpr);
      expr = expr.substring(0, lastOpen) + subResult.toString() + expr.substring(firstClose + 1);
    }
    
    return _evaluateSimpleExpression(expr);
  }

  double _evaluateSimpleExpression(String expr) {
    List<String> terms = [];
    List<String> ops = [];
    String current = '';
    
    for (int i = 0; i < expr.length; i++) {
      if ((expr[i] == '+' || expr[i] == '-') && i > 0 && current.isNotEmpty && expr[i-1] != 'e' && expr[i-1] != 'E') {
        terms.add(current);
        ops.add(expr[i]);
        current = '';
      } else {
        current += expr[i];
      }
    }
    if (current.isNotEmpty) terms.add(current);
    
    List<double> values = [];
    for (String term in terms) {
      values.add(_evaluateTerm(term));
    }
    
    double result = values[0];
    for (int i = 0; i < ops.length; i++) {
      if (ops[i] == '+') {
        result += values[i + 1];
      } else {
        result -= values[i + 1];
      }
    }
    
    return result;
  }

  double _evaluateTerm(String term) {
    List<String> factors = [];
    List<String> ops = [];
    String current = '';
    
    for (int i = 0; i < term.length; i++) {
      if ((term[i] == '*' || term[i] == '/' || term[i] == '%') && current.isNotEmpty) {
        factors.add(current);
        ops.add(term[i]);
        current = '';
      } else {
        current += term[i];
      }
    }
    if (current.isNotEmpty) factors.add(current);
    
    double result = double.parse(factors[0]);
    for (int i = 0; i < ops.length; i++) {
      double nextValue = double.parse(factors[i + 1]);
      if (ops[i] == '*') {
        result *= nextValue;
      } else if (ops[i] == '/') {
        if (nextValue == 0) throw Exception('Division by zero');
        result /= nextValue;
      } else if (ops[i] == '%') {
        result %= nextValue;
      }
    }
    
    return result;
  }

  String _formatResult(double value) {
    if (value.isInfinite || value.isNaN) return 'Error';
    if (value == value.roundToDouble() && value.abs() < 1e10) {
      return value.round().toString();
    }
    return value.toStringAsFixed(8).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _onEqualsPressed() {
    _calculate();
  }

  void _onClearPressed() {
    setState(() {
      _display = '0';
      _expression = '';
      _controller.text = '0';
      _shouldResetDisplay = false;
    });
  }

  void _onDeletePressed() {
    if (!mounted) return;
    setState(() {
      int cursorPos = _controller.selection.baseOffset;
      if (cursorPos < 0 || cursorPos > _display.length) cursorPos = _display.length;
      
      if (_display.length > 1 && _display != '0' && _display != 'Error' && cursorPos > 0) {
        _display = _display.substring(0, cursorPos - 1) + _display.substring(cursorPos);
        _expression = _display;
        _controller.text = _display;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: cursorPos - 1),
        );
      } else {
        _display = '0';
        _expression = '';
        _controller.text = '0';
      }
    });
  }

  void _onDecimalPressed() {
    setState(() {
      if (_display == 'Error') {
        _display = '0.';
        _expression = '0.';
        _controller.text = '0.';
        _shouldResetDisplay = false;
      } else if (_shouldResetDisplay) {
        _display = '0.';
        _expression = '0.';
        _controller.text = '0.';
        _shouldResetDisplay = false;
      } else {
        int cursorPos = _controller.selection.baseOffset;
        if (cursorPos < 0 || cursorPos > _display.length) cursorPos = _display.length;
        String lastNumber = _display.split(RegExp(r'[+\-×÷()]')).last;
        if (!lastNumber.contains('.')) {
          _display = '${_display.substring(0, cursorPos)}.${_display.substring(cursorPos)}';
          _expression = _display;
          _controller.text = _display;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: cursorPos + 1),
          );
        }
      }
    });
  }

  void _onSqrtPressed() {
    if (_expression.isEmpty || _expression == '0') return;
    
    try {
      _calculate();
      double value = double.parse(_display);
      if (value >= 0) {
        setState(() {
          _display = _formatResult(math.sqrt(value));
          _expression = _display;
          _controller.text = _display;
          _shouldResetDisplay = true;
        });
      } else {
        setState(() {
          _display = 'Error';
          _controller.text = 'Error';
          _shouldResetDisplay = true;
        });
      }
    } catch (e) {
      setState(() {
        _display = 'Error';
        _controller.text = 'Error';
        _shouldResetDisplay = true;
      });
    }
  }

  void _onSignPressed() {
    setState(() {
      if (_display != '0' && _display != 'Error') {
        if (_display.startsWith('-')) {
          _display = _display.substring(1);
          _expression = _display;
          _controller.text = _display;
        } else {
          _display = '-$_display';
          _expression = '-$_expression';
          _controller.text = _display;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: colorScheme.surfaceContainerHighest,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                readOnly: false,
                showCursor: true,
                cursorColor: colorScheme.primary,
                cursorWidth: 3,
                maxLines: 1,
                scrollController: ScrollController(),
              ),
            ),
            
            // Buttons
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Row 1: C, DEL, √, ÷
                    _buildButtonRow([
                      _buildButton('C', onPressed: _onClearPressed, 
                        color: colorScheme.errorContainer, 
                        textColor: colorScheme.onErrorContainer),
                      _buildButton('DEL', onPressed: _onDeletePressed, 
                        color: colorScheme.secondaryContainer),
                      _buildButton('√', onPressed: _onSqrtPressed, 
                        color: colorScheme.tertiaryContainer),
                      _buildButton('÷', onPressed: () => _onOperationPressed('÷'), 
                        color: colorScheme.primaryContainer),
                    ]),
                    
                    // Row 2: 7, 8, 9, ×
                    _buildButtonRow([
                      _buildButton('7', onPressed: () => _onNumberPressed('7')),
                      _buildButton('8', onPressed: () => _onNumberPressed('8')),
                      _buildButton('9', onPressed: () => _onNumberPressed('9')),
                      _buildButton('×', onPressed: () => _onOperationPressed('×'), 
                        color: colorScheme.primaryContainer),
                    ]),
                    
                    // Row 3: 4, 5, 6, −
                    _buildButtonRow([
                      _buildButton('4', onPressed: () => _onNumberPressed('4')),
                      _buildButton('5', onPressed: () => _onNumberPressed('5')),
                      _buildButton('6', onPressed: () => _onNumberPressed('6')),
                      _buildButton('−', onPressed: () => _onOperationPressed('-'), 
                        color: colorScheme.primaryContainer),
                    ]),
                    
                    // Row 4: 1, 2, 3, +
                    _buildButtonRow([
                      _buildButton('1', onPressed: () => _onNumberPressed('1')),
                      _buildButton('2', onPressed: () => _onNumberPressed('2')),
                      _buildButton('3', onPressed: () => _onNumberPressed('3')),
                      _buildButton('+', onPressed: () => _onOperationPressed('+'), 
                        color: colorScheme.primaryContainer),
                    ]),
                    
                    // Row 5: ( ) 0 .
                    _buildButtonRow([
                      _buildButton('(', onPressed: () => _onParenthesisPressed('(')),
                      _buildButton(')', onPressed: () => _onParenthesisPressed(')')),
                      _buildButton('0', onPressed: () => _onNumberPressed('0')),
                      _buildButton('.', onPressed: _onDecimalPressed),
                    ]),
                    
                    // Row 6: +/− =
                    _buildButtonRow([
                      _buildButton('+/−', onPressed: _onSignPressed),
                      _buildButton('=', onPressed: _onEqualsPressed, 
                        color: colorScheme.primary,
                        textColor: colorScheme.onPrimary,
                        flex: 3),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<Widget> buttons) {
    return SizedBox(
      height: 70,
      child: Row(
        children: buttons,
      ),
    );
  }

  Widget _buildButton(
    String text, {
    required VoidCallback onPressed,
    Color? color,
    Color? textColor,
    int flex = 1,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? colorScheme.surfaceContainerLow,
            foregroundColor: textColor ?? colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
