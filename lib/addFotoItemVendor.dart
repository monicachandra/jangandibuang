// ignore_for_file: file_names, avoid_print, prefer_const_constructors, use_key_in_widget_constructors

import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
//gapake lagi

class AddFotoItemVendor extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AddFotoItemVendor> {
  final formKey = GlobalKey<FormState>();
  
  XFile _image;

  ImagePicker picker = ImagePicker();
  List<String> arrFoto = new List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    if(globals.idAddMakanan!=-1){
      isiArr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gambar = Container(
      width : MediaQuery.of(context).size.width,
      height: 100.0,
      child: Center(
        child: _image==null ? Text('Belum Ada Gambar yang Dipilih') : Image.file(File(_image.path))
      ),
    );

    final btn = Padding(
      padding : EdgeInsets.symmetric(vertical: 0),
      child : ElevatedButton(
        onPressed: (){
          getImageFromGallery();
        },
        child : Text('Pilih Foto')
      )
    );

    final btnSimpan = Padding(
      padding : EdgeInsets.symmetric(vertical: 0),
      child : ElevatedButton(
        onPressed: (){
          simpanFotoMakanan();
        },
        child : Text('Simpan Foto')
      )
    );

    final nama = Center(child: Text(globals.namaAddMakanan));

    final gridFoto = GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          children: List.generate(arrFoto.length, (index) {
                            return Card(
                              color: Colors.red,
                              elevation: 10.0,
                              child:ListView(
                                shrinkWrap: false,
                                children: [
                                  Image.network(
                                    globals.imgAddMakanan+arrFoto[index],
                                    fit: BoxFit.cover,
                                    height: 50.0,
                                    width: 50.0
                                  )
                                ]
                              ) 
                            );
                          }));

    return Scaffold(
        appBar: AppBar(
          title: const Text("Jangan Dibuang"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 2.0),
                    nama,
                    SizedBox(height: 8.0),
                    gambar,
                    SizedBox(height: 8.0),
                    btn,
                    SizedBox(height: 8.0),
                    btnSimpan,
                    SizedBox(height: 8.0),
                  ],
                )),
            Expanded(
              child: Padding(padding: EdgeInsets.only(left: 10.0,right:10.0),child: gridFoto,)
            )
          ],
        )
    );
  }

  Future getImageFromGallery() async{
    if(globals.idAddMakanan==-1){
      globals.buatToast("Anda belum menginputkan info makanan");
    }
    else{
      var image = await picker.pickImage(source:ImageSource.camera);
      setState((){
        _image = image;
      });
    }
  }

  Future<String> simpanFotoMakanan() async{
    if(globals.idAddMakanan==-1){
      globals.buatToast("Anda belum menginputkan info makanan");
      return "Gagal";
    }
    else{
      String base64Image = "";
      String namaFile = "";
      String idBarang="";
      if(_image!=null){
        base64Image = base64Encode(File(_image.path).readAsBytesSync());
        namaFile = _image.path.split("/").last;
        idBarang = globals.idAddMakanan.toString();
        var url = Uri.parse(globals.ipnumber+'addFotoMakanan');
        await http
                  .post(url,
                        body:{'idBarang':idBarang,'m_image':base64Image,'m_filename':namaFile})
                  .then((res){
                    var result = json.decode(res.body);
                    var status = result['status'];
                    if(status=="Sukses"){
                      globals.buatToast("Gambar tersimpan");
                      //globals.idAddMakanan=-1;
                      isiArr();
                      print(status);
                    }
                  })
                  .catchError((err){
                    print(err);
                  });
        return "Sukses";
      }
      else{
        globals.buatToast("Anda belum memilih foto");
        return "Cancel";
      }
    }
  }

  Future<String> isiArr() async{
    var url = Uri.parse(globals.ipnumber+'getFotobyIdBarang');
    await http
            .post(url, body: {'idBarang':globals.idAddMakanan.toString()})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                arrFoto.clear();
                var data   = result['data'];
                print(data);
                for (int i = 0; i < data.length; i++) {
                  String databaru = data[i]['foto'];
                  setState(() {
                    arrFoto.add(databaru);
                    //print(arrFoto.length);
                  }); 
                }
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
}