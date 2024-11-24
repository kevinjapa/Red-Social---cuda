// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class Feed extends StatefulWidget {
//   const Feed({Key? key}) : super(key: key);

//   @override
//   _FeedState createState() => _FeedState();
// }

// class _FeedState extends State<Feed> {
//   String _username = '';
//   List<Map<String, dynamic>> _posts = [];

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
//     _fetchPosts(); 
//   }

//   Future<String> getServerIp() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('server_ip') ?? 'default_ip_here';
//   }

//   Future<void> _fetchPosts() async {
//     final String serverIp = await getServerIp();
//     final url = 'http://$serverIp:5001/feed';

//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           _posts = List<Map<String, dynamic>>.from(data['posts']);
//         });
//       } 
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<String>(
//       future: getServerIp(),
//       builder: (context, snapshot) {
//         final String serverIp = snapshot.data ?? 'default_ip_here';
//         return Scaffold(
//           body: _posts.isEmpty
//               ? Center(child: CircularProgressIndicator())
//               : ListView.builder(
//                   padding: EdgeInsets.zero, 
//                   itemCount: _posts.length,
//                   itemBuilder: (context, index) {
//                     final post = _posts[index];
//                     return PostCard(
//                       username: _username,
//                       imageUrl: 'http://$serverIp:5001${post['imageUrl']}',
//                       description: post['description'],
//                       likes: post['likes'] ?? [],
//                       comments: post['comments'] ?? [],
//                     );
//                   },
//                 ),
//         );
//       }
//     );
//   }
// }

// class PostCard extends StatefulWidget {
//   final String username;
//   final String imageUrl;
//   final String description;
//   final List<dynamic> likes;
//   final List<dynamic> comments;

//   const PostCard({
//     Key? key,
//     required this.username,
//     required this.imageUrl,
//     required this.description,
//     required this.likes,
//     required this.comments,
//   }) : super(key: key);

//   @override
//   _PostCardState createState() => _PostCardState();
// }

// class _PostCardState extends State<PostCard> {
//   late List<dynamic> likes;
//   late List<dynamic> comments;

//   @override
//   void initState() {
//     super.initState();
//     likes = widget.likes;
//     comments = widget.comments;
//   }

//   Future<void> _likePost() async {
//     final serverIp = await SharedPreferences.getInstance()
//         .then((prefs) => prefs.getString('server_ip') ?? 'default_ip_here');

//     final url = 'http://$serverIp:5001/like-post';

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'username': widget.username,
//           'imageUrl': widget.imageUrl,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           likes = List<dynamic>.from(data['likes'] ?? []);
//         });
//       }
//     } catch (e) {
//       print('Error en el cliente Flutter: $e');
//     }
//   }

// Future<void> _addComment(String comment) async {
//   if (comment.trim().isEmpty) {
//     return;
//   }

//   final prefs = await SharedPreferences.getInstance();
//   final serverIp = prefs.getString('server_ip') ?? 'default_ip_here';
//   final url = 'http://$serverIp:5001/comment-post';

//   try {
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'username': widget.username,
//         'imageUrl': widget.imageUrl,
//         'comment': comment.trim(),
//       }),
//     );
//     if (response.statusCode == 200) {
//       final responseData = json.decode(response.body);
//       setState(() {
//         comments = List<Map<String, dynamic>>.from(responseData['comments']);
//       });
//     }
//   } catch (e) {
//     print('Error al agregar comentario: $e');
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.zero,
//       elevation: 0, // Quita la sombra del Card    
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ListTile(
//             leading: CircleAvatar(
//               backgroundColor: Colors.grey[300],
//               child: Icon(Icons.person, color: Colors.white),
//             ),
//             title: Text(
//               widget.username,
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           ClipRRect(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
//             child: Image.network(
//               widget.imageUrl,
//               fit: BoxFit.cover,
//               width: double.infinity,
//               height: 250,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   color: Colors.grey[300],
//                   height: 250,
//                   child: Icon(Icons.error, size: 50),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               widget.description,
//               style: TextStyle(fontSize: 16),
//             ),
//           ),
//           Row(
//             children: [
//               IconButton(
//                 icon: Icon(
//                   likes.contains(widget.username)
//                       ? Icons.favorite
//                       : Icons.favorite_border,
//                 ),
//                 onPressed: _likePost,
//               ),
//               Text('${likes.length} likes'),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 for (var comment in comments)
//                   Text('${comment['username']}: ${comment['comment']}'),
//                 TextField(
//                   onSubmitted: (text) {
//                     if (text.isNotEmpty) {
//                       _addComment(text);
//                     }
//                   },
//                   decoration: InputDecoration(labelText: 'Agregar un comentario...'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  String _username = '';
  List<Map<String, dynamic>> _posts = [];

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
    _fetchPosts(); 
  }

  Future<String> getServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_ip') ?? 'default_ip_here';
  }

  Future<void> _fetchPosts() async {
    final String serverIp = await getServerIp();
    final url = 'http://$serverIp:5001/feed';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _posts = List<Map<String, dynamic>>.from(data['posts']);
        });
      } else {
        print('Error fetching posts: ${response.reasonPhrase}');
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
          title: Text('Inicio'),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<String>(
      future: getServerIp(),
      builder: (context, snapshot) {
          final String serverIp = snapshot.data ?? 'default_ip_here';
          return Scaffold(
            body: _posts.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.zero, // Sin espacio superior ni inferior 
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return PostCard(
                        username: _username,
                        imageUrl: 'http://$serverIp:5001${post['imageUrl']}',
                        description: post['description'],
                        likes: post['likes'] ?? [],
                        comments: post['comments'] ?? [],
                      );
                    },
                  ),
          );
        }
    );
  }
}

