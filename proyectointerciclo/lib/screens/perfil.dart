// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class Perfil extends StatefulWidget {
//   const Perfil({Key? key}) : super(key: key);

//   @override
//   _PerfilScreenState createState() => _PerfilScreenState();
// }

// class _PerfilScreenState extends State<Perfil> {
//   String _username = '';
//   TextEditingController _nombreController = TextEditingController();
//   TextEditingController _apellidoController = TextEditingController();
//   TextEditingController _correoController = TextEditingController();

//   bool _isLoading = false;
//   List<String> _imageUrls = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadUsername();
//   }

//   Future<void> _loadUsername() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _username = prefs.getString('username') ?? '';
//     });

//     if (_username.isNotEmpty) {
//       _fetchUserData();
//       _fetchUserImages();
//     }
//   }

//   Future<String> getServerIp() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('server_ip') ?? 'default_ip_here';
//   }

//   Future<void> _fetchUserData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final serverIp = await getServerIp();
//       final response = await http.get(
//         Uri.parse('http://$serverIp:5001/user/$_username'),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           _nombreController.text = data['nombre'];
//           _apellidoController.text = data['apellido'];
//           _correoController.text = data['username'];
//         });
//       } else {
//         throw Exception('Error al obtener los datos del usuario');
//       }
//     } catch (e) {
//       print('Error: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchUserImages() async {
//     final String serverIp = await getServerIp();
//     final url = 'http://$serverIp:5001/user-images/$_username';

