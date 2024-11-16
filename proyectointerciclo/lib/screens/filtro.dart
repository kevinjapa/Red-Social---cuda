import 'package:flutter/material.dart';
import 'dart:io';

class Filtro extends StatefulWidget {
  final File image;

  const   Filtro({Key? key, required this.image}) : super(key: key);

  @override
  _FiltroScreenState createState() => _FiltroScreenState();
}

class _FiltroScreenState extends State<Filtro> {
  String _selectedFilter = 'Original';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplicar Filtros'),
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
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: _selectedFilter == filterName ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter, size: 40), // Un ícono representativo
            Text(filterName),
          ],
        ),
      ),
    );
  }
}
