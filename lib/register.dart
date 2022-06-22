// ignore_for_file: non_constant_identifier_names, prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new

import 'package:flutter/material.dart';
import 'package:jangandibuang/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:passwordfield/passwordfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'globals.dart' as globals;

class Register extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController username  = new TextEditingController();
  TextEditingController nama      = new TextEditingController();
  TextEditingController email     = new TextEditingController();
  TextEditingController noHP      = new TextEditingController();
  TextEditingController pwd       = new TextEditingController();
  TextEditingController cpwd      = new TextEditingController();
  String tipeuser = "Pembeli";
  bool _isObscure = true;
  bool _isObscure2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Register"),
      ),
      body:ListView(
        children:<Widget>[
          Form(
            key:_formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15.0,),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0,right:25.0),
                    child:TextFormField(
                            controller: username,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Username belum terisi';
                              }
                              else if(value.length>50){
                                return 'Username maks. 50 karakter';
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
                                Icons.person_outline_rounded,
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
                              hintText: "Username",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'Username',
                              labelStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 7.0,),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0,right:25.0),
                    child:TextFormField(
                            controller: nama,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama belum terisi';
                              }
                              else if(value.length>50){
                                return 'Nama maks. 50 karakter';
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
                                Icons.person_outline_rounded,
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
                              hintText: "Nama",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'Nama',
                              labelStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 7.0,),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0,right:25.0),
                    child:TextFormField(
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email belum terisi';
                              }
                              else if(value.length>50){
                                return 'Email maks. 50 karakter';
                              }
                              else if(!(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value))){
                                return 'Inputan tidak memenuhi format email';
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
                                Icons.email_outlined,
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
                              hintText: "Email",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 7.0,),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0,right:25.0),
                    child:TextFormField(
                            controller: noHP,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'No. HP belum terisi';
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
                                Icons.phone_android_outlined,
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
                              hintText: "No. HP",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'No. HP',
                              labelStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 7.0,),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0,right:25.0),
                    child: Container(
                              padding:  EdgeInsets.only(left:25.0,right:25.0),
                              decoration: BoxDecoration(
                                border: Border.all(color:Colors.grey,width:1),
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: DropdownButton<String>(
                                      hint:Text("Pilih tipe user"),
                                      isExpanded: true,
                                      value:tipeuser,
                                      onChanged: (value){
                                        setState(() {
                                          tipeuser=value;
                                        });
                                      },
                                      items:<String>['Pembeli','Penyedia Makanan'].map((String value) {
                                        return new DropdownMenuItem<String>(
                                          value: value,
                                          child: new Text(value)
                                        );
                                      }).toList()
                                    ),
                            ),
                  ),
                  SizedBox(height:7.0),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0,right:25.0),
                    child:TextFormField(
                            controller: pwd,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password belum terisi';
                              }
                              else if(!(value.contains(RegExp(r'[a-z]')))){
                                return 'Password belum mengandung huruf kecil';
                              }
                              else if(!(value.contains(RegExp(r'[A-Z]')))){
                                return 'Password belum mengandung huruf besar';
                              }
                              else if(!(value.contains(RegExp(r'[0-9]')))){
                                return 'Password minimal mengandung 1 angka';
                              }
                              return null;
                            },
                            obscureText: _isObscure,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              focusColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscure ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
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
                              hintText: "Password",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 7.0,),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0,right:25.0),
                    child:TextFormField(
                            controller: cpwd,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Konfirmasi Password belum terisi';
                              }
                              else if(!(value.contains(RegExp(r'[a-z]')))){
                                return 'Konfirmasi Password belum mengandung huruf kecil';
                              }
                              else if(!(value.contains(RegExp(r'[A-Z]')))){
                                return 'Konfirmasi Password belum mengandung huruf besar';
                              }
                              else if(!(value.contains(RegExp(r'[0-9]')))){
                                return 'Konfirmasi Password minimal mengandung 1 angka';
                              }
                              return null;
                            },
                            obscureText: _isObscure2,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              focusColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscure2 ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscure2 = !_isObscure2;
                                  });
                                },
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
                              hintText: "Konfirmasi Password",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'Konfirmasi Password',
                              labelStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding : EdgeInsets.only(top:7.0,left:25.0,right:25.0),
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
                                  // If the form is valid, display a snackbar. In the real world,
                                  // you'd often call a server or save the information in a database.
                                  /*ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Processing Data')),
                                  );*/
                                  register();
                                }
                              },
                              child: const Text('Register'),
                            ),
                          ),
                      ]
                    )
                  ),
                  Padding(
                    padding : EdgeInsets.only(top:7.0,left:25.0,right:25.0),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children:[
                          // ignore: prefer_const_constructors
                          Expanded(
                            flex:1,
                            child: Text('atau',textAlign: TextAlign.center)
                          ),
                      ]
                    )
                  ),
                  Padding(
                    padding : EdgeInsets.only(top:7.0,left:25.0,right:25.0),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children:[
                          Expanded(
                            flex:1,
                            child: ElevatedButton(
                              onPressed: () {
                                  moveLogin();
                              },
                              child: const Text('Login'),
                            ),
                          ),
                      ]
                    )
                  ),
                ],
              ),
          )
        ]
      )
      
    );
  }

  Future<String> RegisterActor(username,nama,email,noHP,tipeUser,password) async{
    var url = Uri.parse(globals.ipnumber+'registerActor');
    await http
            .post(url, body: {'username': username, 'nama': nama,'email': email, 'noHP':noHP,'tipeUser':tipeUser,'password':password})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status!="Sukses"){
                buatToast(status);
              }
              else{
                kosongkanForm();
                if(tipeUser=="Penyedia Makanan"){
                  globals.buatPushNotifAdmin("Penyedia Makanan Baru Mendaftar", "Cek Profil dan Konfirmasi");
                  print("masuk siniii");
                }
                buatToast("Register Sukses");
                kirimEmailVerifikasi(username);
              }
              //print(status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> kirimEmailVerifikasi(username) async{
    var url = Uri.parse(globals.ipnumber+'kirimEmailVerifikasi');
    await http
            .post(url, body: {'username': username})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              print("Status"+status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  void buatToast(message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
  }
  void register() {
    //cek confirm dan password harus sama
    if(pwd.text!=cpwd.text){
      buatToast('Password dan Confirm tidak sama');
    }
    else{
      RegisterActor(username.text,nama.text,email.text,noHP.text,tipeuser,pwd.text);
    }
  }

  void kosongkanForm() {
    username.text="";
    nama.text="";
    email.text="";
    noHP.text="";
    pwd.text="";
    cpwd.text="";
  }

  void moveLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }
}
