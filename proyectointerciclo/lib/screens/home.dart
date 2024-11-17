// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'filtro.dart'; // Asegúrate de importar la nueva pantalla
// import 'perfil.dart'; // Asegúrate de importar la pantalla de perfil

// class Home extends StatefulWidget {
//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   final ImagePicker _picker = ImagePicker();
//   int _selectedIndex = 0; // Controla la pestaña activa

//   // Páginas para la barra de navegación
//   late List<Widget> _pages;

//   @override
//   void initState() {
//     super.initState();
//     _pages = [
//       Center(child: Text('Inicio', style: TextStyle(fontSize: 24))),
//       Perfil(username: 'usuarioEjemplo'), // Ventana de perfil
//       Center(child: Text('Configuración', style: TextStyle(fontSize: 24))),
//     ];
//   }

//   Future<void> _openCamera() async {
//     try {
//       final XFile? pickedFile =
//           await _picker.pickImage(source: ImageSource.camera);
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

//   // Actualiza el índice seleccionado
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Aplicación'),
//       ),
//       body: _pages[_selectedIndex], // Cambia el contenido según la pestaña
//       floatingActionButton: FloatingActionButton(
//         onPressed: _openCamera,
//         child: Icon(Icons.camera_alt),
//         tooltip: 'Abrir cámara',
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex, // Índice de la pestaña activa
//         onTap: _onItemTapped, // Llama a _onItemTapped cuando se selecciona
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
import 'dart:io';
import 'filtro.dart'; // Asegúrate de importar la nueva pantalla
import 'perfil.dart'; // Asegúrate de importar la pantalla de perfil

class Home extends StatefulWidget {
  final String username; // Recibe el username

  Home({required this.username});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ImagePicker _picker = ImagePicker();
  int _selectedIndex = 0; // Controla la pestaña activa

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Center(child: Text(widget.username, style: TextStyle(fontSize: 24))),
      Perfil(username: widget.username), // Pasa el username al perfil
      Center(child: Text('Configuración', style: TextStyle(fontSize: 24))),
    ];
  }

  Future<void> _openCamera() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
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