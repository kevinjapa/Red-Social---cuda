import 'package:flutter/material.dart';
import 'package:proyectointerciclo/screens/filtro.dart';
import 'package:proyectointerciclo/screens/settings.dart';

import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/register.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsController = SettingsController(SettingsService());

  await settingsController.loadSettings();

  runApp(MyApp(settingsController: settingsController));
}

class MyApp extends StatelessWidget {
  final SettingsController settingsController;

  const MyApp({Key? key, required this.settingsController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/registro': (context) => Registro(),
        '/settings':(context) => Settings(),
        // '/home': (context) => Home(),  
      },
    );
  }
}