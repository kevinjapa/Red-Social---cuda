// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:proyectointerciclo/screens/feel.dart'; 
// import 'package:proyectointerciclo/screens/perfil.dart' as perfil;
// import 'package:proyectointerciclo/screens/settings.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:io';
// import 'filtro.dart';

// class Home extends StatefulWidget {
//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   final ImagePicker _picker = ImagePicker();
//   int _selectedIndex = 0;
//   String _username = '';
//   late List<Widget> _pages;

//   @override
//   void initState() {
//     super.initState();
//     _loadUsername(); 
//     _pages = [
//       Feed(), 
//       perfil.Perfil(), 
//       Settings(),
//     ];
//   }

//     Future<void> _loadUsername() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _username = prefs.getString('username') ?? '';
//     });
//   }

//   Future<void> _openCamera() async {
//     try {
//       final XFile? pickedFile =
//           await _picker.pickImage(source: ImageSource.camera);
//       if (pickedFile != null) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 Filtro(image: File(pickedFile.path), username: _username,), 
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
//         title: ShaderMask(
//           shaderCallback: (Rect bounds) {
//             return const LinearGradient(
//               colors: [
//                 Color(0xFFfeda75), 
//                 Color(0xFFfa7e1e), 
//                 Color(0xFFd62976), 
//                 Color(0xFF962fbf),
//                 Color(0xFF4f5bd5),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ).createShader(bounds);
//           },
//           child: Text(
//             'Zonify',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),

//       body: Padding(
//         padding: EdgeInsets.zero,
//         child: _pages[_selectedIndex],
//       ),

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
import 'package:proyectointerciclo/screens/feel.dart';
import 'package:proyectointerciclo/screens/perfil.dart' as perfil;
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
    _loadUsername();
    _pages = [
      Feed(),
      perfil.Perfil(),
      Settings(),
    ];
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Filtro(
              image: File(pickedFile.path),
              username: _username,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error al seleccionar la imagen: $e');
    }
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar fuente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
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
        title: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFFfeda75),
                Color(0xFFfa7e1e),
                Color(0xFFd62976),
                Color(0xFF962fbf),
                Color(0xFF4f5bd5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            'Zylo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.zero,
        child: _pages[_selectedIndex],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImageSourceDialog,
        child: Icon(Icons.camera_alt),
        tooltip: 'Abrir cámara o galería',
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
