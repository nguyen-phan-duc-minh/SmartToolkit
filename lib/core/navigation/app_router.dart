
import 'package:go_router/go_router.dart';
import 'package:smarttoolkit/screens/home_screen.dart';
import 'package:smarttoolkit/screens/calculator_screen.dart';
import 'package:smarttoolkit/screens/notes_screen.dart';
import 'package:smarttoolkit/screens/password_generator_screen.dart';
import 'package:smarttoolkit/screens/qr_generator_screen.dart';
import 'package:smarttoolkit/screens/tip_calculator_screen.dart';
import 'package:smarttoolkit/screens/unit_converter_screen.dart';
import 'package:smarttoolkit/screens/age_calculator_screen.dart';
import 'package:smarttoolkit/screens/bmi_calculator_screen.dart';
import 'package:smarttoolkit/screens/stopwatch_screen.dart';
import 'package:smarttoolkit/screens/todo_list_screen.dart';
import 'package:smarttoolkit/screens/flashlight_screen.dart';
import 'package:smarttoolkit/screens/countdown_timer_screen.dart';
import 'package:smarttoolkit/screens/qr_scanner_screen.dart';
import 'package:smarttoolkit/screens/image_to_text_screen.dart';
import 'package:smarttoolkit/screens/sound_meter_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/calculator',
        name: 'calculator',
        builder: (context, state) => const CalculatorScreen(),
      ),
      GoRoute(
        path: '/notes',
        name: 'notes',
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        path: '/password-generator',
        name: 'password-generator',
        builder: (context, state) => const PasswordGeneratorScreen(),
      ),
      GoRoute(
        path: '/qr-generator',
        name: 'qr-generator',
        builder: (context, state) => const QrGeneratorScreen(),
      ),
      GoRoute(
        path: '/tip-calculator',
        name: 'tip-calculator',
        builder: (context, state) => const TipCalculatorScreen(),
      ),
      GoRoute(
        path: '/unit-converter',
        name: 'unit-converter',
        builder: (context, state) => const UnitConverterScreen(),
      ),
      GoRoute(
        path: '/age-calculator',
        name: 'age-calculator',
        builder: (context, state) => const AgeCalculatorScreen(),
      ),
      GoRoute(
        path: '/bmi-calculator',
        name: 'bmi-calculator',
        builder: (context, state) => const BmiCalculatorScreen(),
      ),
      GoRoute(
        path: '/stopwatch',
        name: 'stopwatch',
        builder: (context, state) => const StopwatchScreen(),
      ),
      GoRoute(
        path: '/todo-list',
        name: 'todo-list',
        builder: (context, state) => const TodoListScreen(),
      ),
      GoRoute(
        path: '/flashlight',
        name: 'flashlight',
        builder: (context, state) => const FlashlightScreen(),
      ),
      GoRoute(
        path: '/countdown-timer',
        name: 'countdown-timer',
        builder: (context, state) => const CountdownTimerScreen(),
      ),
      GoRoute(
        path: '/qr-scanner',
        name: 'qr-scanner',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/image-to-text',
        name: 'image-to-text',
        builder: (context, state) => const ImageToTextScreen(),
      ),
      GoRoute(
        path: '/sound-meter',
        name: 'sound-meter',
        builder: (context, state) => const SoundMeterScreen(),
      ),
    ],
  );
}