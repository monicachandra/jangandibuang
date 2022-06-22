// ignore_for_file: file_names, use_key_in_widget_constructors, unused_field, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:jangandibuang/ClassKategoris.dart';
import 'package:jangandibuang/ShowHtmlPage.dart';
import 'package:jangandibuang/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jangandibuang/register.dart';
import 'package:passwordfield/passwordfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class ListKategori extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ListKategori> with SingleTickerProviderStateMixin{
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  List<ClassKategoris> arrKategoriAktif = new List.empty(growable:true);
  List<ClassKategoris> arrKategoriNonAktif = new List.empty(growable:true);
  TextEditingController kat       = new TextEditingController();
  final List<Tab> myTabs = <Tab>[
    new Tab(text: 'Aktif'),
    new Tab(text: 'NonAktif'),
  ];
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    getKategoriAktif();
    getKategoriNonAktif();
    _tabController = new TabController(vsync: this, length: myTabs.length);
    _tabController.animateTo(0);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        int indexTab = _tabController.index;
        getKategoriAktif();
        getKategoriNonAktif();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget viewtab0(){
    return Form(
        key:_formKey,
        child: Padding(
          padding:EdgeInsets.all(10.0),
          child: ListView.builder(
                  itemCount: arrKategoriAktif.length==0 ? 1 : arrKategoriAktif.length,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemBuilder: (context,index){
                    if(arrKategoriAktif.length==0){
                      return Text("no data");
                    }
                    else{
                      return GestureDetector(
                        onTap:(){
                          //tap
                        },
                        child:Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                shadowColor: Colors.black,
                                color: globals.customLightBlue,
                                child: Padding(
                                        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0,bottom: 15.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children:[
                                            Expanded(
                                              flex:1,
                                              child:Text(arrKategoriAktif[index].nama)
                                            ),
                                            Expanded(
                                              flex:1,
                                              child:Container(
                                                    alignment: Alignment.topRight,
                                                    child:PopupMenuButton(
                                                          onSelected: (value) {
                                                            if(value==1){
                                                              setState(() {
                                                                kat.text=arrKategoriAktif[index].nama;
                                                              });
                                                              openEdit(context,index);
                                                            }
                                                            else{
                                                              nonAktif(index);
                                                            }
                                                          },
                                                          itemBuilder: (context) => [
                                                            PopupMenuItem(
                                                              child: Text("Sunting"),
                                                              value: 1,
                                                            ),
                                                            PopupMenuItem(
                                                              child: Text("NonAktifkan"),
                                                              value: 2,
                                                            ),
                                                          ],
                                                          child: Icon(Icons.more_vert,color: Colors.black,),
                                                      )
                                                  )
                                            ),
                                          ]
                                        )
                                        
                                )
                              )
                      );
                    }
                  }
                ),
        ),
        );
  }

  Widget viewtab1(){
    return Form(
        key:_formKey4,
        child: Padding(
          padding:EdgeInsets.all(10.0),
          child: ListView.builder(
                  itemCount: arrKategoriNonAktif.length==0 ? 1 : arrKategoriNonAktif.length,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemBuilder: (context,index){
                    if(arrKategoriNonAktif.length==0){
                      return Text("no data");
                    }
                    else{
                      return GestureDetector(
                        onTap:(){
                          //tap
                        },
                        child:Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                shadowColor: Colors.black,
                                color: globals.customLightBlue,
                                child: Padding(
                                        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0,bottom: 15.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children:[
                                            Expanded(
                                              flex:1,
                                              child:Text(arrKategoriNonAktif[index].nama)
                                            ),
                                            Expanded(
                                              flex:1,
                                              child:Container(
                                                    alignment: Alignment.topRight,
                                                    child:PopupMenuButton(
                                                          onSelected: (value) {
                                                            if(value==1){
                                                              aktifKan(index);
                                                            }
                                                          },
                                                          itemBuilder: (context) => [
                                                            PopupMenuItem(
                                                              child: Text("Aktifkan"),
                                                              value: 1,
                                                            ),
                                                          ],
                                                          child: Icon(Icons.more_vert,color: Colors.black,),
                                                      )
                                                  )
                                            ),
                                          ]
                                        )
                                        
                                )
                              )
                      );
                    }
                  }
                ),
        ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Kategori Makanan"),
        bottom: new TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body:new TabBarView(
        controller: _tabController,
        children: [viewtab0(), viewtab1()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            kat.text="";
          });
          openTambah(context);
        },
        child: const Icon(Icons.add),
      )
    );
  }

  openTambah(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)), //this right here
            child: 
            Form(
              key:_formKey2,
              child:
              Container(
                height: 175,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5.0),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:[
                                    Expanded(
                                      flex:1,
                                      child:TextFormField(
                                                controller: kat,
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Kategori belum terisi';
                                                  }
                                                  else if(value.length>50){
                                                    return 'Kategori maks. 50 karaketer';
                                                  }
                                                  return null;
                                                },
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                decoration: InputDecoration(
                                                  focusColor: Colors.white,
                                                  prefixIcon: Icon(
                                                    Icons.add,
                                                    color: Colors.grey,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(color: Colors.blue, width: 1.0),
                                                    borderRadius: BorderRadius.circular(10.0),
                                                  ),
                                                  fillColor: Colors.grey,
                                                  hintText: "Nama Kategori",
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                    fontFamily: "verdana_regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  labelText: 'Nama Kategori',
                                                  labelStyle: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                    fontFamily: "verdana_regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                    )
                                  ]
                                ),
                                SizedBox(height:10.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:[
                                    Expanded(
                                      flex:1,
                                      child:ElevatedButton(
                                              onPressed: () {
                                                // Validate returns true if the form is valid, or false otherwise.
                                                if (_formKey2.currentState.validate()) {
                                                  // If the form is valid, display a snackbar. In the real world,
                                                  // you'd often call a server or save the information in a database.
                                                  /*ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Processing Data')),
                                                  );*/
                                                  tambahKategori(context).then((value) => refreshView());
                                                }
                                              },
                                              child: const Text('Tambah Kategori'),
                                            ),
                                    )
                                  ]
                                )
                            ],
                        )
                ),
              ),
            )
          );
        });
      }
    );
  }

  openEdit(BuildContext context,int idx){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)), //this right here
            child: 
            Form(
              key:_formKey3,
              child:
              Container(
                height: 175,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5.0),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:[
                                    Expanded(
                                      flex:1,
                                      child:TextFormField(
                                                controller: kat,
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Kategori belum terisi';
                                                  }
                                                  else if(value.length>50){
                                                    return 'Kategori maks. 50 karaketer';
                                                  }
                                                  return null;
                                                },
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                decoration: InputDecoration(
                                                  focusColor: Colors.white,
                                                  prefixIcon: Icon(
                                                    Icons.add,
                                                    color: Colors.grey,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(color: Colors.blue, width: 1.0),
                                                    borderRadius: BorderRadius.circular(10.0),
                                                  ),
                                                  fillColor: Colors.grey,
                                                  hintText: "Nama Kategori",
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                    fontFamily: "verdana_regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  labelText: 'Nama Kategori',
                                                  labelStyle: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                    fontFamily: "verdana_regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                    )
                                  ]
                                ),
                                SizedBox(height:10.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:[
                                    Expanded(
                                      flex:1,
                                      child:ElevatedButton(
                                              onPressed: () {
                                                // Validate returns true if the form is valid, or false otherwise.
                                                if (_formKey3.currentState.validate()) {
                                                  // If the form is valid, display a snackbar. In the real world,
                                                  // you'd often call a server or save the information in a database.
                                                  /*ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Processing Data')),
                                                  );*/
                                                  editKategori(context,idx).then((value) => refreshView());
                                                }
                                              },
                                              child: const Text('Sunting Kategori'),
                                            ),
                                    )
                                  ]
                                )
                            ],
                        )
                ),
              ),
            )
          );
        });
      }
    );
  }
  
  Future<String> getKategoriAktif() async{
    setState(() {
      arrKategoriAktif.clear();
    });
    var url = Uri.parse(globals.ipnumber+'getAllKategori');
    await http
            .post(url,body: {'status': '1'})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                for (int i = 0; i < data.length; i++) {
                  ClassKategoris databaru = ClassKategoris(data[i]['idKategori'], data[i]['namaKategori']);
                  setState(() {
                    arrKategoriAktif.add(databaru);
                  }); 
                }
              }
              print(status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
  Future<String> getKategoriNonAktif() async{
    setState(() {
      arrKategoriNonAktif.clear();
    });
    var url = Uri.parse(globals.ipnumber+'getAllKategori');
    await http
            .post(url,body: {'status': '0'})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                for (int i = 0; i < data.length; i++) {
                  ClassKategoris databaru = ClassKategoris(data[i]['idKategori'], data[i]['namaKategori']);
                  setState(() {
                    arrKategoriNonAktif.add(databaru);
                  }); 
                }
              }
              print(status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> tambahKategori(BuildContext context) async{
    var url = Uri.parse(globals.ipnumber+'tambahKategori');
    await http
            .post(url, body: {'nama': kat.text})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                kat.text="";
                globals.buatToast("Sukses Menambahkan Kategori");
                Navigator.pop(context);
              }
              //print(status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> editKategori(BuildContext context,int index) async{
    var url = Uri.parse(globals.ipnumber+'editKategori');
    await http
            .post(url, body: {'id':arrKategoriAktif[index].id.toString(),'nama': kat.text})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                kat.text="";
                globals.buatToast("Sukses Mengubah Nama Kategori");
                Navigator.pop(context);
              }
              //print(status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> nonAktif(int index) async{
    var url = Uri.parse(globals.ipnumber+'nonAktifKategori');
    await http
            .post(url, body: {'id':arrKategoriAktif[index].id.toString()})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                refreshView();
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> aktifKan(int index) async{
    var url = Uri.parse(globals.ipnumber+'aktifKategori');
    await http
            .post(url, body: {'id':arrKategoriNonAktif[index].id.toString()})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                refreshView();
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  refreshView(){
    getKategoriAktif();
    getKategoriNonAktif();
  }
}