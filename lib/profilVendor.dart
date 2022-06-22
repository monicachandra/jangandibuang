// ignore_for_file: file_names, use_key_in_widget_constructors, unused_field, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:jangandibuang/daftarWithdrawal.dart';
import 'package:jangandibuang/listLaporanVendor.dart';
import 'package:jangandibuang/listOfChat.dart';
import 'package:jangandibuang/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jangandibuang/register.dart';
import 'package:jangandibuang/ubahAlamat.dart';
import 'package:jangandibuang/withdrawal.dart';
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
import 'package:geolocator/geolocator.dart';

class ProfilVendor extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ProfilVendor> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  SharedPreferences prefs;
  String logoActor = "default.jpg";
  String nama="Memuat...";
  String email="Memuat...";
  String noHP="Memuat...";
  String alamat="-";
  String kodepos="-";
  String keteranganAlamat="-";
  double saldo=0;
  XFile _image;
  double longi=0.0;
  double lati=0.0;

  TextEditingController pwd      = new TextEditingController();
  TextEditingController pwdBaru  = new TextEditingController();
  TextEditingController cpwdBaru = new TextEditingController();

  TextEditingController namaCtrl = new TextEditingController();
  TextEditingController noHPCtrl = new TextEditingController();
  TextEditingController ongkirCtrl = new TextEditingController();

  bool _isObscure = true;
  bool _isObscure2 = true;
  bool _isObscure3 = true;

  ImagePicker picker = ImagePicker();

  final List<Tab> myTabs = <Tab>[
    new Tab(text: 'Profil'),
    new Tab(text: 'Privasi'),
  ];

  TabController _tabController;

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  Position position = null;

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
            height: 240,
            decoration: BoxDecoration(
                color:globals.customLightBlue),
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
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex:3,
                                                  child:this.alamat!="-"?
                                                        Text(
                                                          this.alamat+", "+this.kodepos+(this.keteranganAlamat=="-"?"":" ("+this.keteranganAlamat+")"),
                                                          style: TextStyle(fontSize: 14.0),
                                                        ):
                                                        Text(
                                                          "Belum ada alamat yang diatur",
                                                          style: TextStyle(fontSize: 14.0,color: Colors.red,fontWeight: FontWeight.bold),
                                                        ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child:GestureDetector(
                                                    onTap: (){
                                                      if(globals.isVerified==0){
                                                        globals.buatToast("Verifikasi E-mail terlebih dahulu");
                                                      }
                                                      else{
                                                        ambilLongitudeLatitude(myContext);
                                                        Navigator.push(
                                                          myContext,
                                                          MaterialPageRoute(
                                                            builder: (context) => UbahAlamat(
                                                              username:globals.loginuser,
                                                              alamat:this.alamat,
                                                              kodePos: this.kodepos,
                                                              keterangan: this.keteranganAlamat,
                                                              longi : this.longi,
                                                              lati : this.lati
                                                            )
                                                          ) 
                                                        ).then((value) => getDetailVendor(globals.loginuser));
                                                      }
                                                    },
                                                    child: Icon(Icons.edit),
                                                  )
                                                )
                                              ],
                                            ),
                                            Text(
                                              "Saldo : Rp "+myFormat.format(this.saldo).toString(),
                                              style: TextStyle(fontSize: 14.0,fontWeight:FontWeight.bold),
                                            ),
                                            Row(
                                              mainAxisAlignment:MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child:ElevatedButton(
                                                    onPressed: (){
                                                      if(globals.isVerified==0){
                                                        globals.buatToast("Verifikasi E-mail terlebih dahulu");
                                                      }
                                                      else{
                                                        Navigator.push(
                                                          myContext,
                                                          MaterialPageRoute(
                                                            builder: (context) => DaftarWithdrawal()
                                                          ) 
                                                        ).then((value) => getDetailVendor(globals.loginuser));
                                                      }
                                                    },
                                                    child: Text("Withdrawal"),
                                                  )
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
                  SizedBox(height: 10.0),
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
                  SizedBox(height: 7.0),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0,right:25.0),
                    child:TextFormField(
                            controller: ongkirCtrl,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ongkos kirim/km belum terisi';
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
                                Icons.motorcycle,
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
                              hintText: "Ongkos Kirim / km",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'Ongkos Kirim / km',
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
                    padding : EdgeInsets.only(top:10.0,left:25.0,right:25.0),
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
                                  editProfil();
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
        title: const Text("Profil Vendor"),
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
                  builder: (context) => ListLaporanVendor()
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
        bottom: new TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
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
                var almt  = result['alamat'][0];
                this.alamat = almt['alamat'];
                this.kodepos= almt['kodePos'];
                this.longi= almt['longitude'];
                this.lati= almt['latitude'];
                this.keteranganAlamat = almt['keterangan'];
                this.ongkirCtrl.text = data['ongkir'].toInt().toString();
                setState((){
                  globals.longitude = almt['longitude'].toDouble();
                  globals.latitude  = almt['latitude'].toDouble();
                });
                //print("longitude:"+globals.longitude.toString());
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
    if(globals.isVerified=="0"){
      globals.buatToast("Verifikasi E-mail terlebih dahulu");
    }
    else{
      var url = Uri.parse(globals.ipnumber+'gantiProfilVendor');
      await http
              .post(url, body: {'username': globals.loginuser, 'nama':namaCtrl.text, 'noHP':noHPCtrl.text,
                                'ongkir':ongkirCtrl.text})
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
  }
  void logoutApp(BuildContext context) async {
    prefs= await SharedPreferences.getInstance();
    prefs.remove('loginuser');
    prefs.remove('loginjenis');
    prefs.remove('vendorTerverifikasi');
    prefs.remove('isVerified');
    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  void ambilLongitudeLatitude(BuildContext context) async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) {
      return;
    }

    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      position = currentPosition;
      globals.longitude=position.longitude;
      globals.latitude = position.latitude;
      print("lat"+globals.latitude.toString());
      print("long"+globals.longitude.toString());
    });
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return true;
  }
}