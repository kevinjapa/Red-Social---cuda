// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// class Registro extends StatefulWidget {
//   @override
//   _RegistroScreenState createState() => _RegistroScreenState();
// }
// class _RegistroScreenState extends State<Registro> {
//   final TextEditingController _nombreController = TextEditingController();
//   final TextEditingController _apellidoController = TextEditingController();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();


//   Future<void> _registro() async {
//     final String nombre = _nombreController.text;
//     final String apellido = _apellidoController.text;
//     final String username = _usernameController.text;
//     final String password = _passwordController.text;

//     final String url = 'http://172.20.10.3:5001/register';

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(<String, String>{
//           'username': username,
//           'password': password,
//         }),
//       );

//       if (response.statusCode == 201) {
//         final Map<String, dynamic> responseData = jsonDecode(response.body);

//         if (responseData['success'] == true) {
//             // Muestra el SnackBar usando ScaffoldMessenger
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Usuario Registrado'), 
//                 duration: Duration(seconds: 1), 
//                 backgroundColor: Color.fromARGB(255, 150, 185, 246),
//               ),
//             );
//             await Future.delayed(Duration(seconds: 1));
//             Navigator.pushReplacementNamed(context, '/login');
          
//         } else {
//           _showError(responseData['message'] ?? 'Error al Registrar');
//         }

//       } else {
//         _showError('Error en el servidor');
//       }
//     } catch (e) {
//       _showError('No se pudo conectar al servidor');
//     }
//   }
//   void _showError(String message) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Error'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Registro'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _nombreController,
//               decoration: const InputDecoration(
//                 labelText: 'Nombre ',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16.0),
//             TextField(
//               controller: _apellidoController,
//               decoration: const InputDecoration(
//                 labelText: 'Apellido',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16.0),
            
//             TextField(
//               controller: _usernameController,
//               decoration: const InputDecoration(
//                 labelText: 'Correo',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16.0),
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(
//                 labelText: 'Password',
//                 border: OutlineInputBorder(),
//               ),
//               obscureText: true,
//             ),
//             SizedBox(height: 20.0),

//             ElevatedButton(
//               onPressed: _registro,
//               child: Text('Registro'),
//             ),
//             SizedBox(height: 20.0),
//             ElevatedButton(
//               onPressed: () => Navigator.pushReplacementNamed(context, '/login'), 
//               child: Text("Regresar")
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Registro extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<Registro> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _registro() async {
    final String nombre = _nombreController.text;
    final String apellido = _apellidoController.text;
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    final String url = 'http://172.20.10.3:5001/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
          'nombre': nombre,
          'apellido': apellido,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
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
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [Colors.orange, Colors.pink, Colors.blue],
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //   ),
        // ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/register.png',
                    height: 80,
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Create Your Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                       color: const Color.fromARGB(255, 64, 64, 64),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Nombre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _apellidoController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Apellido',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Correo',
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
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Colors.blue,
                      backgroundColor: const Color.fromARGB(255, 221, 238, 252), 
                      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _registro,
                    child: Text(
                      'Registro',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: Text(
                      "Regresar",
                      // style: TextStyle(color: Colors.white),
                       style: TextStyle(color: const Color.fromARGB(255, 132, 155, 249)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
