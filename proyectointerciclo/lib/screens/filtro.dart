// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as path; // Prefijo para evitar conflictos
// import 'package:http_parser/http_parser.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// class Filtro extends StatefulWidget {
//   final File image;
//   final String username;

//   const Filtro({Key? key, required this.image, required this.username}) : super(key: key);

//   @override
//   _FiltroScreenState createState() => _FiltroScreenState();
// }
// class _FiltroScreenState extends State<Filtro> {
//   final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>(); // GlobalKey para el ScaffoldMessenger
//   String _selectedFilter = 'Original';
//   Uint8List? _processedImageBytes;

//   Future<String> getServerIp() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString('server_ip') ?? 'default_ip_here';
//   }

//   // Aplica filtro a la imagen seleccionada
//   Future<void> applyFilter() async {

//     if (_selectedFilter == 'Original') {
//       // Mostrar la imagen original sin enviar ninguna solicitud al servidor
//       setState(() {
//         _processedImageBytes = null; // Asegurarse de que se muestre la imagen original
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Mostrando imagen original')),
//       );
//       return; // Detener la ejecución del método
//     }

//     final serverIp = await getServerIp();
//     final String filterUrl = 'http://$serverIp:5001/apply-filter';

//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(filterUrl));
//       var file = await http.MultipartFile.fromPath(
//         'file',
//         widget.image.path,
//         contentType: MediaType('image', 'jpeg'),
//       );
//       request.files.add(file);
//       request.fields['filter'] = _selectedFilter; // Filtro seleccionado
//       request.fields['kernel_size'] = '21'; // Tamaño del kernel predeterminado

//       var response = await request.send();
//       if (response.statusCode == 200) {
//         var responseData = await http.Response.fromStream(response);
//         setState(() {
//           _processedImageBytes = responseData.bodyBytes; // Guarda la imagen procesada
//         });
//         _scaffoldKey.currentState?.showSnackBar(
//           SnackBar(content: Text('Filtro aplicado con éxito')),
//         );
//       } else {
//         throw Exception('Error aplicando filtro: ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('Error: $e');
//       _scaffoldKey.currentState?.showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   Future<void> uploadImage() async {
//     final serverIp = await getServerIp();
//     final String url = 'http://$serverIp:5001/upload-image';

//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(url));

//       if (_processedImageBytes != null) {
//         // Sube la imagen procesada si existe
//         var processedFile = http.MultipartFile.fromBytes(
//           'file',
//           _processedImageBytes!,
//           filename: '${path.basename(widget.image.path)}_processed.jpg',
//           contentType: MediaType('image', 'jpeg'),
//         );
//         request.files.add(processedFile);
//       } else {
//         // Sube la imagen original
//         var originalFile = await http.MultipartFile.fromPath(
//           'file',
//           widget.image.path,
//           contentType: MediaType('image', 'jpeg'),
//         );
//         request.files.add(originalFile);
//       }

//       request.fields['username'] = widget.username;

//       var response = await request.send();

//       if (response.statusCode == 200) {
//         _scaffoldKey.currentState?.showSnackBar(
//           SnackBar(content: Text('Imagen subida con éxito')),
//         );
//       } else {
//         throw Exception('Error subiendo imagen: ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('Error: $e');
//       _scaffoldKey.currentState?.showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Aplicar Filtros'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.upload),
//             onPressed: uploadImage,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Center(
//               child: Text(
//                 'Filtro: $_selectedFilter',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//           ),
//           Expanded(
//             child: _processedImageBytes != null
//                 ? Image.memory(
//               _processedImageBytes!,
//               fit: BoxFit.contain,
//             )
//                 : Image.file(widget.image),
//           ),
//           Expanded(
//             child: Container(
//               height: 20,
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 children: [
//                   SizedBox(
//                     width: 100,
//                     height: 100,
//                     // child: _filterButton("Original"),
//                     child: FittedBox(
//                       child: _filterButton("Original"),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 100,
//                     height: 100,
//                     child: FittedBox(
//                       child: _filterButton('Gabor'),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 100,
//                     height: 100,
//                     child: FittedBox(
//                       child: _filterButton('Emboss'),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 100,
//                     height: 100,
//                     child: FittedBox(
//                       child: _filterButton('High Boost'),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 100,
//                     height: 100,
//                     child: FittedBox(
//                       child: _filterButton('Contrast Enhancement'),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 100,
//                     height: 100,
//                     child: FittedBox(
//                       child: _filterButton('Selective Tone'),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: applyFilter,
//             child: Text('Aplicar Filtro'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _filterButton(String filterName) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedFilter = filterName;
//         });
//       },
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 10),
//         padding: EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           border: Border.all(color: _selectedFilter == filterName ? Colors.blue : Colors.grey),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.filter, size: 25),
//             Text(filterName),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:proyectointerciclo/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Filtro extends StatefulWidget {
  final File image;
  final String username;

  const Filtro({Key? key, required this.image, required this.username}) : super(key: key);

  @override
  _FiltroScreenState createState() => _FiltroScreenState();
}

