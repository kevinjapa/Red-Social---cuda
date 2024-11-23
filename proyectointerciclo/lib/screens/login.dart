import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyectointerciclo/screens/home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
        //  Uri.parse('http://172.20.10.3:5001/login'),
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
          await prefs.setString('username', username);

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
          AnimatedContainer(
            duration: Duration(seconds: 2),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade300],
                // colors: [const Color.fromARGB(255, 201, 217, 233), const Color.fromARGB(255, 235, 240, 245)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      '¡Bienvenido!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _usernameController,
                      hintText: 'Username',
                      icon: Icons.person,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    SizedBox(height: 24),
                    GestureDetector(
                      onTapDown: (_) => _animationController.forward(),
                      onTapUp: (_) => _animationController.reverse(),
                      onTap: _login,
                      child: ScaleTransition(
                        scale: _buttonScale,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 80,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade400,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/registro'),
                      child: Text(
                        "Create an Account",
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}