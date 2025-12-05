import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  String _generatedPassword = '';
  int _length = 12;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = false;

  final String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  final String _numbers = '0123456789';
  final String _symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    String characters = '';
    
    if (_includeUppercase) characters += _uppercase;
    if (_includeLowercase) characters += _lowercase;
    if (_includeNumbers) characters += _numbers;
    if (_includeSymbols) characters += _symbols;

    if (characters.isEmpty) {
      setState(() {
        _generatedPassword = '';
      });
      return;
    }

    final random = math.Random.secure();
    String password = '';
    
    for (int i = 0; i < _length; i++) {
      password += characters[random.nextInt(characters.length)];
    }

    setState(() {
      _generatedPassword = password;
    });
  }

  void _copyToClipboard() {
    if (_generatedPassword.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _generatedPassword));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password copied to clipboard!')),
      );
    }
  }

  Color _getPasswordStrengthColor() {
    if (_length < 8) return Colors.red;
    if (_length < 12) return Colors.orange;
    if (_length < 16) return Colors.yellow;
    return Colors.green;
  }

  String _getPasswordStrengthText() {
    if (_length < 8) return 'Weak';
    if (_length < 12) return 'Medium';
    if (_length < 16) return 'Strong';
    return 'Very Strong';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Generator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _generatedPassword.isEmpty ? 'Generate a password' : _generatedPassword,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _copyToClipboard,
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPasswordStrengthColor(),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _getPasswordStrengthText(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _generatePassword,
                          child: const Text('Generate New'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Password Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('Length: $_length'),
                        const Spacer(),
                        Text('$_length'),
                      ],
                    ),
                    Slider(
                      value: _length.toDouble(),
                      min: 4,
                      max: 50,
                      divisions: 46,
                      onChanged: (value) {
                        setState(() {
                          _length = value.toInt();
                        });
                        _generatePassword();
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Uppercase (A-Z)'),
                      value: _includeUppercase,
                      onChanged: (value) {
                        setState(() {
                          _includeUppercase = value;
                        });
                        _generatePassword();
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Lowercase (a-z)'),
                      value: _includeLowercase,
                      onChanged: (value) {
                        setState(() {
                          _includeLowercase = value;
                        });
                        _generatePassword();
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Numbers (0-9)'),
                      value: _includeNumbers,
                      onChanged: (value) {
                        setState(() {
                          _includeNumbers = value;
                        });
                        _generatePassword();
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Symbols (!@#\$%^&*)'),
                      value: _includeSymbols,
                      onChanged: (value) {
                        setState(() {
                          _includeSymbols = value;
                        });
                        _generatePassword();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}