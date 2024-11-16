// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:proyectointerciclo/screens/filtro.dart';
// import 'dart:io';
// import 'filtro.dart';// Asegúrate de importar la nueva pantalla

// class Home extends StatefulWidget {
//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _openCamera() async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
//       if (pickedFile != null) {
//         // Navega a la pantalla de filtros con la imagen capturada
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => Filtro(image: File(pickedFile.path)),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error al abrir la cámara: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Inicio'),
//       ),
//       body: Center(
//         child: Text('Proximamente'),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _openCamera,
//         child: Icon(Icons.camera_alt),
//         tooltip: 'Abrir cámara',
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'filtro.dart'; // Asegúrate de importar la nueva pantalla

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ImagePicker _picker = ImagePicker();
  int _selectedIndex = 0; // Controla la pestaña activa

  // Páginas para la barra de navegación
  final List<Widget> _pages = [
    Center(child: Text('Inicio', style: TextStyle(fontSize: 24))),
    Center(child: Text('Perfil', style: TextStyle(fontSize: 24))),
    Center(child: Text('Configuración', style: TextStyle(fontSize: 24))),
  ];

  Future<void> _openCamera() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        // Navega a la pantalla de filtros con la imagen capturada
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Filtro(image: File(pickedFile.path)),
          ),
        );
      }
    } catch (e) {
      print('Error al abrir la cámara: $e');
    }
  }

  // Actualiza el índice seleccionado
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplicación'),
      ),
      body: _pages[_selectedIndex], // Cambia el contenido según la pestaña
      floatingActionButton: FloatingActionButton(
        onPressed: _openCamera,
        child: Icon(Icons.camera_alt),
        tooltip: 'Abrir cámara',
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Índice de la pestaña activa
        onTap: _onItemTapped, // Llama a _onItemTapped cuando se selecciona
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feel',
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