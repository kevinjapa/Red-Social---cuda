// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:proyectointerciclo/screens/feel.dart';
// import 'package:proyectointerciclo/screens/settings.dart';
// import 'dart:io';
// import 'filtro.dart';
// import 'perfil.dart';

// class Home extends StatefulWidget {
//   final String username;

//   Home({required this.username});

//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   final ImagePicker _picker = ImagePicker();
//   int _selectedIndex = 0;

//   late List<Widget> _pages;

//   @override
//   void initState() {
//     super.initState();
//     _pages = [
//       Feed(username: widget.username),
//       Perfil(username: widget.username), // Pasa el username al perfil
//       Settings(),
//     ];
//   }
//   Future<void> _openCamera() async {
//     try {
//       final XFile? pickedFile =
//           await _picker.pickImage(source: ImageSource.camera);
//       if (pickedFile != null) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => Filtro(image: File(pickedFile.path), username: widget.username),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error al abrir la cámara: $e');
//     }
//   }
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Instagram'),
//       ),
//       body: _pages[_selectedIndex],
//       floatingActionButton: FloatingActionButton(
//         onPressed: _openCamera,
//         child: Icon(Icons.camera_alt),
//         tooltip: 'Abrir cámara',
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Inicio',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Perfil',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Configuración',
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyectointerciclo/screens/feel.dart'; // Asegúrate de importar correctamente Feed
import 'package:proyectointerciclo/screens/perfil.dart' as perfil; // Alias para evitar conflicto
import 'package:proyectointerciclo/screens/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'filtro.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ImagePicker _picker = ImagePicker();
  int _selectedIndex = 0;
  String _username = '';
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadUsername(); // Cargar el username desde SharedPreferences
    _pages = [
      Feed(), // Asegúrate de que Feed esté definido y correctamente importado
      perfil.Perfil(), // Usa el alias para evitar conflictos
      Settings(),
    ];
  }

    Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
    });
  }

  Future<void> _openCamera() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Filtro(image: File(pickedFile.path), username: _username,), // Filtro ya definido
          ),
        );
      }
    } catch (e) {
      print('Error al abrir la cámara: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instagram'),
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _openCamera,
        child: Icon(Icons.camera_alt),
        tooltip: 'Abrir cámara',
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}
