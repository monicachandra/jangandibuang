// ignore_for_file: file_names, use_key_in_widget_constructors, unused_field, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
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
import 'package:intl/intl.dart';


class StackKonfirmasiAdmin extends StatefulWidget {
  final String username;

  StackKonfirmasiAdmin(
    {
      @required this.username
    }
  ):super();

  @override
  _MyHomePageState createState() => _MyHomePageState(this.username);
}

class _MyHomePageState extends State<StackKonfirmasiAdmin> {
  String username="";
  String nama="Memuat...";
  String email="Memuat...";
  String noHP="Memuat...";
  String alamat="Memuat...";
  String kodepos="Memuat...";
  String logoActor = "default.jpg";
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  double ongkir = 0.0;

  @override
  void initState() {
    super.initState();
    getDetailVendor(this.username); 
  }


  _MyHomePageState(this.username){
    print("usernameku adl "+this.username);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Jangan Dibuang"),
      ),
      body:
        ListView(
          children: <Widget>[
            Container(
              height: 200,
              color: globals.customLightBlue,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      CircleAvatar(
                        minRadius: 55,
                        backgroundColor: globals.customDarkBlue,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(globals.imgAdd+this.logoActor),
                          minRadius: 50,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    this.username,
                    style: TextStyle(fontSize: 22.0, fontWeight:FontWeight.bold),
                  ),
                  Text(
                    this.nama,
                    style: TextStyle(fontSize: 17.0, color: globals.customGrey,fontWeight:FontWeight.bold)
                  )
                ],
              ),
            ),
            Container (
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
              ),
              child:ListTile(
                title: Text(
                  "Email",
                  style: TextStyle(color: globals.customDarkBlue, fontSize: 12.0,fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  this.email,
                  style: TextStyle(fontSize: 18.0,color:Colors.black),
                ),
              ),
            ),
            ListTile(
              title: Text(
                "No. HP",
                style: TextStyle(color: globals.customDarkBlue, fontSize: 12.0,fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                this.noHP,
                style: TextStyle(fontSize: 18.0,color:Colors.black),
              ),
              tileColor:Colors.white
            ),
            ListTile(
              title: Text(
                "Alamat",
                style: TextStyle(color: globals.customDarkBlue, fontSize: 12.0,fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                this.alamat,
                style: TextStyle(fontSize: 18.0,color:Colors.black),
              ),
              tileColor:Colors.white
            ),
            ListTile(
              title: Text(
                "Kode Pos",
                style: TextStyle(color: globals.customDarkBlue, fontSize: 12.0,fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                this.kodepos,
                style: TextStyle(fontSize: 18.0,color:Colors.black),
              ),
              tileColor: Colors.white
            ),
            ListTile(
              title: Text(
                "Ongkos Kirim / km",
                style: TextStyle(color: globals.customDarkBlue, fontSize: 12.0,fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Rp "+myFormat.format(this.ongkir).toString(),style:TextStyle(fontSize: 18.0,color:Colors.black)),
              tileColor: Colors.white
            ),
            Padding(
              padding : EdgeInsets.only(top:20.0,left:25.0,right:25.0),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children:[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showAlert(context,this.username);
                        },
                        child: const Text('Konfirmasi'),
                      ),
                    ),
                ]
              )
            ),
          ],
      ),
      
    );
  }

  Future<String> getDetailVendor(String username) async{
    var url = Uri.parse(globals.ipnumber+'getDetailVendor');
    await http
            .post(url, body: {'username': username})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                this.nama  = data['nama'];
                this.email = data['email'];
                this.noHP  = data['noHP'];
                this.logoActor = data['logo'];
                this.ongkir = data['ongkir'].toDouble();
                
                var almt  = result['alamat'][0];
                this.alamat = almt['alamat'];
                this.kodepos= almt['kodePos'];


                setState((){});
                print(data);
                print(almt);

              }
              print(status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> konfirmasi(String username) async{
    var url = Uri.parse(globals.ipnumber+'konfirmasiVendor');
    await http
            .post(url, body: {'username': username})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                globals.buatPushNotif(username,"Verifikasi Akun Berhasil","Selamat, akun Anda telah terverifikasi. Yuk, mulai berjualan!");
                print("sudah update");
                Navigator.pop(context);
              }
              print(status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
  
  showAlert(BuildContext context,String username) {
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Konfirmasi'),
        content: Text("Anda yakin mengkonfirmasi Vendor "+username+" ?"),
        actions: <Widget>[
          FlatButton(
            child: Text("Ya"),
            onPressed: () {
              //Put your code here which you want to execute on Yes button click.
              konfirmasi(username);
              Navigator.of(context).pop();
            },
          ),

           FlatButton(
            child: Text("Tidak"),
            onPressed: () {
              //Put your code here which you want to execute on No button click.
              Navigator.of(context).pop();
            },
          ),
        ],
      );
     },
    );
  }
}
