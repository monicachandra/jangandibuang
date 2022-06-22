// ignore_for_file: unnecessary_new

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jangandibuang/register.dart';
import 'package:passwordfield/passwordfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'globals.dart' as globals;


class Login extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController username  = new TextEditingController();
  TextEditingController pwd      = new TextEditingController();
  bool _isObscure = true;
  FirebaseFirestore _firestore;
  FirebaseMessaging _firebaseMessaging;
  String tokenKu;
  SharedPreferences prefs;

  _MyHomePageState(){
    takeFirebase();
  }

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    prefs = await SharedPreferences.getInstance();
    String loginuser = prefs.getString("loginuser") ?? "guest";
    String loginjenis= prefs.getString("loginjenis") ?? "G";
    String vendorTerverifikasi = prefs.getString("vendorTerverifikasi")??"0";
    String isVerified = prefs.getString("isVerified")??"0";
    print("isV"+isVerified);
    globals.loginuser = loginuser;
    globals.loginjenis = loginjenis;
    globals.isVerified = isVerified;

    if (loginjenis != "") {
      if(globals.loginjenis=='A'){
        pindahAdmin();
      }
      else if(globals.loginjenis=="V"){
        globals.vendorTerverifikasi=vendorTerverifikasi;
        globals.isVerified = isVerified;
        pindahVendor();
      }
      else if(globals.loginjenis=="P"){
        pindahPembeli();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Jangan Dibuang"),
      ),
      body: ListView(
        children:<Widget>[ 
          Form(
          key:_formKey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 25.0),
                Center(
                  child: Image.asset('assets/logo.PNG',
                          height:200,
                          width:200)
                ),
                SizedBox(height: 10.0),
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
                            fontSize: 15,
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
                              fontSize: 16,
                              fontFamily: "verdana_regular",
                              fontWeight: FontWeight.w400,
                            ),
                            labelText: 'Username',
                            labelStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontFamily: "verdana_regular",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                ),
                SizedBox(height: 10.0),
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
                            fontSize: 15,
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
                              fontSize: 16,
                              fontFamily: "verdana_regular",
                              fontWeight: FontWeight.w400,
                            ),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontFamily: "verdana_regular",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                ),
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
                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                /*ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Processing Data')),
                                );*/
                                login();
                              }
                            },
                            child: const Text('Login',style: TextStyle(fontWeight: FontWeight.w600),),
                          ),
                        ),
                    ]
                  )
                ),
                Padding(
                  padding : EdgeInsets.only(top:10.0,left:25.0,right:25.0),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:[
                        Expanded(
                          flex:1,
                          child: Text('atau',textAlign: TextAlign.center,style: TextStyle(fontSize: 15))
                        ),
                    ]
                  )
                ),
                Padding(
                  padding : EdgeInsets.only(top:10.0,left:25.0,right:25.0),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:[
                        Expanded(
                          flex:1,
                          child: ElevatedButton(
                            onPressed: () {
                                moveRegister();
                            },
                            child: const Text('Register',style: TextStyle(fontWeight: FontWeight.w600),),
                          ),
                        ),
                    ]
                  )
                ),
                Padding(
                  padding : EdgeInsets.only(top:10.0,left:25.0,right:25.0),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:[
                        Expanded(
                          flex:1,
                          child: ElevatedButton(
                            onPressed: () {
                                moveGuest();
                            },
                            child: const Text('Login sebagai Guest (Pembeli)',style: TextStyle(fontWeight: FontWeight.w600),),
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
  Future<String> LoginActor(username,password) async{
    var url = Uri.parse(globals.ipnumber+'loginActor');
    await http
            .post(url, body: {'username': username, 'password':password, 'tokenKu':tokenKu})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              var statusActor = result['statusActor'];
              var isVerified = result['isVerified'];
              if(status!="Sukses"){
                buatToast(status);
              }
              else{
                String jenisActor = result['jenis'].toString();
                prefs.setString('loginuser', username);
                prefs.setString('loginjenis', jenisActor);
                String isVer = isVerified.toString();
                globals.isVerified = isVer;
                prefs.setString('isVerified',isVer);
                print("isVer:"+isVer);
                kosongkanForm();
                globals.loginuser=username;
                globals.loginjenis=result['jenis'];
                buatToast("Login Sukses");
                if(globals.loginjenis=='A'){
                  pindahAdmin();
                }
                else if(globals.loginjenis=="V"){
                  globals.vendorTerverifikasi=statusActor.toString();
                  prefs.setString('vendorTerverifikasi',statusActor.toString());
                  pindahVendor();
                }
                else if(globals.loginjenis=="P"){
                  pindahPembeli();
                }
              }
              print(status);
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
  void login() {
    LoginActor(username.text,pwd.text);
  }

  void kosongkanForm() {
    username.text="";
    pwd.text="";
  }

  void moveRegister() {
    //Navigator.pushNamed(context, "/home");
    Navigator.of(context).pushNamedAndRemoveUntil('/register', (Route<dynamic> route) => false);
  }

  void moveGuest(){
    globals.loginuser='guest';
    globals.loginjenis='G';
    Navigator.of(context).pushNamedAndRemoveUntil('/dashboardGuest', (Route<dynamic> route) => false);
  }

  void pindahAdmin() {
    Navigator.of(context).pushNamedAndRemoveUntil('/admin', (Route<dynamic> route) => false);
  }

  void pindahVendor() {
    Navigator.of(context).pushNamedAndRemoveUntil('/vendor', (Route<dynamic> route) => false);
  }

  void pindahPembeli() {
    Navigator.of(context).pushNamedAndRemoveUntil('/pembeli', (Route<dynamic> route) => false);
  }

  takeFirebase() async {
    await Firebase.initializeApp();
    _firestore = FirebaseFirestore.instance;
    _firebaseMessaging = FirebaseMessaging.instance;
    firebaseCloudMessaging_Listeners();
  }

  void firebaseCloudMessaging_Listeners() {
    _firebaseMessaging.getToken().then((token) {
      print("token di home dart = " + token);
      tokenKu = token;
      FirebaseFirestore.instance
          .collection("chatting")
          .get()
          .then((QuerySnapshot snapshot) {
        snapshot.docs.forEach((f) {});
      });
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('on message $message');
    });
  }
}
