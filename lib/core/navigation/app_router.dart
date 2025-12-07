import 'package:go_router/go_router.dart';
import 'package:smarttoolkit/screens/home_screen.dart';
import 'package:smarttoolkit/screens/calculator_screen.dart';
import 'package:smarttoolkit/screens/notes_screen.dart';
import 'package:smarttoolkit/screens/qr_generator_screen.dart';
import 'package:smarttoolkit/screens/tip_calculator_screen.dart';
import 'package:smarttoolkit/screens/unit_converter_screen.dart';
import 'package:smarttoolkit/screens/flashlight_screen.dart';
import 'package:smarttoolkit/screens/countdown_timer_screen.dart';
import 'package:smarttoolkit/screens/image_to_text_screen.dart';

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
        path: '/image-to-text',
        name: 'image-to-text',
        builder: (context, state) => const ImageToTextScreen(),
      ),
    ],
  );
}