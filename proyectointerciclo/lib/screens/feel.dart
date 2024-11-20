import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Feed extends StatefulWidget {
  final String username;

  const Feed({Key? key, required this.username}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
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
    return FutureBuilder<String>(
      future: getServerIp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Inicio'),
              centerTitle: true,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Inicio'),
              centerTitle: true,
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          final String serverIp = snapshot.data ?? 'default_ip_here';
          return Scaffold(
            appBar: AppBar(
              title: Text('Inicio'),
              centerTitle: true,
            ),
            body: _posts.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return PostCard(
                        username: post['username'],
                        imageUrl: 'http://$serverIp:5001${post['imageUrl']}',
                        description: post['description'],
                        likes: post['likes'] ?? [],
                        comments: post['comments'] ?? [],
                      );
                    },
                  ),
          );
        }
      },
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
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': widget.username,
        'imageUrl': widget.imageUrl,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        likes = json.decode(response.body)['likes'];
      });
    }
  }

  Future<void> _addComment(String comment) async {
    final serverIp = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('server_ip') ?? 'default_ip_here');

    final url = 'http://$serverIp:5001/comment-post';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': widget.username,
        'imageUrl': widget.imageUrl,
        'comment': comment,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        comments = json.decode(response.body)['comments'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 2,
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
