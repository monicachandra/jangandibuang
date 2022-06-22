import 'package:flutter/material.dart';
import 'addInfoItemVendor.dart';
import 'addFotoItemVendor.dart';
//gapake lagi

class AddBarangVendor extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AddBarangVendor> {
  final formKey = GlobalKey<FormState>();

  int _selectedIndex = 0;
  final bottomBar = [
    AddInfoItemVendor(),
    AddFotoItemVendor(),
  ];

  void _onTapItem(int index){
    setState(() {
     _selectedIndex = index; 
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bottomBar.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.info), title: Text('Info')),
          BottomNavigationBarItem(
              icon: Icon(Icons.photo), title: Text('Foto')),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onTapItem,
      ),
    );
  }
}