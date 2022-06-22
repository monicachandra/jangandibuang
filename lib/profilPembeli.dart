// ignore_for_file: file_names, use_key_in_widget_constructors, unused_field, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:jangandibuang/listOfChat.dart';
import 'package:jangandibuang/listLaporanPembeli.dart';
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
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ProfilPembeli extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ProfilPembeli> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  SharedPreferences prefs;
  String logoActor = "default.jpg";
  String nama="Memuat...";
  String email="Memuat...";
  String noHP="Memuat...";
  double saldo=0;
  XFile _image;

  TextEditingController pwd      = new TextEditingController();
  TextEditingController pwdBaru  = new TextEditingController();
  TextEditingController cpwdBaru = new TextEditingController();

  TextEditingController namaCtrl = new TextEditingController();
  TextEditingController noHPCtrl = new TextEditingController();

  bool _isObscure = true;
  bool _isObscure2 = true;
  bool _isObscure3 = true;

  ImagePicker picker = ImagePicker();

  final List<Tab> myTabs = <Tab>[
    new Tab(text: 'Profil'),
    new Tab(text: 'Privasi'),
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: myTabs.length);

    _tabController.animateTo(0);
    getDetailVendor(globals.loginuser);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget viewtab0(BuildContext myContext) {
    return ListView(
        children: <Widget>[
          Container(
            height: 175,
            decoration: BoxDecoration(
              color:globals.customLightBlue
            ),
            child: Padding(
                      padding: EdgeInsets.only(left: 15.0,right:15.0,top:15.0,bottom:15.0),
                      child:Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child:CircleAvatar(
                                          minRadius: 60,
                                          backgroundColor: Colors.blue.shade700,
                                          child: GestureDetector(
                                            onTap: (){
                                              getImageFromGallery();
                                            },
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(globals.imgAdd+this.logoActor),
                                              minRadius: 50,
                                            ),
                                          ),
                                        ),
                                ),
                                SizedBox(width: 20.0,),
                                Expanded(
                                  flex: 5,
                                  child:Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              globals.loginuser,
                                              style: TextStyle(fontSize: 22.0,fontWeight:FontWeight.bold),
                                            ),
                                            Text(
                                              this.email,
                                              style: TextStyle(fontSize: 14.0),
                                            ),
                                            Text(
                                              "Saldo : Rp "+myFormat.format(this.saldo).toString(),
                                              style: TextStyle(fontSize: 14.0),
                                            ),
                                            Row(
                                              mainAxisAlignment:MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex:1,
                                                  child:ElevatedButton(
                                                          onPressed: () {
                                                            if(globals.isVerified=="0"){
                                                              globals.buatToast("Verifikasi E-mail terlebih dahulu");
                                                            }
                                                            else{
                                                              Navigator.pushNamed(myContext, "/topUp").then((value) => refreshView());
                                                            }
                                                          },
                                                          child: const Text('Top Up',style: TextStyle(fontWeight: FontWeight.w600),),
                                                        ),
                                                ),
                                                SizedBox(width:5.0),
                                                Expanded(
                                                  flex:1,
                                                  child:ElevatedButton(
                                                          onPressed: () {
                                                            if(globals.isVerified=="0"){
                                                              globals.buatToast("Verifikasi E-mail terlebih dahulu");
                                                            }
                                                            else{
                                                              Navigator.pushNamed(myContext, "/daftarAlamatPembeli").then((value) => refreshView());
                                                            }
                                                          },
                                                          child: const Text('Alamat',style: TextStyle(fontWeight: FontWeight.w600),),
                                                        ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                ),
                              ],
                            ),
                    )
          ),
          Form(
            key:formKey2,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 25.0),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0,right:25.0),
                    child:TextFormField(
                            controller: namaCtrl,
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
                            controller: noHPCtrl,
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
                  SizedBox(height:7.0),
                  Padding(
                    padding : EdgeInsets.only(top:5.0,left:25.0,right:25.0),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children:[
                          Expanded(
                            flex:1,
                            child: ElevatedButton(
                              onPressed: () {
                                // Validate returns true if the form is valid, or false otherwise.
                                if (formKey2.currentState.validate()) {
                                  // If the form is valid, display a snackbar. In the real world,
                                  // you'd often call a server or save the information in a database.
                                  /*ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Processing Data')),
                                  );*/
                                  if(globals.isVerified=="0"){
                                    globals.buatToast("Verifikasi E-mail terlebih dahulu");
                                  }
                                  else{
                                    editProfil();
                                  }
                                }
                              },
                              child: const Text('Edit Profil',style: TextStyle(fontWeight: FontWeight.w600),),
                            ),
                          ),
                      ]
                    )
                  ),
                ],
              ),
            )
        ],
    );
  }
  Widget viewtab1() {
    return ListView(
        children:<Widget>[ 
          Form(
          key:_formKey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.0,),
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
      );
  }
  Future getImageFromGallery() async{
    var image = await picker.pickImage(source:ImageSource.gallery);
    setState((){
      _image = image;
    });
    if(_image!=null){
      String base64Image = "";
      String namaFile = "";
      base64Image = base64Encode(File(_image.path).readAsBytesSync());
      namaFile = _image.path.split("/").last;
      var url = Uri.parse(globals.ipnumber+'gantiProfileImage');
      await http
                .post(url,
                      body:{'username':globals.loginuser,'m_image':base64Image,'m_filename':namaFile})
                .then((res){
                  var result = json.decode(res.body);
                  var status = result['status'];
                  if(status=="Sukses"){
                    globals.buatToast("Foto Profil Terupdate");
                    getDetailVendor(globals.loginuser);
                    print(status);
                  }
                })
                .catchError((err){
                  print(err);
                });
      return "Sukses";
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Profil Pembeli"),
        bottom: new TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
        actions: <Widget>[
          IconButton(
            icon:Icon(Icons.chat),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListOfChat()
                ) 
              );
            },
          ),
          IconButton(
            icon:Icon(Icons.event_note),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListLaporanPembeli()
                ) 
              );
            },
          ),
          PopupMenuButton(
                onSelected: (value) {
                  logoutApp(context);
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
      body:new TabBarView(
        controller: _tabController,
        children: [viewtab0(context), viewtab1()],
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
                this.namaCtrl.text=this.nama;
                this.email = data['email'];
                this.noHP  = data['noHP'];
                this.noHPCtrl.text=this.noHP;
                this.logoActor = data['logo'];
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
  Future<String> editProfil() async{
    var url = Uri.parse(globals.ipnumber+'gantiProfilPembeli');
    await http
            .post(url, body: {'username': globals.loginuser, 'nama':namaCtrl.text, 'noHP':noHPCtrl.text})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status!="Sukses"){
                globals.buatToast(status);
              }
              else{
                globals.buatToast("Sukses Edit Profil");
                getDetailVendor(globals.loginuser);
              }
              print(status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  refreshView(){
    getDetailVendor(globals.loginuser);
  }

  void logoutApp(BuildContext context) async {
    prefs= await SharedPreferences.getInstance();
    prefs.remove('loginuser');
    prefs.remove('loginjenis');
    prefs.remove('vendorTerverifikasi');
    prefs.remove('isVerified');
    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }
}