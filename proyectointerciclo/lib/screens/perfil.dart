import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Perfil extends StatefulWidget {
  final String username;

  Perfil({required this.username});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<Perfil> {
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _apellidoController = TextEditingController();
  TextEditingController _correoController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
  Future<String> getServerIp() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('server_ip') ?? 'default_ip_here';
}
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final serverIp = await getServerIp();
      final response = await http.get(
        // Uri.parse('http://192.168.0.104:5001/user/${widget.username}'),
         Uri.parse('http://$serverIp:5001/user/${widget.username}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _nombreController.text = data['nombre'];
          _apellidoController.text = data['apellido'];
          _correoController.text = data['username'];
        });
      } else {
        throw Exception('Error al obtener los datos del usuario');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePassword() async {
    if (_newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La nueva contraseña no puede estar vacía')),
      );
      return;
    }

    try {
      final serverIp = await getServerIp();
      final response = await http.post(
        
        // Uri.parse('http://192.168.0.104:5001/update-password'),
         Uri.parse('http://$serverIp:5001/update-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': widget.username,
          'new_password': _newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contraseña actualizada con éxito')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la contraseña')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _apellidoController,
                    decoration: InputDecoration(labelText: 'Apellido'),
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _correoController,
                    decoration: InputDecoration(labelText: 'Correo'),
                    readOnly: true,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    readOnly: true,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(labelText: 'Nueva Contraseña'),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updatePassword,
                    child: Text('Actualizar Contraseña'),
                  ),
                ],
              ),
            ),
    );
  }
}