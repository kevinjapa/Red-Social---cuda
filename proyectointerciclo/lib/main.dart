
// import 'package:flutter/material.dart';

// import 'src/settings/settings_controller.dart';
// import 'src/settings/settings_service.dart';
// import 'screens/home.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   final settingsController = SettingsController(SettingsService());

//   await settingsController.loadSettings();

//   runApp(MyApp(settingsController: settingsController));
// }

// class MyApp extends StatelessWidget {
//   final SettingsController settingsController;

//   const MyApp({Key? key, required this.settingsController}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Home(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:proyectointerciclo/screens/filtro.dart';

import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'screens/home.dart';
import 'screens/login.dart'; // Asegúrate de que la ruta sea correcta
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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/registro': (context) => Registro(),
        '/home': (context) => Home(),  
      },
    );
  }
}