// ignore_for_file: file_names, prefer_const_constructors, avoid_print, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'ClassKategoris.dart';
import 'ClassStatus.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';

class AddMasterBarangVendor extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AddMasterBarangVendor> {
  final _formKey = GlobalKey<FormState>();

  XFile _image;

  ImagePicker picker = ImagePicker();
  List<String> arrFoto = new List.empty(growable: true);

  TextEditingController namabarang  = new TextEditingController();
  TextEditingController deskripsi   = new TextEditingController();
  TextEditingController hargaawal   = new TextEditingController();
  TextEditingController hargawaste  = new TextEditingController();
  List<ClassKategoris> arrKategoris = new List.empty(growable: true);
  List<ClassStatus> arrStatus       = new List.empty(growable: true);
  ClassKategoris chosenKategori     = new ClassKategoris(0, '');
  ClassStatus chosenStatus          = new ClassStatus(1, 'Aktif');
  String keteranganbutton = "Tambah Makanan";

  @override
  void initState() {
    super.initState();
    getKategori(); 
    getStatus();
    if(globals.idAddMakanan!=-1){
      getDataMakanan();
      keteranganbutton="Edit Data Makanan";
      isiArr();
    }
  }
  @override
  Widget build(BuildContext context) {
    final gambar = Container(
      width : MediaQuery.of(context).size.width,
      height: 100.0,
      child: Center(
        child: _image==null ? 
          GestureDetector(
            onTap: (){
              getImageFromGallery();
            },
            child : Image.asset('assets/addPhoto.png',
                    height:200,
                    width:200),
          )
         : Image.file(File(_image.path))
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

    final gridFoto = GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          shrinkWrap: true,
                          primary: false,
                          physics:ClampingScrollPhysics(),
                          children: List.generate(arrFoto.length, (index) {
                            return Card(
                              color: Colors.red,
                              elevation: 10.0,
                              child:
                                  Image.network(
                                    globals.imgAddMakanan+arrFoto[index],
                                    fit: BoxFit.cover,
                                    height: 40.0,
                                    width: 40.0
                                  )
                            );
                          }));

    return Scaffold(
      appBar:AppBar(
        title: const Text("Data Makanan"),
      ),
      body: ListView(
        children: <Widget>[
          Form(
            key:_formKey,
            child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Padding(
                    padding : EdgeInsets.only(top:25.0,left:15.0,right:15.0),
                    child : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color:globals.customLightBlue,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 10.0,),
                          Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child:Text("Info Makanan",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)
                          ),
                          SizedBox(height: 10.0,),
                          Padding(
                            padding:  EdgeInsets.only(left:15.0,right:15.0),
                            child:TextFormField(
                                    controller: namabarang,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Nama Makanan belum terisi';
                                      }
                                      else if(value.length>50){
                                        return 'Nama Makanan maks. 50 karakter';
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
                                        Icons.local_dining_rounded,
                                        color: Colors.black,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            const BorderSide(color: Colors.blue, width: 1.0),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      fillColor: Colors.black,
                                      hintText: "Nama Makanan",
                                      hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontFamily: "verdana_regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                      labelText: 'Nama Makanan',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontFamily: "verdana_regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                          ),
                          SizedBox(height: 5.0,),
                          Padding(
                            padding:  EdgeInsets.only(left:15.0,right:15.0),
                            child: Container(
                                      padding:  EdgeInsets.only(left:15.0,right:15.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color:Colors.grey,width:1),
                                        borderRadius: BorderRadius.circular(12)
                                      ),
                                      child: DropdownButton<ClassKategoris>(
                                                hint:Text("Pilih Kategori"),
                                                isExpanded: true,
                                                value:chosenKategori,
                                                onChanged: (value){
                                                  setState(() {
                                                    chosenKategori=value;
                                                  });
                                                },
                                                items:arrKategoris.map((ClassKategoris value) {
                                                    // ignore: unnecessary_new
                                                    return new DropdownMenuItem<ClassKategoris>(
                                                      value: value,
                                                      child: new Text(value.nama),
                                                    );
                                                  }).toList()
                                              )
                                    ),
                          ),
                          SizedBox(height: 5.0,),
                          Padding(
                            padding:  EdgeInsets.only(left:15.0,right:15.0),
                            child:TextFormField(
                                    controller: deskripsi,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Deskripsi belum terisi';
                                      }
                                      return null;
                                    },
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      focusColor: Colors.white,
                                      prefixIcon: Icon(
                                        Icons.description_rounded,
                                        color: Colors.black,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            const BorderSide(color: Colors.blue, width: 1.0),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      fillColor: Colors.black,
                                      hintText: "Deskripsi",
                                      hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontFamily: "verdana_regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                      labelText: 'Deskripsi',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontFamily: "verdana_regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                          ),
                          SizedBox(height: 5.0,),
                          Padding(
                            padding:  EdgeInsets.only(left:15.0,right:15.0),
                            child:TextFormField(
                                    controller: hargaawal,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Harga Asli belum terisi';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      focusColor: Colors.white,
                                      prefixIcon: Icon(
                                        Icons.sell,
                                        color: Colors.black,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            const BorderSide(color: Colors.blue, width: 1.0),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      fillColor: Colors.black,
                                      hintText: "Harga Asli",
                                      hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontFamily: "verdana_regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                      labelText: 'Harga Asli',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontFamily: "verdana_regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                          ),
                          SizedBox(height: 5.0,),
                          Padding(
                            padding:  EdgeInsets.only(left:15.0,right:15.0),
                            child:TextFormField(
                                    controller: hargawaste,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Harga Waste belum terisi';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      focusColor: Colors.white,
                                      prefixIcon: Icon(
                                        Icons.sell_outlined,
                                        color: Colors.black,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            const BorderSide(color: Colors.blue, width: 1.0),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      fillColor: Colors.black,
                                      hintText: "Harga Waste",
                                      hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontFamily: "verdana_regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                      labelText: 'Harga Waste',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontFamily: "verdana_regular",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                          ),
                          SizedBox(height: 5.0,),
                          Padding(
                            padding:  EdgeInsets.only(left:15.0,right:15.0),
                            child: Container(
                                      padding:  EdgeInsets.only(left:15.0,right:15.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color:Colors.grey,width:1),
                                        borderRadius: BorderRadius.circular(12)
                                      ),
                                      child: DropdownButton<ClassStatus>(
                                              hint:Text("Pilih Status Aktif"),
                                              isExpanded: true,
                                              value:chosenStatus,
                                              onChanged: (value){
                                                setState(() {
                                                  chosenStatus=value;
                                                });
                                              },
                                              items:arrStatus.map((ClassStatus value) {
                                                  // ignore: unnecessary_new
                                                  return new DropdownMenuItem<ClassStatus>(
                                                    value: value,
                                                    child: new Text(value.keteranganStatus),
                                                  );
                                                }).toList()
                                            )
                                    ),
                          ),
                          Padding(
                            padding : EdgeInsets.only(top:7.0,left:15.0,right:15.0),
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
                                          tambahMakanan();
                                        }
                                      },
                                      child: Text(keteranganbutton,style:TextStyle(fontSize: 14.0)),
                                    ),
                                  ),
                                  SizedBox(width: 5.0,),
                                  Expanded(
                                    flex:1,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        resetForm();
                                      },
                                      child: Text("Reset"),
                                    ),
                                  ),
                              ]
                            )
                          ),
                          SizedBox(height: 5.0,)
                        ],
                      ),
                    ),
                  ),
                ]
            )
          ),
          Padding(
            padding : EdgeInsets.only(top:10.0,left:15.0,right:15.0,bottom:15.0),
            child : Container(
              width: 320,
              decoration: BoxDecoration(
                  color:globals.customLightBlue,
                  borderRadius: BorderRadius.circular(12)
                ),
              child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10.0,),
                      Padding(
                        padding: EdgeInsets.only(left: 15.0),
                        child:Text("Foto",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)
                      ),
                      gambar,
                      SizedBox(height: 8.0),
                      /*Padding(
                        padding: EdgeInsets.only(left: 15.0,right: 15.0),
                        child:Center(child: btn,)
                      ),
                      SizedBox(height: 8.0),*/
                      Padding(
                        padding: EdgeInsets.only(left: 15.0,right: 15.0),
                        child:Center(child: btnSimpan,)
                      ),
                      SizedBox(height: 8.0),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0,right:10.0,bottom:10.0),
                        child:gridFoto
                      ),
                      /*Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 2.0),
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
                      )*/
                    ],
                  )
                  
                  
            ),
          ),
        ],
      )
    );
  }

  void resetForm() async{
    kosongkanForm();
    getKategori();
    getStatus();
    if(globals.modeAdd==1){
      globals.idAddMakanan=-1;
      globals.namaAddMakanan="";
      setState(() {
        keteranganbutton="Tambah Makanan";
        arrFoto = new List.empty(growable:true);
      });
    }
  }
  Future<String> getKategori() async{
    var url = Uri.parse(globals.ipnumber+'getKategoriNoPaket');
    await http
            .get(url)
            .then((res){
              arrKategoris.clear();
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                for (int i = 0; i < data.length; i++) {
                  ClassKategoris databaru = ClassKategoris(data[i]['idKategori'], data[i]['namaKategori']);
                  setState(() {
                    arrKategoris.add(databaru);
                    chosenKategori=arrKategoris[i];
                  }); 
                }
              }
              print(status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  void getStatus(){
    arrStatus.clear();
    ClassStatus aktif = ClassStatus(1,'Aktif');
    ClassStatus non   = ClassStatus(0,'Non Aktif');
    setState(() {
      arrStatus.add(aktif);
      arrStatus.add(non);
      chosenStatus=arrStatus[0];
    });
  }

  void tambahMakanan(){
    if(globals.idAddMakanan==-1){
      addMakanan(chosenKategori.id.toString(),namabarang.text.toString(),deskripsi.text.toString(),hargaawal.text.toString(),
              hargawaste.text.toString(),globals.loginuser,chosenStatus.valStatus.toString());
    }
    else{
      //globals.buatToast("sini");
      editMakanan(chosenKategori.id.toString(),namabarang.text.toString(),deskripsi.text.toString(),hargaawal.text.toString(),
              hargawaste.text.toString(),globals.idAddMakanan.toString(),chosenStatus.valStatus.toString());
    }
  }
  
  Future<String> addMakanan(idKategori,namaMakanan,deskripsi,hargaAwal,hargaWaste,username,status) async{
    var url = Uri.parse(globals.ipnumber+'addMakanan');
    await http
            .post(url, body: {'idKategori': idKategori, 'namaMakanan': namaMakanan,'deskripsi': deskripsi, 'hargaAwal':hargaAwal,
                                'hargaWaste':hargaWaste,'username':username,'status':status})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){              
                //kosongkanForm();
                globals.idAddMakanan=result['id'].toInt();
                setState(() {
                  keteranganbutton="Edit Data Makanan";
                });
                globals.namaAddMakanan=result['nama'];
                globals.buatToast("Sukses Menambahkan Makanan");
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
  Future<String> editMakanan(idKategori,namaMakanan,deskripsi,hargaAwal,hargaWaste,idMakanan,status) async{
    var url = Uri.parse(globals.ipnumber+'editMakanan');
    await http
            .post(url, body: {'idKategori': idKategori, 'namaMakanan': namaMakanan,'deskripsi': deskripsi, 'hargaAwal':hargaAwal,
                                'hargaWaste':hargaWaste,'idBarang':idMakanan,'status':status})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){              
                //kosongkanForm();
                globals.idAddMakanan=result['id'].toInt();
                globals.namaAddMakanan=result['nama'];
                globals.buatToast("Sukses Mengubah Data Makanan");
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
  Future<String> getDataMakanan() async{
    var url = Uri.parse(globals.ipnumber+'getDataMakanan');
    await http
            .post(url, body: {'idBarang': globals.idAddMakanan.toString()})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data = result['data'];
                namabarang.value = namabarang.value.copyWith(text:data['namaBarang']);
                deskripsi.value = deskripsi.value.copyWith(text:data['deskripsiBarang']);
                int hargaSblm = data['hargaBarangAsli'].toInt();
                hargaawal.value = hargaawal.value.copyWith(text:hargaSblm.toString());
                int hargaSsdh = data['hargaBarangFoodWaste'].toInt();
                hargawaste.value = hargawaste.value.copyWith(text:hargaSsdh.toString());
                int stat = data['status'].toInt();
                setStatus(stat);
                int kat = data['idKategori'];
                setKategori(kat);
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
  void setKategori(int kat) async{
    var url = Uri.parse(globals.ipnumber+'getKategoriNoPaket');
    await http
            .get(url)
            .then((res){
              arrKategoris.clear();
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                for (int i = 0; i < data.length; i++) {
                  ClassKategoris databaru = ClassKategoris(data[i]['idKategori'], data[i]['namaKategori']);
                  setState(() {
                    arrKategoris.add(databaru);
                  }); 
                }
              }
              print(status);
            })
            .catchError((err){
              print(err);
            });
    for(int i=0;i<arrKategoris.length;i++){
      if(arrKategoris[i].id==kat){
        setState(() {
          chosenKategori=arrKategoris[i];
        });
      }
    }
  }

  void setStatus(int stat) async{
    arrStatus.clear();
    ClassStatus aktif = ClassStatus(1,'Aktif');
    ClassStatus non   = ClassStatus(0,'Non Aktif');
    setState(() {
      arrStatus.add(aktif);
      arrStatus.add(non);
    });
    for(int i=0;i<arrStatus.length;i++){
      if(arrStatus[i].valStatus==stat){
        chosenStatus=arrStatus[i];
      }
    }
  }

  void kosongkanForm(){
    namabarang.text="";
    deskripsi.text="";
    hargaawal.text="";
    hargawaste.text="";
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
        _image=null;
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