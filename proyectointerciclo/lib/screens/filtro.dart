// import 'package:flutter/material.dart';
// import 'dart:io';

// class Filtro extends StatefulWidget {
//   final File image;
//   final String username;
//   // Filtro({required this.username, required File image});

//   const   Filtro({Key? key, required this.image,required this.username}) : super(key: key);

//   @override
//   _FiltroScreenState createState() => _FiltroScreenState();
// }

// class _FiltroScreenState extends State<Filtro> {
//   String _selectedFilter = 'Original';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Aplicar Filtros'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Center(
//               child: Text(
//                 'Filtro: $_selectedFilter',
//                 style: TextStyle(fontSize: 18),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Image.file(widget.image),
//           ),
//           Expanded(
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               children: [
//                 _filterButton('Original'),
//                 _filterButton('Gabor'),
//                 _filterButton('Emboss'),
//                 _filterButton('High Boost'),
//               ],
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               print('Aplicar filtro: $_selectedFilter');
//             },
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
//         width: 40,
//         height: 40,
//         margin: EdgeInsets.symmetric(horizontal: 10),
//         padding: EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           border: Border.all(color: _selectedFilter == filterName ? Colors.blue : Colors.grey),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.filter, size: 40), // Un ícono representativo
//             Text(filterName),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart'; // Para obtener el nombre del archivo
import 'package:http_parser/http_parser.dart'; // Para MediaType
import 'package:mime/mime.dart'; // Para detectar el tipo MIME del archivo
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
  Future<String> getServerIp() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('server_ip') ?? 'default_ip_here';
  }


  Future<void> uploadImage(File image) async {
  final String url = 'http://192.168.0.106:5001/upload-image';

  try {
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Adjuntar archivo
    var file = await http.MultipartFile.fromPath(
      'file',
      image.path,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(file);

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      print('Upload successful: ${responseData.body}');
    } else {
      print('Error uploading image: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplicar Filtros'),
        actions: [
          IconButton(
            icon: Icon(Icons.upload),
            onPressed: () => uploadImage(widget.image),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Filtro: $_selectedFilter',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Expanded(
            child: Image.file(widget.image),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _filterButton('Original'),
                _filterButton('Gabor'),
                _filterButton('Emboss'),
                _filterButton('High Boost'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              print('Aplicar filtro: $_selectedFilter');
            },
            child: Text('Aplicar Filtro'),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String filterName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterName;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: _selectedFilter == filterName ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter, size: 40),
            Text(filterName),
          ],
        ),
      ),
    );
  }
}
