import 'package:flutter/material.dart';

class ToolItem {
  final String title;
  final IconData icon;
  final String route;
  final String description;

  const ToolItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.description,
  });
}

class ToolsData {
  static const List<ToolItem> tools = [
    ToolItem(
      title: 'Calculator',
      icon: Icons.calculate,
      route: '/calculator',
      description: 'Basic calculator for mathematical operations',
    ),
    ToolItem(
      title: 'Notes',
      icon: Icons.note_add,
      route: '/notes',
      description: 'Create and manage your notes',
    ),
    ToolItem(
      title: 'Password Generator',
      icon: Icons.security,
      route: '/password-generator',
      description: 'Generate secure passwords',
    ),
    ToolItem(
      title: 'QR Generator',
      icon: Icons.qr_code,
      route: '/qr-generator',
      description: 'Generate QR codes from text',
    ),
    ToolItem(
      title: 'Tip Calculator',
      icon: Icons.monetization_on,
      route: '/tip-calculator',
      description: 'Calculate tips and split bills',
    ),
    ToolItem(
      title: 'Unit Converter',
      icon: Icons.straighten,
      route: '/unit-converter',
      description: 'Convert between different units',
    ),
    ToolItem(
      title: 'Age Calculator',
      icon: Icons.cake,
      route: '/age-calculator',
      description: 'Calculate age and days until birthday',
    ),
    ToolItem(
      title: 'BMI Calculator',
      icon: Icons.monitor_weight,
      route: '/bmi-calculator',
      description: 'Calculate your Body Mass Index',
    ),
    ToolItem(
      title: 'Stopwatch',
      icon: Icons.timer,
      route: '/stopwatch',
      description: 'Time your activities',
    ),
    ToolItem(
      title: 'Todo List',
      icon: Icons.checklist,
      route: '/todo-list',
      description: 'Manage your tasks and todos',
    ),
    ToolItem(
      title: 'Flashlight',
      icon: Icons.flashlight_on,
      route: '/flashlight',
      description: 'Turn your device into a flashlight',
    ),
    ToolItem(
      title: 'Countdown Timer',
      icon: Icons.hourglass_bottom,
      route: '/countdown-timer',
      description: 'Set countdown timers',
    ),
    ToolItem(
      title: 'QR Scanner',
      icon: Icons.qr_code_scanner,
      route: '/qr-scanner',
      description: 'Scan QR codes and barcodes',
    ),
    ToolItem(
      title: 'Image to Text',
      icon: Icons.image_search,
      route: '/image-to-text',
      description: 'Extract text from images',
    ),
    ToolItem(
      title: 'Sound Meter',
      icon: Icons.mic,
      route: '/sound-meter',
      description: 'Measure sound levels',
    ),
  ];
}