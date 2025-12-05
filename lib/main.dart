import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarttoolkit/core/theme/app_theme.dart';
import 'package:smarttoolkit/core/services/theme_provider.dart';
import 'package:smarttoolkit/core/constants/app_constants.dart';
import 'package:smarttoolkit/screens/home_screen.dart';
import 'package:smarttoolkit/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}