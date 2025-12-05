import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class SoundMeterScreen extends StatefulWidget {
  const SoundMeterScreen({super.key});

  @override
  State<SoundMeterScreen> createState() => _SoundMeterScreenState();
}

class _SoundMeterScreenState extends State<SoundMeterScreen> {
  bool _isListening = false;
  double _currentDB = 0.0;
  double _maxDB = 0.0;


  void _startListening() async {
    try {
      // Simulate sound meter functionality
      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!_isListening) {
          timer.cancel();
          return;
        }
        
        // Simulate random sound levels
        final random = math.Random();
        double simulatedDB = 30 + random.nextDouble() * 50;
        
        setState(() {
          _currentDB = simulatedDB;
          if (_currentDB > _maxDB) {
            _maxDB = _currentDB;
          }
        });
      });
      
      setState(() {
        _isListening = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
  }

  void _resetMax() {
    setState(() {
      _maxDB = _currentDB;
    });
  }

  Color _getDecibelColor(double db) {
    if (db < 30) return Colors.green;
    if (db < 60) return Colors.yellow;
    if (db < 80) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sound Meter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isListening ? Icons.mic : Icons.mic_off,
              size: 100,
              color: _isListening ? Colors.red : Colors.grey,
            ),
            const SizedBox(height: 30),
            Text(
              '${_currentDB.toStringAsFixed(1)} dB',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _getDecibelColor(_currentDB),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Max: ${_maxDB.toStringAsFixed(1)} dB',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 30),
            LinearProgressIndicator(
              value: (_currentDB / 120).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getDecibelColor(_currentDB),
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isListening ? _stopListening : _startListening,
                  child: Text(_isListening ? 'Stop' : 'Start'),
                ),
                ElevatedButton(
                  onPressed: _resetMax,
                  child: const Text('Reset Max'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}