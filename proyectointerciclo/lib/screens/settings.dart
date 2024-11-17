import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController _ipController = TextEditingController();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadSavedIp();
  }

  Future<void> _loadSavedIp() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = _prefs.getString('server_ip') ?? '';
    });
  }

  Future<void> _saveIp() async {
    await _prefs.setString('server_ip', _ipController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dirección IP guardada con éxito')),
    );
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'Dirección IP del servidor',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.save),
                  onPressed: _saveIp,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              ),
              child: Text(
                'Cerrar sesión',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}