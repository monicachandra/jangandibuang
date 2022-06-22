// ignore_for_file: file_names, use_key_in_widget_constructors, unused_field, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:jangandibuang/ClassKategoris.dart';
import 'package:jangandibuang/ClassUbahSaldo.dart';
import 'package:jangandibuang/ShowHtmlPage.dart';
import 'package:jangandibuang/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jangandibuang/register.dart';
import 'package:jangandibuang/withdrawal.dart';
import 'package:passwordfield/passwordfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DaftarWithdrawal extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<DaftarWithdrawal> with SingleTickerProviderStateMixin{
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  List<ClassUbahSaldo> arrMenungguKonfirmasi = new List.empty(growable:true);
  List<ClassUbahSaldo> arrHistory = new List.empty(growable:true);

  final List<Color> warna = <Color>[globals.customBlue, globals.customGreen,globals.customYellow,
                                    globals.customLightRed];
  final List<String> keterangan =["Menunggu Konfirmasi","Telah Disetujui","Dibatalkan","Ditolak"];

  final List<Tab> myTabs = <Tab>[
    new Tab(text: 'Menunggu Konfirmasi'),
    new Tab(text: 'Riwayat'),
  ];
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    getMenungguKonfirmasi();
    getHistory();
    _tabController = new TabController(vsync: this, length: myTabs.length);
    _tabController.animateTo(0);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        int indexTab = _tabController.index;
        getMenungguKonfirmasi();
        getHistory();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget viewtab0(){ 
    return Form(
        key:_formKey,
        child: Padding(
          padding:EdgeInsets.all(10.0),
          child: ListView.builder(
                  itemCount: arrMenungguKonfirmasi.length==0 ? 1 : arrMenungguKonfirmasi.length,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemBuilder: (context,index){
                    if(arrMenungguKonfirmasi.length==0){
                      return Text("no data");
                    }
                    else{
                      return Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                shadowColor: Colors.black,
                                color: globals.customLightBlue,
                                child: Padding(
                                  padding:EdgeInsets.all(10.0),
                                  child:Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              alignment: Alignment.topRight,
                                              child: Text(keterangan[arrMenungguKonfirmasi[index].status],style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,backgroundColor: warna[arrMenungguKonfirmasi[index].status]),),
                                            ),
                                            SizedBox(height: 10.0,),
                                            Text("Pengajuan : "+globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(arrMenungguKonfirmasi[index].tanggal)).toString())+" "+arrMenungguKonfirmasi[index].waktu,
                                                  style: TextStyle(fontWeight: FontWeight.bold),),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child:Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(arrMenungguKonfirmasi[index].namaBank+" "+arrMenungguKonfirmasi[index].invoiceUbahSaldo),
                                                      Text("a.n. "+arrMenungguKonfirmasi[index].namaRekening)
                                                    ],
                                                  )
                                                ),
                                                Expanded(
                                                  flex:1,
                                                  child:Container(
                                                    alignment: Alignment.topRight,
                                                    child:Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Rp "+myFormat.format(arrMenungguKonfirmasi[index].nominal).toString(),style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13)),
                                                        ElevatedButton(
                                                          onPressed: (){
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return AlertDialog(
                                                                  title: Text('Konfirmasi'),
                                                                  content: Text("Anda yakin membatalkan WD ini?"),
                                                                  actions: <Widget>[
                                                                    FlatButton(
                                                                      child: Text("Ya"),
                                                                      onPressed: () {
                                                                        batalkanWD(arrMenungguKonfirmasi[index].idTopUp);
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
                                                          }, 
                                                          child: Text("Batal"),
                                                          style: ElevatedButton.styleFrom(
                                                                    primary:Colors.red
                                                                  ),
                                                        )
                                                      ],
                                                    )
                                                  )
                                                )
                                              ],
                                            )
                                          ],
                                        )
                                )
                              );
                    }
                  }
                ),
        ),
        );
  }

  Widget viewtab1(){
    return Form(
        key:_formKey4,
        child: Padding(
          padding:EdgeInsets.all(10.0),
          child: ListView.builder(
                  itemCount: arrHistory.length==0 ? 1 : arrHistory.length,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemBuilder: (context,index){
                    if(arrHistory.length==0){
                      return Text("no data");
                    }
                    else{
                      return Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                shadowColor: Colors.black,
                                color: globals.customLightBlue,
                                child: Padding(
                                  padding:EdgeInsets.all(10.0),
                                  child:Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              alignment: Alignment.topRight,
                                              child: Text(keterangan[arrHistory[index].status],style: TextStyle(fontWeight: FontWeight.bold,color:Colors.white,backgroundColor: warna[arrHistory[index].status]),),
                                            ),
                                            SizedBox(height: 10.0,),
                                            Text("Pengajuan : "+globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(arrHistory[index].tanggal)).toString())+" "+arrHistory[index].waktu,
                                                  style: TextStyle(fontWeight: FontWeight.bold),),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child:Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(arrHistory[index].namaBank+" "+arrHistory[index].invoiceUbahSaldo),
                                                      Text("a.n. "+arrHistory[index].namaRekening),
                                                      arrHistory[index].status==3?Text("Alasan Penolakan : "+arrHistory[index].catatan):SizedBox()
                                                    ],
                                                  )
                                                ),
                                                Expanded(
                                                  flex:1,
                                                  child:Container(
                                                    alignment: Alignment.topRight,
                                                    child:Text("Rp "+myFormat.format(arrHistory[index].nominal).toString(),style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13)),
                                                  )
                                                )
                                              ],
                                            )
                                          ],
                                        )
                                )
                              );
                    }
                  }
                ),
        ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Withdrawal Saldo"),
        bottom: new TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body:new TabBarView(
        controller: _tabController,
        children: [viewtab0(), viewtab1()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Withdrawal()
            ) 
          ).then((value) => refreshView());
        },
        child: const Icon(Icons.add),
      )
    );
  }
  
  Future<String> getMenungguKonfirmasi() async{
    setState(() {
      arrMenungguKonfirmasi.clear();
    });
    var url = Uri.parse(globals.ipnumber+'getWD');
    await http
            .post(url,body: {'status': '0','username':globals.loginuser})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                for (int i = 0; i < data.length; i++) {
                  int idTopUp = data[i]['idUbahSaldo'].toInt();
                  String invoiceUbahSaldo = data[i]['invoiceUbahSaldo'];
                  double nominal = data[i]['nominal'].toDouble();
                  String tanggal = data[i]['tanggal'];
                  String waktu = data[i]['waktu'];
                  String namaRekening = data[i]['namaRekening'];
                  String namaBank = data[i]['namaBank'];
                  int statusWd = data[i]['status'].toInt();
                  String catatan = data[i]['catatan'];
                  ClassUbahSaldo dataBaru = new ClassUbahSaldo(idTopUp, 1, invoiceUbahSaldo, nominal, tanggal, waktu, namaRekening, namaBank, statusWd, catatan);
                  setState(() {
                    arrMenungguKonfirmasi.add(dataBaru);
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
  Future<String> getHistory() async{
    setState(() {
      arrHistory.clear();
    });
    var url = Uri.parse(globals.ipnumber+'getWD');
    await http
            .post(url,body: {'status': '1','username':globals.loginuser})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                for (int i = 0; i < data.length; i++) {
                  int idTopUp = data[i]['idUbahSaldo'].toInt();
                  String invoiceUbahSaldo = data[i]['invoiceUbahSaldo'];
                  double nominal = data[i]['nominal'].toDouble();
                  String tanggal = data[i]['tanggal'];
                  String waktu = data[i]['waktu'];
                  String namaRekening = data[i]['namaRekening'];
                  String namaBank = data[i]['namaBank'];
                  int statusWd = data[i]['status'].toInt();
                  String catatan = data[i]['catatan'];
                  ClassUbahSaldo dataBaru = new ClassUbahSaldo(idTopUp, 1, invoiceUbahSaldo, nominal, tanggal, waktu, namaRekening, namaBank, statusWd, catatan);
                  setState(() {
                    arrHistory.add(dataBaru);
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

  Future<String> batalkanWD(int id) async{
    var url = Uri.parse(globals.ipnumber+'batalkanWD');
    await http
            .post(url,body: {'id':id.toString()})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                globals.buatToast("Sukses Membatalkan WD");
              }
              print(status);
              refreshView();
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  refreshView(){
    getMenungguKonfirmasi();
    getHistory();
  }
}