//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         setState(() {
//           _imageUrls = List<String>.from(
//               data['images'].map((url) => 'http://$serverIp:5001$url'));
//         });
//       } else {
//         print('Error al obtener imágenes: ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF5F5F5),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : CustomScrollView(
//               slivers: [
//                 SliverAppBar(
//                   expandedHeight: 250,
//                   flexibleSpace: FlexibleSpaceBar(
//                     background: Stack(
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 Color(0xFFfeda75), 
//                                 Color(0xFFfa7e1e), 
//                                 Color(0xFFd62976), 
//                                 Color(0xFF962fbf),
//                                 Color(0xFF4f5bd5),
//                               ],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                             borderRadius: BorderRadius.only(
//                               bottomLeft: Radius.circular(30),
//                               bottomRight: Radius.circular(30),
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                           bottom: 20,
//                           left: 20,
//                           right: 20,
//                           child: Column(
//                             children: [
//                               CircleAvatar(
//                                 radius: 50,
//                                 backgroundColor: Colors.white,
//                                 backgroundImage: AssetImage('assets/avatar.png'),
//                               ),
//                               SizedBox(height: 10),
//                               Text(
//                                 '${_nombreController.text} ${_apellidoController.text}',
//                                 style: TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               Text(
//                                 '${_correoController.text}',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.white70,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       children: [
//                         // _buildInfoCard(
//                         //   icon: Icons.person_outline,
//                         //   title: 'Nombre',
//                         //   value: _nombreController.text,
//                         // ),
//                         // SizedBox(height: 10),
//                         _buildInfoCard(
//                           icon: Icons.email_outlined,
//                           title: 'Correo',
//                           value: _correoController.text,
//                         ),
//                         SizedBox(height: 10),
//                         _buildInfoCard(
//                           icon: Icons.lock_outline,
//                           title: 'Cambiar Contraseña',
//                           value: 'Actualizar',
//                           onTap: () {
//                             Navigator.pushNamed(context, '/change-password');
//                           },
//                         ),
//                         _buildInfoCard(
//                           icon: Icons.logout,
//                           title: 'Cerrar Sesión',
//                           value: 'Salir',
//                           onTap: () async {
//                             final prefs = await SharedPreferences.getInstance();
//                             await prefs.remove('username');
//                             Navigator.pushReplacementNamed(context, '/login');
//                           },
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Galería de imágenes
//                 SliverPadding(
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   sliver: _imageUrls.isEmpty
//                       ? SliverToBoxAdapter(
//                           child: Center(
//                             child: Text(
//                               "No hay publicaciones todavía",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ),
//                         )
//                       : SliverGrid(
//                           gridDelegate:
//                               SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 3,
//                             crossAxisSpacing: 8,
//                             mainAxisSpacing: 8,
//                           ),
//                           delegate: SliverChildBuilderDelegate(
//                             (context, index) {
//                               return ClipRRect(
//                                 borderRadius: BorderRadius.circular(10),
//                                 child: Image.network(
//                                   _imageUrls[index],
//                                   fit: BoxFit.cover,
//                                   errorBuilder:
//                                       (context, error, stackTrace) =>
//                                           Icon(Icons.error),
//                                 ),
//                               );
//                             },
//                             childCount: _imageUrls.length,
//                           ),
//                         ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildInfoCard(
//       {required IconData icon,
//       required String title,
//       required String value,
//       Function()? onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: ListTile(
//           leading: Icon(icon, color: Colors.blueAccent),
//           title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
//           subtitle: Text(value, style: TextStyle(color: Colors.grey[600])),
//           trailing: onTap != null
//               ? Icon(Icons.arrow_forward_ios, color: Colors.grey)
//               : null,
//         ),
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

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
  File? _selectedImage;
  String? _profileImageUrl;

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

      // Obtener datos del usuario
      final userResponse = await http.get(
        Uri.parse('http://$serverIp:5001/user/$_username'),
      );

      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body);
        setState(() {
          _nombreController.text = userData['nombre'];
          _apellidoController.text = userData['apellido'];
          _correoController.text = userData['username'];
        });
      } else {
        throw Exception('Error al obtener los datos del usuario');
      }

      // Obtener URL de la imagen de perfil
      final imageResponse = await http.get(
        Uri.parse('http://$serverIp:5001/profile-image/$_username'),
      );

      if (imageResponse.statusCode == 200) {
        final imageData = json.decode(imageResponse.body);
        setState(() {
          _profileImageUrl = imageData['imageUrl'];
        });
      } else {
        print('Error al obtener la imagen de perfil: ${imageResponse.reasonPhrase}');
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

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null) return;

    try {
      final serverIp = await getServerIp();
      final url = Uri.parse('http://$serverIp:5001/upload-profile-image');
      final request = http.MultipartRequest('POST', url)
        ..fields['username'] = _username
        ..files.add(await http.MultipartFile.fromPath('file', _selectedImage!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);

        setState(() {
          _profileImageUrl = jsonResponse['imageUrl'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Imagen de perfil actualizada con éxito")),
        );
      } else {
        throw Exception('Error al subir la imagen');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar la imagen de perfil")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFfeda75),
                                Color(0xFFfa7e1e),
                                Color(0xFFd62976),
                                Color(0xFF962fbf),
                                Color(0xFF4f5bd5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.white,
                                  backgroundImage: _profileImageUrl != null
                                      ? NetworkImage(_profileImageUrl!) as ImageProvider
                                      : (_selectedImage != null
                                          ? FileImage(_selectedImage!)
                                          : const AssetImage('assets/avatar.png')),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _uploadProfileImage,
                                child: const Text('Actualizar imagen de perfil'),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${_nombreController.text} ${_apellidoController.text}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _correoController.text,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildInfoCard(
                          icon: Icons.lock_outline,
                          title: 'Cambiar Contraseña',
                          value: 'Actualizar',
                          onTap: () {
                            Navigator.pushNamed(context, '/change-password');
                          },
                        ),
                        _buildInfoCard(
                          icon: Icons.logout,
                          title: 'Cerrar Sesión',
                          value: 'Salir',
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('username');
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                 // Galería de imágenes
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  sliver: _imageUrls.isEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Text(
                              "No hay publicaciones todavía",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  _imageUrls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          Icon(Icons.error),
                                ),
                              );
                            },
                            childCount: _imageUrls.length,
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard(
      {required IconData icon, required String title, required String value, Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.blueAccent),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(value, style: TextStyle(color: Colors.grey[600])),
          trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, color: Colors.grey) : null,
        ),
      ),
    );
  }
}
