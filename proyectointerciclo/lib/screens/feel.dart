import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class feel extends StatefulWidget {
  final String username;

  const feel({Key? key, required this.username}) : super(key: key);

  @override
  _feelPageState createState() => _feelPageState();
}

class _feelPageState extends State<feel> {
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchUserImages();
  }

Future<void> _fetchUserImages() async {
  final String serverIp = await SharedPreferences.getInstance()
      .then((prefs) => prefs.getString('server_ip') ?? 'default_ip_here');
  final url = 'http://$serverIp:5001/user-images/${widget.username}';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Construir URLs absolutas
      setState(() {
        _imageUrls = List<String>.from(data['images']
            .map((url) => 'http://$serverIp:5001$url')); // URLs absolutas
      });
    } else {
      print('Error fetching images: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.username} - Imágenes'),
      ),
      body: _imageUrls.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
    );
  }
}
