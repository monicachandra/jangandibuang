import 'package:flutter/material.dart';
import 'package:jangandibuang/pengaturanAdmin.dart';
import 'konfirmasiAdmin.dart';
import 'penerimaBantuanAdmin.dart';
import 'forumAdmin.dart';
import 'profilAdmin.dart';

class Admin extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Admin> {
  final formKey = GlobalKey<FormState>();

  int _selectedIndex = 0;
  final bottomBar = [
    KonfirmasiAdmin(),
    PenerimaBantuanAdmin(),
    ForumAdmin(),
    PengaturanAdmin(),
    ProfilAdmin()
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
              icon: Icon(Icons.store), title: Text('Konfirmasi')),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), title: Text('Penerima Bantuan',style: TextStyle(fontSize: 12.0))),
          BottomNavigationBarItem(
              icon: Icon(Icons.forum), title: Text('Forum')),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), title: Text('Pengaturan')),
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