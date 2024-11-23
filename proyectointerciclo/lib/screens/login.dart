import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyectointerciclo/screens/home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

Future<String> getServerIp() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('server_ip') ?? 'default_ip_here';
}

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    try {
      final serverIp = await getServerIp();
      final response = await http.post(
        Uri.parse('http://$serverIp:5001/login'),

        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', username); // Guardar el nuevo usuario

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(),
            ),
          );
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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/login.png',
                        height: 130,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Bienvenido',
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: "Arial",
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 64, 64, 64),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 18),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 221, 238, 252),
                          padding:
                              EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _login,
                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                            context, '/registro'),
                        child: Text(
                          "Create an Account",
                          style: TextStyle(
                              color:
                                  const Color.fromARGB(255, 132, 155, 249)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Botón de configuración en la esquina superior derecha
          Positioned(
            top: 40,
            right: 15,
            child: IconButton(
              icon: Icon(
                Icons.settings,
                color: const Color.fromARGB(255, 90, 90, 90),
                size: 25,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ),
        ],
      ),
    );
  }
}
