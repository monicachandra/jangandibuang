// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:jangandibuang/ClassMasterBarangs.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'ClassMasterBarangsDaily.dart';
import 'package:intl/intl.dart';
import 'ClassDailyWasteItem.dart';
import 'ClassDailyItemSaved.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class AddItemDailyWaste extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AddItemDailyWaste> {
  final _formKey = GlobalKey<FormState>();
  List<ClassMasterBarangsDaily> arrMakanan = new List.empty(growable: true);
  List<ClassDailyWasteItem> arrChosen = new List.empty(growable: true);
  List<ClassDailyItemSaved> arrToday = new List.empty(growable: true);
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  String tanggal="";
  XFile _image;
  ImagePicker picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getAllMakanan();
    getItemSavedToday();
    tanggal=DateFormat("dd-MM-yyyy").format(DateTime.now()).toString();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Daftar Makanan"),
      ),
      body: ModalProgressHUD(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height:10.0),
                Expanded(
                  flex:1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:[
                      ElevatedButton(
                          onPressed: () {
                              openDialogLanjutan(context);
                          },
                          child: Text("Tambah Waste"),
                        )
                    ]
                  ),
                ),
                SizedBox(height: 25.0),
                Expanded(
                  flex:8,
                  child:Padding(
                    padding : EdgeInsets.only(left:15.0,right:15.0),
                    child:ListView.builder(
                        itemCount: arrMakanan.length==0 ? 1 : arrMakanan.length,
                        itemBuilder: (context,index){
                          if(arrMakanan.length==0){
                            return Text("no data");
                          }
                          else{
                            return CheckboxListTile(
                              value: arrMakanan[index].chosen,
                              onChanged: (value) {
                                setState(() {
                                  arrMakanan[index].chosen = value;
                                  if(value){
                                    for(int i=0;i<arrToday.length;i++){
                                      if(arrToday[i].idBarang==arrMakanan[index].idBarang){
                                        arrMakanan[index].keteranganAda=arrMakanan[index].namaBarang+" sudah ada dengan stok saat ini "+arrToday[i].stok.toString()+", "+
                                                                          "pemilihan ini bersifat menambah stok";
                                      }
                                    }
                                  }
                                  else{
                                    arrMakanan[index].keteranganAda="";
                                  }
                                });
                              },
                              title: Text(arrMakanan[index].namaBarang,style: TextStyle(fontWeight: FontWeight.bold),),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(arrMakanan[index].deskripsiBarang,style:TextStyle(fontSize: 18.0)),
                                    SizedBox(height: 3.0),
                                    Text(arrMakanan[index].keteranganAda,
                                      style:TextStyle(color: Colors.red,fontSize: 13.0)
                                    )
                                  ],  
                                ),
                                secondary: Image.network(
                                        globals.imgAddMakanan+arrMakanan[index].foto,
                                        fit: BoxFit.cover,
                                        height: 75.0,
                                        width: 75.0),
                                selected: arrMakanan[index].chosen,
                                controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10
                              ),
                            );
                          }
                        }
                      ),
                    ),
                )
              ],
            ),inAsyncCall: isLoading
      ),      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getImageFromCamera(context);
        },
        child: const Icon(Icons.camera_alt),
      )
    );
  }

  Future getImageFromCamera(BuildContext context) async{
    var image = await picker.pickImage(source:ImageSource.camera);
    setState((){
      _image = image;
    });
    kirimFotokeWebService(this.context);
  }
  Future<String> kirimFotokeWebService(BuildContext context) async{
    String base64Image = "";
    String namaFile = "";
    if(_image!=null){
      setState(() {
        arrMakanan.clear();
        isLoading=true;
      });
      base64Image = base64Encode(File(_image.path).readAsBytesSync());
      namaFile = _image.path.split("/").last;
      var url = Uri.parse(globals.ipnumber+'compareFotoMakananDaily');
      await http
                .post(url, body: {'username':globals.loginuser,'m_image':base64Image,'m_filename':namaFile})
                .then((res){
                  var result = json.decode(res.body);
                  var status = result['status'];
                  if(status=="Sukses"){
                    arrMakanan.clear();
                    var data   = result['data'];
                    print(data);
                    for (int i = 0; i < data.length; i++) {
                      ClassMasterBarangsDaily databaru = ClassMasterBarangsDaily(data[i]['idBarang'].toInt(), data[i]['idKategori'].toInt(),
                                                                        data[i]['namaBarang'],data[i]['deskripsiBarang'],
                                                                        data[i]['hargaBarangAsli'],data[i]['hargaBarangFoodWaste'],
                                                                        data[i]['foto'],false);
                      setState(() {
                        arrMakanan.add(databaru);
                      }); 
                    }
                  }
                  setState(() {
                    isLoading = false;
                  });
                })
                .catchError((err){
                  print(err);
                });
      _image=null;
      return "Sukses";
    }
    else{
      globals.buatToast("Anda belum memilih foto");
      Navigator.of(context).pop();
      return "Cancel";
    }
  }

  Future<String> getAllMakanan() async{
    var url = Uri.parse(globals.ipnumber+'getAllMakanan');
    String status='1';
    await http
            .post(url, body: {'username':globals.loginuser,'status':status})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                arrMakanan.clear();
                var data   = result['data'];
                for (int i = 0; i < data.length; i++) {
                  ClassMasterBarangsDaily databaru = ClassMasterBarangsDaily(data[i]['idBarang'].toInt(), data[i]['idKategori'].toInt(),
                                                                    data[i]['namaBarang'],data[i]['deskripsiBarang'],
                                                                    data[i]['hargaBarangAsli'],data[i]['hargaBarangFoodWaste'],
                                                                    data[i]['foto'],false);
                  setState(() {
                    arrMakanan.add(databaru);
                  }); 
                }
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
  Future<String> getItemSavedToday() async{
    var url = Uri.parse(globals.ipnumber+'getItemToday');
    await http
            .post(url, body: {'username':globals.loginuser})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                arrToday.clear();
                var data   = result['data'];
                for (int i = 0; i < data.length; i++) {
                  ClassDailyItemSaved databaru = ClassDailyItemSaved(data[i]['idMasterBarang'].toInt(), data[i]['realStok'].toInt());
                  setState(() {
                    arrToday.add(databaru);
                  }); 
                }
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
  openDialogLanjutan(BuildContext context){
    setState(() {
      arrChosen.clear();
    });
    for(int i=0;i<arrMakanan.length;i++){
      if(arrMakanan[i].chosen){
        ClassDailyWasteItem databaru = new ClassDailyWasteItem(arrMakanan[i].idBarang,arrMakanan[i].namaBarang, 
                                        arrMakanan[i].foto,0, arrMakanan[i].hargaBarangAsli, 
                                        arrMakanan[i].hargaBarangFoodWaste);
        setState(() {
          arrChosen.add(databaru);
        });
      }
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)), //this right here
            child: Container(
              height: 500,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex:1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children:[
                                  Text("Tanggal : "+globals.getDeskripsiTanggal(tanggal),style:TextStyle(fontWeight: FontWeight.bold))
                                ]
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Expanded(
                              flex:8,
                              child:Padding(
                              padding : EdgeInsets.only(left:2.0,right:2.0),
                              child:
                                    ListView.builder(
                                      itemCount: arrChosen.length==0 ? 1 : arrChosen.length,
                                      itemBuilder: (context,index){
                                        if(arrChosen.length==0){
                                          return Text("Belum ada makanan yang dipilih");
                                        }
                                        else{
                                          return Card(
                                            elevation: 10,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                            ),
                                            shadowColor: Colors.black,
                                            color: globals.customLightBlue,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start, 
                                              crossAxisAlignment: CrossAxisAlignment.start, 
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child:Padding(
                                                        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0,bottom: 10.0),
                                                        child: InkWell(
                                                            onTap: () {
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: <Widget>[
                                                                Expanded(
                                                                  flex: 4,
                                                                  child: Image.network(
                                                                              globals.imgAddMakanan+arrChosen[index].foto,
                                                                              fit: BoxFit.cover,
                                                                              height: 60.0,
                                                                              width: 60.0),
                                                                ),
                                                                SizedBox(width: 2.0,),
                                                                Expanded(
                                                                  flex:8,
                                                                  child:Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children:[
                                                                      Text(arrChosen[index].nama,
                                                                        style: TextStyle(
                                                                        fontSize: 17.0,
                                                                        fontWeight: FontWeight.bold)),
                                                                      Row(
                                                                        mainAxisAlignment:MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: <Widget>[
                                                                          Expanded(
                                                                            flex: 4,
                                                                            child:/*Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children:<Widget>[
                                                                                SizedBox(
                                                                                  width:25.0,
                                                                                  child:ElevatedButton(
                                                                                        onPressed: (){
                                                                                          setState(() {
                                                                                            if(arrChosen[index].stok>0){
                                                                                              arrChosen[index].stok--;
                                                                                            }
                                                                                          });
                                                                                        },
                                                                                        child: Align(alignment: Alignment.center, child:Text('-')),
                                                                                        style:ElevatedButton.styleFrom(
                                                                                          alignment: Alignment.center,
                                                                                        )
                                                                                      ),
                                                                                ),
                                                                              ]
                                                                            ),*/
                                                                            Text('Stok',style: TextStyle(fontWeight: FontWeight.bold),)
                                                                          ),
                                                                          Expanded(
                                                                            flex:3,
                                                                            child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children:<Widget>[
                                                                                SizedBox(
                                                                                  width:25.0,
                                                                                  child:ElevatedButton(
                                                                                        onPressed: (){
                                                                                          setState(() {
                                                                                            if(arrChosen[index].stok>0){
                                                                                              arrChosen[index].stok--;
                                                                                            }
                                                                                          });
                                                                                        },
                                                                                        child: Text('-'),
                                                                                        style:ElevatedButton.styleFrom(
                                                                                          alignment: Alignment.center,
                                                                                        )
                                                                                      ),
                                                                                ),
                                                                                SizedBox(width:5.0),
                                                                                Text(arrChosen[index].stok.toString()),
                                                                                SizedBox(width:5.0),
                                                                                SizedBox(
                                                                                  width:25.0,
                                                                                  child:ElevatedButton(
                                                                                        onPressed: (){
                                                                                          setState(() {
                                                                                            arrChosen[index].stok++;
                                                                                          });
                                                                                        },
                                                                                        child: Text('+'),
                                                                                      ),
                                                                                ),
                                                                              ]
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: <Widget>[
                                                                          Expanded(
                                                                            flex: 4,
                                                                            child:Text('Harga Asli',style: TextStyle(fontWeight: FontWeight.bold),)
                                                                          ),
                                                                          Expanded(
                                                                            flex:3,
                                                                            child:Text("Rp "+myFormat.format(arrChosen[index].hargaAsli).toString())
                                                                          )
                                                                        ]
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: <Widget>[
                                                                          Expanded(
                                                                            flex: 4,
                                                                            child:Text('Harga Waste',style: TextStyle(fontWeight: FontWeight.bold),)
                                                                          ),
                                                                          Expanded(
                                                                            flex:3,
                                                                            child:TextFormField(
                                                                                controller: arrChosen[index].ctrlHargaWaste,
                                                                                style: TextStyle(
                                                                                  fontSize: 15,
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                                keyboardType: TextInputType.number,
                                                                                onChanged: (text){
                                                                                  arrChosen[index].hargaWaste=int.tryParse(text);
                                                                                },
                                                                              )
                                                                          )
                                                                        ]
                                                                      ),
                                                                    ]
                                                                  )
                                                                )
                                                              ],
                                                            )
                                                          )
                                                      )
                                                )
                                              ]
                                            )
                                          );
                                        }
                                      }
                                    )
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Expanded(
                              flex:1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children:[
                                  ElevatedButton(
                                    onPressed: (){
                                      konfirmasiSimpan(context);
                                    },
                                    child : Text('Simpan')
                                  )
                                ]
                              ),
                            ),
                          ],
                      )
              ),
            ),
          );
        });
      }
    );
  }
  /*Widget _buildMakananItem(int index) {
    return 
      Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0,bottom: 10.0),
        child: InkWell(
            onTap: () {
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Image.network(
                              globals.imgAddMakanan+arrChosen[index].foto,
                              fit: BoxFit.cover,
                              height: 75.0,
                              width: 75.0),
                ),
                SizedBox(width: 15.0,),
                Expanded(
                  flex:8,
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text(arrChosen[index].nama,
                        style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment:MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child:Text('Stok',style: TextStyle(fontWeight: FontWeight.bold),)
                          ),
                          Expanded(
                            flex:3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children:<Widget>[
                                SizedBox(
                                  width:20.0,
                                  child:ElevatedButton(
                                        onPressed: (){
                                          setState(() {
                                            arrChosen[index].stok--;
                                          });
                                        },
                                        child: Text('-'),
                                      ),
                                ),
                                SizedBox(width:5.0),
                                Text(arrChosen[index].stok.toString()),
                                SizedBox(width:5.0),
                                SizedBox(
                                  width:20.0,
                                  child:ElevatedButton(
                                        onPressed: (){
                                          setState(() {
                                            arrChosen[index].stok++;
                                          });
                                        },
                                        child: Text('+'),
                                      ),
                                ),
                              ]
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment:MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child:Text('Harga Asli',style: TextStyle(fontWeight: FontWeight.bold),)
                          ),
                          Expanded(
                            flex:3,
                            child:Text(arrChosen[index].hargaAsli.toString())
                          )
                        ]
                      ),
                      Row(
                        mainAxisAlignment:MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child:Text('Harga Waste',style: TextStyle(fontWeight: FontWeight.bold),)
                          ),
                          Expanded(
                            flex:3,
                            child:TextFormField(
                                controller: arrChosen[index].ctrlHargaWaste,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (text){
                                  arrChosen[index].hargaWaste=int.tryParse(text);
                                },
                              )
                          )
                        ]
                      ),
                      
                    ]
                  )
                )
              ],
            )
          )
      );
  }*/
  konfirmasiSimpan(BuildContext context) {
    if(arrChosen.length==0){
      globals.buatToast("Belum Ada Item yang Dipilih");
    }
    else{
      showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text("Anda yakin seluruh stok sudah benar?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Ya"),
              onPressed: () {
                simpanItemDailyWaste(context);
                getAllMakanan();
                getItemSavedToday();
                Navigator.pop(context);
                Navigator.of(context).pop();
              },
            ),

            FlatButton(
              child: Text("Tidak"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
      );
    }
  }
  Future<String> simpanItemDailyWaste(BuildContext context) async{
    var url = Uri.parse(globals.ipnumber+'simpanItem');
    var chosenItem = json.encode(arrChosen);
    //print(chosenItem);
    await http
            .post(url, body: {'username': globals.loginuser,'chosenItem':chosenItem})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                print(result['leng'].toString());
                arrChosen.clear();
                getItemSavedToday();
                Navigator.pop(context);
                Navigator.pop(context);
              }
              print(status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

}