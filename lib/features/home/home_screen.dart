import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarttoolkit/core/constants/app_constants.dart';
import 'package:smarttoolkit/core/constants/tools_data.dart';
import 'package:smarttoolkit/core/services/theme_provider.dart';
import 'package:smarttoolkit/features/calculator/calculator_screen.dart';
import 'package:smarttoolkit/features/notes/notes_screen.dart';
import 'package:smarttoolkit/features/password_generator/password_generator_screen.dart';
import 'package:smarttoolkit/features/qr_generator/qr_generator_screen.dart';
import 'package:smarttoolkit/features/tip_calculator/tip_calculator_screen.dart';
import 'package:smarttoolkit/features/unit_converter/unit_converter_screen.dart';
import 'package:smarttoolkit/features/age_calculator/age_calculator_screen.dart';
import 'package:smarttoolkit/features/bmi_calculator/bmi_calculator_screen.dart';
import 'package:smarttoolkit/features/stopwatch/stopwatch_screen.dart';
import 'package:smarttoolkit/features/todo_list/todo_list_screen.dart';
import 'package:smarttoolkit/features/flashlight/flashlight_screen.dart';
import 'package:smarttoolkit/features/countdown_timer/countdown_timer_screen.dart';
import 'package:smarttoolkit/features/qr_scanner/qr_scanner_screen.dart';
import 'package:smarttoolkit/features/image_to_text/image_to_text_screen.dart';
import 'package:smarttoolkit/features/sound_meter/sound_meter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  
  List<ToolItem> get filteredTools {
    if (_searchQuery.isEmpty) {
      return ToolsData.tools;
    }
    return ToolsData.tools.where((tool) =>
        tool.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        tool.description.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void _navigateToTool(String route) {
    Widget screen;
    switch (route) {
      case '/calculator':
        screen = const CalculatorScreen();
        break;
      case '/notes':
        screen = const NotesScreen();
        break;
      case '/password-generator':
        screen = const PasswordGeneratorScreen();
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
      case '/age-calculator':
        screen = const AgeCalculatorScreen();
        break;
      case '/bmi-calculator':
        screen = const BmiCalculatorScreen();
        break;
      case '/stopwatch':
        screen = const StopwatchScreen();
        break;
      case '/todo-list':
        screen = const TodoListScreen();
        break;
      case '/flashlight':
        screen = const FlashlightScreen();
        break;
      case '/countdown-timer':
        screen = const CountdownTimerScreen();
        break;
      case '/qr-scanner':
        screen = const QrScannerScreen();
        break;
      case '/image-to-text':
        screen = const ImageToTextScreen();
        break;
      case '/sound-meter':
        screen = const SoundMeterScreen();
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search tools...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.smallPadding,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.smallPadding,
                mainAxisSpacing: AppConstants.smallPadding,
                childAspectRatio: 0.95,
              ),
              itemCount: filteredTools.length,
              itemBuilder: (context, index) {
                final tool = filteredTools[index];
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
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
            ),
          ),
        ],
      ),
    );
  }
}