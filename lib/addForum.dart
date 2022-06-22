// ignore_for_file: unnecessary_new

import 'package:flutter/material.dart';
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
import 'dart:io';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';


class AddForum extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AddForum> {
  final _formKey = GlobalKey<FormState>();
  XFile _image;
  ImagePicker picker = ImagePicker();
  TextEditingController judul  = new TextEditingController();
  TextEditingController deskripsi  = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final gambar = Container(
      width : MediaQuery.of(context).size.width,
      height: 150.0,
      child: Center(
        child: _image==null ? 
          GestureDetector(
            onTap: (){
              getImageFromGallery();
            },
            child : Image.asset('assets/addPhoto.png',
                    height:100,
                    width:100),
          )
         : Image.file(File(_image.path))
      ),
    );
    return Scaffold(
      appBar:AppBar(
        title: const Text("Berbagi Tips & Trik"),
      ),
      body: ListView(
        children: <Widget>[
          Form(
            key:_formKey,
            child:Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height:15.0),
                gambar,
                SizedBox(height:15.0),
                Padding(
                    padding:  EdgeInsets.only(left:25.0,right:25.0),
                    child:TextFormField(
                            controller: judul,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Judul belum terisi';
                              }
                              else if(value.length>255){
                                return 'Judul maks. 255 karakter';
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
                                Icons.title_outlined,
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
                              hintText: "Judul",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'Judul',
                              labelStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height:7.0),
                  Padding(
                      padding:  EdgeInsets.only(left:25.0,right:25.0),
                      child:TextFormField(
                              controller: deskripsi,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Deskripsi belum terisi';
                                }
                                return null;
                              },
                              maxLines: 10,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                focusColor: Colors.white,
                                prefixIcon: Icon(
                                  Icons.description_outlined,
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
                                hintText: "Deskripsi",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                  fontFamily: "verdana_regular",
                                  fontWeight: FontWeight.w400,
                                ),
                                labelText: 'Deskripsi',
                                labelStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
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
                                  posting();
                                }
                              },
                              child: const Text('Posting'),
                            ),
                          ),
                      ]
                    )
                  ),
              ],
            )
          )
        ],
      )
    );
  }
  Future getImageFromGallery() async{
    var image = await picker.pickImage(source:ImageSource.gallery);
    setState((){
      _image = image;
    });
  }
  void posting() {
    //cek confirm dan password harus sama
    if(_image!=null){
      if(globals.loginjenis=='A'){
        postingForum();
      }
      else{
        postingForumVendorPembeli();
      }
    }
    else{
      globals.buatToast("Anda belum memilih gambar");
    }
  }

  Future<String> postingForum() async{
    String base64Image = "";
    String namaFile = "";
    String idBarang="";
    base64Image = base64Encode(File(_image.path).readAsBytesSync());
    namaFile = _image.path.split("/").last;
    var url = Uri.parse(globals.ipnumber+'addForumAdmin');
    await http
              .post(url,
                    body:{'username':globals.loginuser,'judul':judul.text,'deskripsi':deskripsi.text,'m_image':base64Image,'m_filename':namaFile})
              .then((res){
                var result = json.decode(res.body);
                var status = result['status'];
                if(status=="Sukses"){
                  globals.buatToast("Artikel telah terposting");
                  //globals.idAddMakanan=-1;
                  judul.text="";
                  deskripsi.text="";
                  setState(() {
                    _image=null;
                  });
                  print(status);
                }
              })
              .catchError((err){
                print(err);
              });
    return "Sukses";
  }
  Future<String> postingForumVendorPembeli() async{
    String base64Image = "";
    String namaFile = "";
    String idBarang="";
    base64Image = base64Encode(File(_image.path).readAsBytesSync());
    namaFile = _image.path.split("/").last;
    var url = Uri.parse(globals.ipnumber+'addForumVendorPembeli');
    await http
              .post(url,
                    body:{'username':globals.loginuser,'jenisUser':globals.loginjenis,'judul':judul.text,'deskripsi':deskripsi.text,'m_image':base64Image,'m_filename':namaFile})
              .then((res){
                var result = json.decode(res.body);
                var status = result['status'];
                if(status=="Sukses"){
                  globals.buatToast("Artikel Baru Anda telah Terposting");
                  //globals.idAddMakanan=-1;
                  judul.text="";
                  deskripsi.text="";
                  setState(() {
                    _image=null;
                  });
                  print(status);
                }
              })
              .catchError((err){
                print(err);
              });
    return "Sukses";
  }
}
