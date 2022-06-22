// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassMasterBarangs.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'ClassMasterBarangsDaily.dart';
import 'package:intl/intl.dart';
import 'ClassDailyWasteItem.dart';
import 'ClassDailyItemSaved.dart';

class AddPaketDailyWaste extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AddPaketDailyWaste> {
  final _formKey = GlobalKey<FormState>();
  List<ClassMasterBarangsDaily> arrMakanan = new List.empty(growable: true);
  List<ClassDailyWasteItem> arrChosen = new List.empty(growable: true);
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  String tanggal="";
  int stokPaket=1;
  int hargaAsli=0;
  bool bolehInsert=false;
  TextEditingController namaPaket      = new TextEditingController();
  TextEditingController hargaWaste     = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllMakanan();
    tanggal=DateFormat("dd-MM-yyyy").format(DateTime.now()).toString();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Daftar Makanan"),
      ),
      body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),
                Expanded(
                  flex:1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:[
                      ElevatedButton(
                          onPressed: () {
                              openDialogLanjutan();
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
                    padding : EdgeInsets.only(left:10.0,right:10.0),
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
                                      style:TextStyle(color: Colors.red,fontSize: 10.0)
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
              ],)
    );
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
  openDialogLanjutan(){
    setState(() {
      arrChosen.clear();
      stokPaket=0;
      namaPaket.text="";
      hargaWaste.text="";
      hargaAsli=0;
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
            child: 
            Form(
              key:_formKey,
              child:
              Container(
                height: 500,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5.0),
                              Expanded(
                                flex:1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children:[
                                    Text("Tanggal:"+globals.getDeskripsiTanggal(tanggal),style:TextStyle(fontWeight: FontWeight.bold))
                                  ]
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Expanded(
                                flex:1,
                                child: Padding(
                                        padding:  EdgeInsets.only(left:10.0,right:10.0),
                                        child:TextFormField(
                                                controller: namaPaket,
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Nama Paket belum terisi';
                                                  }
                                                  return null;
                                                },
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: "Nama Paket",
                                                ),
                                              ),
                                      ),
                              ),
                              SizedBox(height: 10.0),
                              Expanded(
                                flex:1,
                                child: Padding(
                                        padding:  EdgeInsets.only(left:10.0,right:10.0),
                                        child:Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex:4,
                                              child: Text('Stok Paket'),
                                            ),
                                            Expanded(
                                              flex:4,
                                              child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children:<Widget>[
                                                        SizedBox(
                                                          width:30.0,
                                                          child:ElevatedButton(
                                                                onPressed: (){
                                                                  setState(() {
                                                                    //arrChosen[index].stok--;
                                                                    if(stokPaket>0){
                                                                      stokPaket--;
                                                                      hitungStokPaket();
                                                                    }
                                                                  });
                                                                },
                                                                child: Text('-'),
                                                              ),
                                                        ),
                                                        SizedBox(width:5.0),
                                                        Text(stokPaket.toString()),
                                                        SizedBox(width:5.0),
                                                        SizedBox(
                                                          width:30.0,
                                                          child:ElevatedButton(
                                                                onPressed: (){
                                                                  setState(() {
                                                                    //arrChosen[index].stok++;
                                                                    stokPaket++;
                                                                    hitungStokPaket();
                                                                  });
                                                                },
                                                                child: Text('+'),
                                                              ),
                                                        ),
                                                      ]
                                                    ),
                                            ),
                                          ],
                                        )
                                      ),
                              ),
                              SizedBox(height: 10.0),
                              Expanded(
                                flex:1,
                                child: Padding(
                                        padding:  EdgeInsets.only(left:10.0,right:10.0),
                                        child:Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              flex:4,
                                              child:Text("Harga Asli")
                                            ),
                                            Expanded(
                                              flex:4,
                                              child:Text("Rp "+myFormat.format(hargaAsli).toString())
                                            )
                                          ],
                                        )
                                      ),
                              ),
                              SizedBox(height: 10.0),
                              Expanded(
                                flex:1,
                                child: Padding(
                                        padding:  EdgeInsets.only(left:10.0,right:10.0),
                                        child:Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              flex:4,
                                              child:Text("Harga Waste")
                                            ),
                                            Expanded(
                                              flex:4,
                                              child:TextFormField(
                                                controller: hargaWaste,
                                                keyboardType: TextInputType.number,
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Harga Waste belum terisi';
                                                  }
                                                  return null;
                                                },
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                decoration: InputDecoration(
                                                  fillColor: Colors.grey,
                                                  hintText: "Harga Waste",
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      ),
                              ),
                              SizedBox(height: 10.0),
                              Expanded(
                                flex:8,
                                child:Padding(
                                padding : EdgeInsets.only(left:5.0,right:5.0),
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
                                                          padding: EdgeInsets.only(left: 3.0, right: 3.0, top: 10.0,bottom: 10.0),
                                                          child: InkWell(
                                                              onTap: () {
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: <Widget>[
                                                                  Expanded(
                                                                    flex: 3,
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
                                                                                    width:25.0,
                                                                                    child:ElevatedButton(
                                                                                          onPressed: (){
                                                                                            setState(() {
                                                                                              if(arrChosen[index].stok>0){
                                                                                                arrChosen[index].stok--;
                                                                                                hitungStokPaket();
                                                                                              }
                                                                                            });
                                                                                          },
                                                                                          child: Text('-'),
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
                                                                                              hitungStokPaket();
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
                                                                        SizedBox(height:5.0),
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
                                                                              child:Text("Rp "+myFormat.format(arrChosen[index].hargaWaste).toString())
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
                                        if (_formKey.currentState.validate()) {
                                          konfirmasiSimpan(context);
                                        }
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
            )
          );
        });
      }
    );
  }
  Widget _buildMakananItem(int index) {
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
                      SizedBox(height:5.0),
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
                            child:Text(arrChosen[index].hargaWaste.toString())
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
  }
  konfirmasiSimpan(BuildContext context) {
    if(arrChosen.length==0){
      globals.buatToast("Belum Ada Item yang Dipilih");
    }
    else{
      bolehInsert=true;
      for(int i=0;i<arrChosen.length;i++){
        if(arrChosen[i].stok%stokPaket!=0){
          bolehInsert=false;
        } 
      }
      if(!bolehInsert){
        globals.buatToast("Stok makanan tidak dapat dibagi sama rata");
      }
      else{
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Konfirmasi'),
              content: Text("Anda yakin seluruh data sudah benar?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Ya"),
                  onPressed: () {
                    simpanItemDailyWaste();
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
  }
  Future<String> simpanItemDailyWaste() async{
    var url = Uri.parse(globals.ipnumber+'simpanPaket');
    var chosenItem = json.encode(arrChosen);
    print(chosenItem);
    await http
            .post(url, body: {'username': globals.loginuser,'chosenItem':chosenItem,'namaPaket':namaPaket.text.toString(),
                              'stokPaket':stokPaket.toString(),'hargaAsli':hargaAsli.toString(),'hargaWaste':hargaWaste.text.toString()})
            .then((res){
              print(res.body);
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                print(result['leng'].toString());
                arrChosen.clear();
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
  void hitungStokPaket(){
    bolehInsert=true;
    hargaAsli=0;
    hargaWaste.text="0";
    if(stokPaket!=0){
      for(int i=0;i<arrChosen.length;i++){
        if(arrChosen[i].stok%stokPaket!=0){
          bolehInsert=false;
        } 
      }
    }
    else{
      globals.buatToast("Isi jumlah paket");
    }
    if(!bolehInsert){
      globals.buatToast("Stok makanan tidak dapat dibagi sama rata");
    }
    else{
      hitungHargaAsli();
      hitungHargaWaste();
    }
  }
  void hitungHargaAsli(){
    int qtyItem=0;
    if(stokPaket==0){
      globals.buatToast("Isi Jumlah Paket");
    }
    else{
      for(int i=0;i<arrChosen.length;i++){
        qtyItem=0;
        double qty = (arrChosen[i].stok/stokPaket);
        qtyItem = qty.toInt();
        int hargaAsliBarang = arrChosen[i].hargaAsli;
        int perkalian = qtyItem*hargaAsliBarang;
        hargaAsli+=perkalian;
      }
    }
  }
  void hitungHargaWaste(){
    int wastePrice=0;
    int qtyItem=0;
    if(stokPaket==0){
      globals.buatToast("Isi Jumlah Paket");
    }
    else{
      for(int i=0;i<arrChosen.length;i++){
        qtyItem=0;
        double qty = (arrChosen[i].stok/stokPaket);
        qtyItem = qty.toInt();
        int hargaWastebrg = arrChosen[i].hargaWaste;
        int perkalian = qtyItem*hargaWastebrg;
        wastePrice+=perkalian;
      }
      hargaWaste.text=wastePrice.toString();
    }
  }
}