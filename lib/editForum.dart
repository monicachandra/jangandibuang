// ignore_for_file: unnecessary_new

import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassForum.dart';
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

class EditForum extends StatefulWidget {
  final ClassForum detailForum;
  EditForum(
    {
      @required this.detailForum
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.detailForum);
}
class _MyHomePageState extends State<EditForum> {
  final _formKey = GlobalKey<FormState>();
  ClassForum detailForum;

  _MyHomePageState(this.detailForum){
    
  }
  XFile _image;
  ImagePicker picker = ImagePicker();
  TextEditingController judul  = new TextEditingController();
  TextEditingController deskripsi  = new TextEditingController();

  @override
  void initState() {
    super.initState();
    judul.text=detailForum.judulForum;
    deskripsi.text=detailForum.deskripsiForum;
  }
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
            child : Center(
                        child: Image.network(
                                    globals.imgForum+detailForum.fotoForum,
                                    fit: BoxFit.cover)
                      ),
          )
         : Image.file(File(_image.path))
      ),
    );
    return Scaffold(
      appBar:AppBar(
        title: const Text("Jangan Dibuang"),
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
                              child: const Text('Sunting Forum'),
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
    if(_image!=null){
      //editSemua
      editFullForum();
    }
    else{
      //editjuduldandeskripsitok
      editHalfForum();
    }
  }

  Future<String> editFullForum() async{
    String base64Image = "";
    String namaFile = "";
    String idBarang="";
    base64Image = base64Encode(File(_image.path).readAsBytesSync());
    namaFile = _image.path.split("/").last;
    var url = Uri.parse(globals.ipnumber+'editFullForum');
    await http
              .post(url,
                    body:{'loginJenis':globals.loginjenis,'idForum':detailForum.idForum.toString(),'judul':judul.text,'deskripsi':deskripsi.text,'m_image':base64Image,'m_filename':namaFile})
              .then((res){
                var result = json.decode(res.body);
                var status = result['status'];
                if(status=="Sukses"){
                  if(globals.loginjenis=="A"){
                    globals.buatToast("Artikel telah tersunting dan otomatis aktif");
                    if(detailForum.jenisUser!="A"){
                      globals.buatPushNotif(detailForum.username, "Artikel Anda telah disunting dan Aktif", judul.text+" telah Aktif!");
                    }
                  }
                  else{
                    globals.buatToast("Artikel menunggu disetujui oleh Admin");
                    globals.buatPushNotifAdmin("Artikel Telah Diedit", "Baca dan Sunting!");
                  }
                  print(status);
                }
              })
              .catchError((err){
                print(err);
              });
    return "Sukses";
  }
  Future<String> editHalfForum() async{
    var url = Uri.parse(globals.ipnumber+'editHalfForum');
    await http
              .post(url,
                    body:{'loginJenis':globals.loginjenis,'idForum':detailForum.idForum.toString(),'judul':judul.text,'deskripsi':deskripsi.text})
              .then((res){
                var result = json.decode(res.body);
                var status = result['status'];
                if(status=="Sukses"){
                  if(globals.loginjenis=="A"){
                    globals.buatToast("Artikel telah tersunting dan otomatis aktif");
                    if(detailForum.jenisUser!="A"){
                      globals.buatPushNotif(detailForum.username, "Artikel Anda telah disunting dan Aktif", judul.text+" telah Aktif!");
                    }
                  }
                  else{
                    globals.buatToast("Artikel menunggu disetujui oleh Admin");
                    globals.buatPushNotifAdmin("Artikel Telah Diedit", "Baca dan Sunting!");
                  }
                  print(status);
                }
              })
              .catchError((err){
                print(err);
              });
    return "Sukses";
  }
}
