import 'package:flutter/material.dart';
import 'addItemDailyWaste.dart';
import 'addPaketDailyWaste.dart';

class AddDailyWaste extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AddDailyWaste> {
  final formKey = GlobalKey<FormState>();

  int _selectedIndex = 0;
  final bottomBar = [
    AddItemDailyWaste(),
    AddPaketDailyWaste(),
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
              icon: Icon(Icons.restaurant_menu), title: Text('Per Item')),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2), title: Text('Paket')),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onTapItem,
      ),
    );
  }
}