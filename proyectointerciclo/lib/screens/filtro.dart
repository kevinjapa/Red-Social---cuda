import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart'; 
import 'package:http_parser/http_parser.dart'; 
import 'package:mime/mime.dart'; 
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
  final serverIp = await getServerIp(); 
  final String url = 'http://$serverIp:5001/upload-image';

  try {

    var request = http.MultipartRequest('POST', Uri.parse(url));

    var file = await http.MultipartFile.fromPath(
      'file', 
      image.path,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(file);

    
    request.fields['username'] = widget.username; 

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      print('Upload successful: ${responseData.body}');
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Imagen subida con éxito')),
      );
    } else {
      print('Error uploading image: ${response.reasonPhrase}');
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Error al subir la imagen')),
      );
    }
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(content: Text('Error al conectar con el servidor')),
    );
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
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: Image.file(widget.image),
          ),
          Expanded(
            child: Container(
              height: 20,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    // child: _filterButton("Original"),
                    child: FittedBox(
                      child: _filterButton("Original"),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: FittedBox(
                      child: _filterButton('Gabor'),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: FittedBox(
                      child: _filterButton('Emboss'),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: FittedBox(
                      child: _filterButton('High Boost'),
                    ),
                  )
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              print('Aplicar filtro: $_selectedFilter');
            },
            child: Text('Publicar'),
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
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: _selectedFilter == filterName ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter, size: 25),
            Text(filterName),
          ],
        ),
      ),
    );
  }
}
