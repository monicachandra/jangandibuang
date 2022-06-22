// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'ClassKategoris.dart';
import 'ClassStatus.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
//gapakelagi

class AddInfoItemVendor extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AddInfoItemVendor> {
  final _formKey = GlobalKey<FormState>();
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
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Jangan Dibuang"),
      ),
      body: Form(
        key:_formKey,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding:  EdgeInsets.only(top:25.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  Text("Info Barang")
                ]
              ),
              Padding(
                padding : EdgeInsets.only(left:25.0,right:25.0),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children:[
                      Expanded(
                        flex:1,
                        child: Text("Nama Makanan")
                      ),
                      Expanded(
                        flex:2,
                        child:TextFormField(
                          controller: namabarang,
                          keyboardType: TextInputType.text,
                          autofocus: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama Makanan belum terisi';
                            }
                            else if(value.length>50){
                              return 'Nama Makanan maks. 50 karakter';
                            }
                            return null;
                          },
                        )
                      ),
                  ]
                )
              ),
              Padding(
                padding : EdgeInsets.only(left:25.0,right:25.0),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children:[
                      // ignore: prefer_const_constructors
                      Expanded(
                        flex:1,
                        child: Text("Kategori")
                      ),
                      Expanded(
                        flex:2,
                        child:DropdownButton<ClassKategoris>(
                          hint:Text("Pilih Kategori"),
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
                  ]
                )
              ),
              Padding(
                padding : EdgeInsets.only(left:25.0,right:25.0),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children:[
                      // ignore: prefer_const_constructors
                      Expanded(
                        flex:1,
                        child: Text("Deskripsi")
                      ),
                      Expanded(
                        flex:2,
                        child:TextFormField(
                              controller:deskripsi,
                              maxLines: 2,
                              decoration: InputDecoration.collapsed(hintText: "Deskripsi Makanan"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Deskripsi belum terisi';
                                }
                                return null;
                              }
                        )
                      ),
                  ]
                )
              ),
              Padding(
                padding : EdgeInsets.only(left:25.0,right:25.0),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children:[
                      Expanded(
                        flex:1,
                        child: Text("Harga Asli")
                      ),
                      Expanded(
                        flex:2,
                        child:TextFormField(
                          controller: hargaawal,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Harga Asli belum terisi';
                            }
                            return null;
                          },
                        )
                      ),
                  ]
                )
              ),
              Padding(
                padding : EdgeInsets.only(left:25.0,right:25.0),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children:[
                      Expanded(
                        flex:1,
                        child: Text("Harga Food Waste")
                      ),
                      Expanded(
                        flex:2,
                        child:TextFormField(
                          controller: hargawaste,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Harga Food Waste belum terisi';
                            }
                            return null;
                          },
                        )
                      ),
                  ]
                )
              ),
              Padding(
                padding : EdgeInsets.only(left:25.0,right:25.0),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children:[
                      Expanded(
                        flex:1,
                        child: Text("Status")
                      ),
                      Expanded(
                        flex:2,
                        child:DropdownButton<ClassStatus>(
                          hint:Text("Pilih Status Aktif"),
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
                        child:ElevatedButton(
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
                          child: Text(keteranganbutton),
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
                        child:ElevatedButton(
                          onPressed: () {
                            resetForm();
                          },
                          child: Text("Reset"),
                        ),
                      ),
                  ]
                )
              ),
            ],
          ),
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
}