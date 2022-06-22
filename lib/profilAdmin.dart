import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/listKategori.dart';
import 'package:jangandibuang/listLaporanAdmin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ProfilAdmin extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ProfilAdmin> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController pwd      = new TextEditingController();
  TextEditingController pwdBaru  = new TextEditingController();
  TextEditingController cpwdBaru = new TextEditingController();
  SharedPreferences prefs;
  bool _isObscure = true;
  bool _isObscure2 = true;
  bool _isObscure3 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Profil Admin"),
        actions: <Widget>[
          IconButton(
            icon:Icon(Icons.event_note),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListLaporanAdmin()
                ) 
              );
            },
          ),
          PopupMenuButton(
                onSelected: (value) {
                  logoutApp();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text("Logout"),
                    value: 1,
                  ),
                ],
                child: Icon(Icons.logout,color: Colors.white,),
          )
        ],
      ),
      body: ListView(
        children:<Widget>[ 
          Form(
          key:_formKey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 25.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[
                    Text("Data Pribadi",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),)
                  ]
                ),
                SizedBox(height: 25.0),
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
                SizedBox(height: 25.0),
                Padding(
                  padding:  EdgeInsets.only(left:25.0,right:25.0),
                  child:TextFormField(
                          controller: pwdBaru,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password Baru belum terisi';
                            }
                            else if(!(value.contains(RegExp(r'[a-z]')))){
                              return 'Password Baru belum mengandung huruf kecil';
                            }
                            else if(!(value.contains(RegExp(r'[A-Z]')))){
                              return 'Password Baru belum mengandung huruf besar';
                            }
                            else if(!(value.contains(RegExp(r'[0-9]')))){
                              return 'Password Baru minimal mengandung 1 angka';
                            }
                            return null;
                          },
                          obscureText: _isObscure2,
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
                            hintText: "Password Baru",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontFamily: "verdana_regular",
                              fontWeight: FontWeight.w400,
                            ),
                            labelText: 'Password Baru',
                            labelStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontFamily: "verdana_regular",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                ),
                SizedBox(height: 25.0),
                Padding(
                  padding:  EdgeInsets.only(left:25.0,right:25.0),
                  child:TextFormField(
                          controller: cpwdBaru,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Konfirmasi Password Baru belum terisi';
                            }
                            else if(!(value.contains(RegExp(r'[a-z]')))){
                              return 'Konfirmasi Password Baru belum mengandung huruf kecil';
                            }
                            else if(!(value.contains(RegExp(r'[A-Z]')))){
                              return 'Konfirmasi Password Baru belum mengandung huruf besar';
                            }
                            else if(!(value.contains(RegExp(r'[0-9]')))){
                              return 'Konfirmasi Password Baru minimal mengandung 1 angka';
                            }
                            return null;
                          },
                          obscureText: _isObscure3,
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
                                _isObscure3 ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscure3 = !_isObscure3;
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
                            hintText: "Konfirmasi Password Baru",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontFamily: "verdana_regular",
                              fontWeight: FontWeight.w400,
                            ),
                            labelText: 'Konfirmasi Password Baru',
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
                                gantiPassword();
                              }
                            },
                            child: const Text('Ubah Password',style: TextStyle(fontWeight: FontWeight.w600),),
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
  void gantiPassword() {
    //cek confirm dan password harus sama
    if(pwdBaru.text!=cpwdBaru.text){
      globals.buatToast('Password Baru dan Konfirmasi Password Baru tidak sama');
    }
    else{
      GantiPassword(pwd.text,pwdBaru.text);
    }
  }
  Future<String> GantiPassword(pwd,pwdBaru) async{
    var url = Uri.parse(globals.ipnumber+'gantiPassword');
    await http
            .post(url, body: {'username': globals.loginuser, 'pwd':pwd, 'pwdBaru':pwdBaru})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status!="Sukses"){
                globals.buatToast(status);
              }
              else{
                globals.buatToast("Sukses Ganti Password");
                this.pwd.text="";
                this.pwdBaru.text="";
                this.cpwdBaru.text="";
              }
              print(status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  void logoutApp() async {
    prefs= await SharedPreferences.getInstance();
    prefs.remove('loginuser');
    prefs.remove('loginjenis');
    prefs.remove('vendorTerverifikasi');
    prefs.remove('isVerified');
    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }
}