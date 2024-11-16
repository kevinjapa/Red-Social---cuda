import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class Registro extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}
class _RegistroScreenState extends State<Registro> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _registro() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    final String url = 'http://192.168.0.109:5001/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
            // Muestra el SnackBar usando ScaffoldMessenger
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Usuario Registrado'), 
                duration: Duration(seconds: 1), 
                backgroundColor: Color.fromARGB(255, 150, 185, 246),
              ),
            );
            await Future.delayed(Duration(seconds: 1));
            Navigator.pushReplacementNamed(context, '/login');
          
        } else {
          _showError(responseData['message'] ?? 'Error al Registrar');
        }

      } else {
        _showError('Error en el servidor');
      }
    } catch (e) {
      _showError('No se pudo conectar al servidor');
    }
  }
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _registro,
              child: Text('Registro'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'), 
              child: Text("Regresar")
            ),
          ],
        ),
      ),
    );
  }
}