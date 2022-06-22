import 'package:flutter/material.dart';
import 'package:jangandibuang/forumVendorPembeli.dart';
import 'profilVendor.dart';
import 'listOrderanVendor.dart';
import 'listBarangVendor.dart';
import 'listDailyWaste.dart';

class Vendor extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Vendor> {
  final formKey = GlobalKey<FormState>();

  int _selectedIndex = 0;
  final bottomBar = [
    ListBarangVendor(),
    ListDailyWaste(),
    ListOrderanVendor(),
    ForumVendorPembeli(),
    ProfilVendor(),
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
              icon: Icon(Icons.store), title: Text('Menu')),
          BottomNavigationBarItem(
              icon: Icon(Icons.food_bank), title: Text('Daily Waste',style: TextStyle(fontSize: 12.0))),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), title: Text('Orderan')),
          BottomNavigationBarItem(
              icon: Icon(Icons.forum), title: Text('Forum')),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), title: Text('Profil')),
          
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onTapItem,
      ),
    );
  }
}