class PostCard extends StatefulWidget {
  final String username;
  final String imageUrl;
  final String description;
  final List<dynamic> likes;
  final List<dynamic> comments;

  const PostCard({
    Key? key,
    required this.username,
    required this.imageUrl,
    required this.description,
    required this.likes,
    required this.comments,
  }) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late List<dynamic> likes;
  late List<dynamic> comments;

  @override
  void initState() {
    super.initState();
    likes = widget.likes;
    comments = widget.comments;
  }

  Future<void> _likePost() async {
    final serverIp = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('server_ip') ?? 'default_ip_here');

    final url = 'http://$serverIp:5001/like-post';

    try {
      // print('Enviando datos: username=${widget.username}, imageUrl=${widget.imageUrl}');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': widget.username,
          'imageUrl': widget.imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          likes = List<dynamic>.from(data['likes'] ?? []);
        });
      } else {
        // print('Error al enviar like: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error en el cliente Flutter: $e');
    }
  }

Future<void> _addComment(String comment) async {
  if (comment.trim().isEmpty) {
    print("Comentario vacío. No se puede agregar.");
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  final serverIp = prefs.getString('server_ip') ?? 'default_ip_here';
  final url = 'http://$serverIp:5001/comment-post';

  try {
    print("URL de solicitud: $url");
    print("Datos enviados: username=${widget.username}, imageUrl=${widget.imageUrl}, comment=$comment");

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': widget.username,
        'imageUrl': widget.imageUrl,
        'comment': comment.trim(),
      }),
    );

    print("Código de respuesta: ${response.statusCode}");
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        comments = List<Map<String, dynamic>>.from(responseData['comments']);
      });
      print('Comentario agregado correctamente.');
    } else {
      print('Error al agregar comentario: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    print('Error al agregar comentario: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Card(
      // margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      // elevation: 2,
      margin: EdgeInsets.zero, // Elimina el espacio alrededor de cada Card
      elevation: 0, // Opcional: Quita la sombra
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              widget.username,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  height: 250,
                  child: Icon(Icons.error, size: 50),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.description,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  likes.contains(widget.username)
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                onPressed: _likePost,
              ),
              Text('${likes.length} likes'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var comment in comments)
                  Text('${comment['username']}: ${comment['comment']}'),
                TextField(
                  onSubmitted: (text) {
                    if (text.isNotEmpty) {
                      _addComment(text);
                    }
                  },
                  decoration: InputDecoration(labelText: 'Agregar un comentario...'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}