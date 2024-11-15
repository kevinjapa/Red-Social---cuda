import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyectointerciclo/screens/filtro.dart';
import 'dart:io';
import 'filtro.dart';// Asegúrate de importar la nueva pantalla

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
      ),
      body: Center(
        child: Text('Proximamente'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCamera,
        child: Icon(Icons.camera_alt),
        tooltip: 'Abrir cámara',
      ),
    );
  }
}