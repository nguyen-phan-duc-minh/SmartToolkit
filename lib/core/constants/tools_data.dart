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
      title: 'Translate Tools',
      icon: Icons.image_search,
      route: '/image-to-text',
      description: 'Image to text and voice translator',
    ),
    ToolItem(
      title: 'Voice to Text',
      icon: Icons.mic,
      route: '/voice-to-text',
      description: 'Convert speech to text with language selection',
    ),
    ToolItem(
      title: 'QR Tools',
      icon: Icons.qr_code,
      route: '/qr-generator',
      description: 'Generate and scan QR codes',
    ),
    ToolItem(
      title: 'PDF Tools',
      icon: Icons.picture_as_pdf,
      route: '/pdf-tools',
      description: 'Scan documents, convert PDFs and images',
    ),
    ToolItem(
      title: 'Notes & Todos',
      icon: Icons.note_add,
      route: '/notes',
      description: 'Create and manage your notes and tasks',
    ),
    ToolItem(
      title: 'Unit Converter',
      icon: Icons.straighten,
      route: '/unit-converter',
      description: 'Convert between different units',
    ),
    ToolItem(
      title: 'Timer & Stopwatch',
      icon: Icons.timer,
      route: '/countdown-timer',
      description: 'Set countdown timers and track time',
    ),
    ToolItem(
      title: 'Calculator',
      icon: Icons.calculate,
      route: '/calculator',
      description: 'Basic calculator for mathematical operations',
    ),
    ToolItem(
      title: 'Tip & BMI Calculators',
      icon: Icons.monetization_on,
      route: '/tip-calculator',
      description: 'Tip calculator and BMI calculator',
    ),
    ToolItem(
      title: 'Flashlight',
      icon: Icons.flashlight_on,
      route: '/flashlight',
      description: 'Turn your device into a flashlight',
    ),
  ];
}