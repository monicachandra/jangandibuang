import 'package:flutter/material.dart';
import 'package:jangandibuang/forumVendorPembeli.dart';
import 'package:jangandibuang/penerimaBantuanUser.dart';
import 'historyOrderPembeli.dart';
import 'profilPembeli.dart';
import 'listDailyWastePembeli.dart';
import 'globals.dart' as globals;

class Pembeli extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Pembeli> {
  final formKey = GlobalKey<FormState>();

  //int _selectedIndex = 0;
  final bottomBar = [
    ListDailyWastePembeli(),
    PenerimaBantuanUser(),
    HistoryOrderPembeli(),
    ForumVendorPembeli(),
    ProfilPembeli()
  ];

  void _onTapItem(int index){
    setState(() {
      globals.selectedIndexBottomNavBarPembeli=index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bottomBar.elementAt(globals.selectedIndexBottomNavBarPembeli),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.store), title: Text('Menu')),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), title: Text('Penerima Bantuan',style: TextStyle(fontSize: 12.0))),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), title: Text('Daftar Order', style:TextStyle(fontSize: 12.0))),
          BottomNavigationBarItem(
              icon: Icon(Icons.forum), title: Text('Forum')),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), title: Text('Profil')),
          
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: globals.selectedIndexBottomNavBarPembeli,
        onTap: _onTapItem,
      ),
    );
  }
}