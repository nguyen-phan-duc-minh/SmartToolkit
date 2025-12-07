import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarttoolkit/core/constants/app_constants.dart';
import 'package:smarttoolkit/core/constants/tools_data.dart';
import 'package:smarttoolkit/core/services/theme_provider.dart';
import 'package:smarttoolkit/screens/calculator_screen.dart';
import 'package:smarttoolkit/screens/notes_screen.dart';
import 'package:smarttoolkit/screens/qr_generator_screen.dart';
import 'package:smarttoolkit/screens/tip_calculator_screen.dart';
import 'package:smarttoolkit/screens/unit_converter_screen.dart';
import 'package:smarttoolkit/screens/flashlight_screen.dart';
import 'package:smarttoolkit/screens/countdown_timer_screen.dart';
import 'package:smarttoolkit/screens/image_to_text_screen.dart';
import 'package:smarttoolkit/screens/pdf_tools_screen.dart';
import 'package:smarttoolkit/screens/voice_to_text_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _navigateToTool(String route) {
    Widget screen;
    switch (route) {
      case '/calculator':
        screen = const CalculatorScreen();
        break;
      case '/notes':
        screen = const NotesScreen();
        break;
      case '/qr-generator':
        screen = const QrGeneratorScreen();
        break;
      case '/tip-calculator':
        screen = const TipCalculatorScreen();
        break;
      case '/unit-converter':
        screen = const UnitConverterScreen();
        break;
      case '/flashlight':
        screen = const FlashlightScreen();
        break;
      case '/countdown-timer':
        screen = const CountdownTimerScreen();
        break;
      case '/image-to-text':
        screen = const ImageToTextScreen();
        break;
      case '/voice-to-text':
        screen = const VoiceToTextScreen();
        break;
      case '/pdf-tools':
        screen = const PdfToolsScreen();
        break;
      default:
        return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive grid based on screen width
          int crossAxisCount = 2;
          if (constraints.maxWidth > 800) {
            crossAxisCount = 4; // Large tablets/desktop
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 3; // Small tablets
          }
          
          return GridView.builder(
            padding: const EdgeInsets.only(
              left: AppConstants.defaultPadding,
              right: AppConstants.defaultPadding,
              top: AppConstants.smallPadding,
              bottom: AppConstants.defaultPadding * 2,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: AppConstants.smallPadding,
              mainAxisSpacing: AppConstants.smallPadding,
              childAspectRatio: 0.95,
            ),
            itemCount: ToolsData.tools.length,
            itemBuilder: (context, index) {
              final tool = ToolsData.tools[index];
                return Card(
                  child: InkWell(
                    onTap: () => _navigateToTool(tool.route),
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            tool.icon,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: Text(
                              tool.title,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Flexible(
                            child: Text(
                              tool.description,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
            },
          );
        },
      ),
    );
  }
}