class _FiltroScreenState extends State<Filtro> {
  String _selectedFilter = 'Original';
  Uint8List? _processedImageBytes;
  bool _isApplyingFilter = false;

  Future<String> getServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_ip') ?? 'default_ip_here';
  }

  Future<void> applyFilter() async {
    if (_selectedFilter == 'Original') {
      setState(() {
        _processedImageBytes = null;
        _isApplyingFilter = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mostrando imagen original')),
      );
      return;
    }

    final serverIp = await getServerIp();
    final String filterUrl = 'http://$serverIp:5001/apply-filter';

    setState(() {
      _isApplyingFilter = true;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(filterUrl));
      var file = await http.MultipartFile.fromPath(
        'file',
        widget.image.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(file);
      request.fields['filter'] = _selectedFilter;

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        setState(() {
          _processedImageBytes = responseData.bodyBytes;
          _isApplyingFilter = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Filtro aplicado con éxito')),
        );
      } else {
        throw Exception('Error aplicando filtro');
      }
    } catch (e) {
      setState(() {
        _isApplyingFilter = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> uploadImage() async {
    final serverIp = await getServerIp();
    final String url = 'http://$serverIp:5001/upload-image';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      if (_processedImageBytes != null) {
        var processedFile = http.MultipartFile.fromBytes(
          'file',
          _processedImageBytes!,
          filename: '${path.basename(widget.image.path)}_processed.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(processedFile);
      } else {
        var originalFile = await http.MultipartFile.fromPath(
          'file',
          widget.image.path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(originalFile);
      }

      request.fields['username'] = widget.username;

      var response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imagen subida con éxito')),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(),
          ),
        );
      } else {
        throw Exception('Error subiendo imagen');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Publicar'),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.upload),
      //       onPressed: uploadImage,
      //     ),
      //   ],
      // ),
      appBar: AppBar(
        title: Text('Nueva Publicación'),
        // actions: [
        //   TextButton.icon(
        //     icon: Icon(Icons.upload, color: const Color.fromARGB(255, 37, 37, 37)),
        //     label: Text(
        //       'Publicar',
        //       style: TextStyle(color: const Color.fromARGB(255, 45, 45, 45)),
        //     ),
        //     onPressed: uploadImage,
        //   ),
        // ],
      ),

      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: _isApplyingFilter
                ? Center(child: CircularProgressIndicator())
                : (_processedImageBytes != null
                    ? Image.memory(_processedImageBytes!, fit: BoxFit.contain)
                    : Image.file(widget.image, fit: BoxFit.contain)),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _filterTile('Original', Icons.image),
                  _filterTile('Gabor', Icons.texture),
                  _filterTile('Emboss', Icons.blur_on),
                  _filterTile('High Boost', Icons.high_quality),
                  _filterTile('Contrast Enhancement', Icons.contrast),
                  _filterTile('Selective Tone', Icons.tune),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: uploadImage,
              icon: Icon(Icons.filter),
              label: Text('Publicar'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterTile(String filterName, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterName;
        });
        applyFilter();
      },
      child: Container(
        decoration: BoxDecoration(
          color: _selectedFilter == filterName ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            SizedBox(height: 8),
            Text(
              filterName,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
