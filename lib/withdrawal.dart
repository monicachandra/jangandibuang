// ignore_for_file: file_names, use_key_in_widget_constructors, unused_field, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
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

class Withdrawal extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Withdrawal> {
  final _formKey = GlobalKey<FormState>();
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  double saldo=0.0;
  TextEditingController nominal      = new TextEditingController();
  TextEditingController namaRek      = new TextEditingController();
  TextEditingController noRek       = new TextEditingController();
  String namaBank = "BCA"; 

  List<Map> daftarBank = [
    {
      "gambar":"assets/bankbca.png",
      "nama":"BCA"
    },
    {
      "gambar":"assets/bankmandiri.png",
      "nama":"Mandiri"
    },
    {
      "gambar":"assets/bankbni.png",
      "nama":"BNI"
    },
    {
      "gambar":"assets/bankbri.png",
      "nama":"BRI"
    }
  ];
  @override
  void initState() {
    super.initState();
    getSaldo(globals.loginuser);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Withdrawal Saldo"),
      ),
      body:Form(
        key:_formKey,
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 25.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[
                    Text("Saldo : Rp "+myFormat.format(this.saldo).toString(),style:TextStyle(fontWeight: FontWeight.bold,fontSize:15.0))
                  ]
                ),
                SizedBox(height: 15.0,),
                Padding(
                  padding : EdgeInsets.only(left:15.0,right:15.0),
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: nominal,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nominal Withdrawal belum terisi';
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
                            Icons.money,
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
                          hintText: "Nominal Withdrawal",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontFamily: "verdana_regular",
                            fontWeight: FontWeight.w400,
                          ),
                          labelText: 'Nominal Withdrawal',
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontFamily: "verdana_regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  )
                ),
                SizedBox(height: 7.0,),
                Padding(
                  padding : EdgeInsets.only(left:15.0,right:15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1,color:Colors.grey),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding:EdgeInsets.all(10.0),
                      child:Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child:DropdownButton<String>(
                                          hint:Text("Pilih Bank"),
                                          isExpanded: true,
                                          value:namaBank,
                                          onChanged: (value){
                                            setState(() {
                                              namaBank=value;
                                            });
                                          },
                                          items:daftarBank.map((Map map) {
                                            return new DropdownMenuItem<String>(
                                              value:map["nama"].toString(),
                                              child: Row(
                                                children: <Widget>[
                                                  Image.asset(map["gambar"],width: 25,),
                                                  Container(
                                                    margin: EdgeInsets.only(left:10),
                                                    child: Text(map["nama"]),
                                                  )
                                                ],
                                              ),
                                            );
                                          }).toList()
                                        ),
                                )
                              ],
                            )
                    )
                  )
                ),
                SizedBox(height:7.0),
                Padding(
                  padding : EdgeInsets.only(left:15.0,right:15.0),
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: noRek,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nomor Rekening belum terisi';
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
                            Icons.credit_card,
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
                          hintText: "Nomor Rekening",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontFamily: "verdana_regular",
                            fontWeight: FontWeight.w400,
                          ),
                          labelText: 'Nomor Rekening',
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontFamily: "verdana_regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  )
                ),
                SizedBox(height:7.0),
                Padding(
                  padding : EdgeInsets.only(left:15.0,right:15.0),
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: namaRek,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'nama Rekening belum terisi';
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
                            Icons.person,
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
                          hintText: "Nama Rekening",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontFamily: "verdana_regular",
                            fontWeight: FontWeight.w400,
                          ),
                          labelText: 'Nama Rekening',
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontFamily: "verdana_regular",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  )
                ),
                SizedBox(height: 7.0,),
                Padding(
                  padding : EdgeInsets.only(top:25.0,left:25.0,right:25.0),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:[
                        Expanded(
                          flex:1,
                          child: ElevatedButton(
                            onPressed: () {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState.validate()) {
                                String pengajuan = nominal.text.toString();
                                double nominalAju = double.parse(pengajuan);
                                if(nominalAju<10000){
                                  globals.buatToast("Nominal WD minimal Rp 10.000,-");
                                }
                                else if(nominalAju<=saldo){
                                  ajukanWD(context);
                                }
                                else{
                                  globals.buatToast("Nominal WD melebihi saldo");
                                }
                              }
                            },
                            child: const Text('Withdrawal',style: TextStyle(fontWeight: FontWeight.w600),),
                          ),
                        ),
                    ]
                  )
                ),
              ],
            ),
          ],
        )
      ),
    );
  }
  Future<String> getSaldo(String username) async{
    var url = Uri.parse(globals.ipnumber+'getSaldo');
    await http
            .post(url, body: {'username': globals.loginuser})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['actor'];
                this.saldo = data['saldo'].toDouble();
                setState((){});
                print(data);
                //print(almt);
              }
              print(status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> ajukanWD(BuildContext context) async{
    var url = Uri.parse(globals.ipnumber+'ajukanWD');
    await http
            .post(url, body: {'username': globals.loginuser,'noRek':noRek.text.toString(),'nominal':nominal.text.toString(),'namaRek':namaRek.text,'namaBank':namaBank})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                Navigator.of(context).pop();
              }
              print(status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  refreshView(){
    getSaldo(globals.loginuser);
    nominal.text="";
  }
}