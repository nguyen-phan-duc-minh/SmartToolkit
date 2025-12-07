import 'dart:async';
import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

enum FlashlightMode {
  off,
  on,
  slowBlink,
  fastBlink,
}

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({super.key});

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> {
  FlashlightMode _currentMode = FlashlightMode.off;
  Timer? _blinkTimer;
  bool _isBlinkOn = false;

  @override
  void dispose() {
    _stopBlink();
    TorchLight.disableTorch();
    super.dispose();
  }

  void _stopBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = null;
  }

  void _setMode(FlashlightMode mode) async {
    try {
      _stopBlink();

      switch (mode) {
        case FlashlightMode.off:
          await TorchLight.disableTorch();
          break;
        case FlashlightMode.on:
          await TorchLight.enableTorch();
          break;
        case FlashlightMode.slowBlink:
          _startBlink(const Duration(milliseconds: 300));
          break;
        case FlashlightMode.fastBlink:
          _startBlink(const Duration(milliseconds: 100));
          break;
      }

      setState(() {
        _currentMode = mode;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _startBlink(Duration interval) {
    _isBlinkOn = false;
    _blinkTimer = Timer.periodic(interval, (timer) async {
      try {
        if (_isBlinkOn) {
          await TorchLight.disableTorch();
        } else {
          await TorchLight.enableTorch();
        }
        _isBlinkOn = !_isBlinkOn;
      } catch (e) {
        timer.cancel();
      }
    });
  }

  IconData _getIcon() {
    switch (_currentMode) {
      case FlashlightMode.off:
        return Icons.flashlight_off;
      case FlashlightMode.on:
        return Icons.flashlight_on;
      case FlashlightMode.slowBlink:
      case FlashlightMode.fastBlink:
        return Icons.flash_auto;
    }
  }

  Color _getIconColor() {
    switch (_currentMode) {
      case FlashlightMode.off:
        return Colors.grey;
      case FlashlightMode.on:
        return Colors.yellow;
      case FlashlightMode.slowBlink:
        return Colors.orange;
      case FlashlightMode.fastBlink:
        return Colors.red;
    }
  }

  String _getModeName(FlashlightMode mode) {
    switch (mode) {
      case FlashlightMode.off:
        return 'Off';
      case FlashlightMode.on:
        return 'On';
      case FlashlightMode.slowBlink:
        return 'Slow Blink';
      case FlashlightMode.fastBlink:
        return 'Fast Blink';
    }
  }

  Widget _buildModeButton({
    required FlashlightMode mode,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _currentMode == mode;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: isSelected ? 8 : 2,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _setMode(mode),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: isSelected
                    ? LinearGradient(
                        colors: [color.withValues(alpha: 0.8), color],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.grey.shade200,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flashlight')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(),
              size: 100,
              color: _getIconColor(),
            ),
            const SizedBox(height: 20),
            Text(
              _getModeName(_currentMode),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildModeButton(
                    mode: FlashlightMode.on,
                    icon: Icons.flashlight_on,
                    label: 'On',
                    color: Colors.yellow.shade700,
                  ),
                  _buildModeButton(
                    mode: FlashlightMode.slowBlink,
                    icon: Icons.sync,
                    label: 'Slow',
                    color: Colors.orange,
                  ),
                  _buildModeButton(
                    mode: FlashlightMode.fastBlink,
                    icon: Icons.bolt,
                    label: 'Fast',
                    color: Colors.red,
                  ),
                  _buildModeButton(
                    mode: FlashlightMode.off,
                    icon: Icons.flashlight_off,
                    label: 'Off',
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}