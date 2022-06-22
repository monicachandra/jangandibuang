import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:jangandibuang/listKategori.dart';
import 'package:jangandibuang/settingAdmin.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PengaturanAdmin extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<PengaturanAdmin> {
  final _formKey = GlobalKey<FormState>();
  List<String> keterangan = new List.empty(growable: true);
  List<String> imageAdd = new List.empty(growable: true);
  final List<Color> warna = <Color>[Colors.amber.shade200, Colors.lightGreen.shade200];

  @override
  void initState() {
    super.initState();
    keterangan.add("Pengaturan Global");keterangan.add("Kategori Makanan");
    imageAdd.add("pengaturan.png");imageAdd.add("kategorimakanan.png");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Pengaturan"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: 
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex:1,
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingAdmin()
                        ) 
                      );
                    },
                    child:Container(
                            height: 200,
                            decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color:warna[0],
                                        ),
                            child:Padding(
                              padding: EdgeInsets.all(20.0),
                              child:Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child:Image.asset('assets/'+imageAdd[0],
                                                          height:100,
                                                          width:150),
                                    ),
                                    SizedBox(height: 25.0,),
                                    Center(
                                      child: Text(keterangan[0],style:TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                                    ),
                                    SizedBox(height: 5.0,),
                                    Center(
                                      child: Text("Pengaturan untuk Mengubah Application Fee"),
                                    ),
                                    Center(
                                      child: Text("dan Limit Makanan yang Ditampilkan"),
                                    ),
                                  ],
                              )
                            )
                          ),
                  )
                ),
                SizedBox(height: 15.0,),
                Expanded(
                  flex:1,
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListKategori()
                        ) 
                      );
                    },
                    child:Container(
                            height: 200,
                            decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color:warna[1],
                                        ),
                            child:Padding(
                              padding: EdgeInsets.all(20.0),
                              child:Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child:Image.asset('assets/'+imageAdd[1],
                                                          height:100,
                                                          width:150),
                                    ),
                                    SizedBox(height: 25.0,),
                                    Center(
                                      child: Text(keterangan[1],style:TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                                    ),
                                    SizedBox(height: 5.0,),
                                    Center(
                                      child: Text("Pengaturan untuk Mengatur Kategori"),
                                    ),
                                    Center(
                                      child: Text("Makanan yang Dijual"),
                                    ),
                                  ],
                              )
                            )
                          ),
                  )
                ),
              ],
            )
      )
    );
  }
}