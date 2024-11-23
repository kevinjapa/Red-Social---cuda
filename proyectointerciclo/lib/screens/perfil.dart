import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Perfil extends StatefulWidget {
  const Perfil({Key? key}) : super(key: key);

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<Perfil> {
  String _username = '';
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _apellidoController = TextEditingController();
  TextEditingController _correoController = TextEditingController();

  bool _isLoading = false;
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _loadUsername(); 
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
    });

    if (_username.isNotEmpty) {
      _fetchUserData();
      _fetchUserImages();
    }
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
        Uri.parse('http://$serverIp:5001/user/$_username'),
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

  Future<void> _fetchUserImages() async {
    final String serverIp = await getServerIp();
    final url = 'http://$serverIp:5001/user-images/$_username';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Construir URLs absolutas
        setState(() {
          _imageUrls = List<String>.from(
              data['images'].map((url) => 'http://$serverIp:5001$url'));
        });
      } else {
        print('Error al obtener imágenes: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_username.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Perfil'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Lógica para cerrar sesión
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('username'); 
              Navigator.pushReplacementNamed(context, '/login'); 
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Información del usuario
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 1),
                        Text(
                          '${_nombreController.text} ${_apellidoController.text}',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${_correoController.text}',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 15),
                        Divider(thickness: 1),
                        // Opción de cambiar contraseña
                        ListTile(
                          leading: Icon(Icons.lock_outline),
                          title: Text('Cambiar Contraseña'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.pushNamed(context, '/change-password');
                          },
                        ),
                        Divider(thickness: 1),
                      ],
                    ),
                  ),
                  // Galería de imágenes
                  _imageUrls.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "No hay publicaciones todavía",
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            shrinkWrap: true, 
                            physics: NeverScrollableScrollPhysics(), 
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                            ),
                            itemCount: _imageUrls.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                _imageUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error);
                                },
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}
