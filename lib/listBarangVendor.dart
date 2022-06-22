// ignore_for_file: file_names, avoid_print, prefer_const_constructors, use_key_in_widget_constructors
import 'dart:convert';

import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'ClassMasterBarangs.dart';
import 'package:intl/intl.dart';

class ListBarangVendor extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ListBarangVendor> 
with SingleTickerProviderStateMixin
{
  final List<Tab> myTabs = <Tab>[
    new Tab(text: 'Aktif'),
    new Tab(text: 'NonAktif'),
  ];
  final _formKey = GlobalKey<FormState>();
  TabController _tabController;
  List<ClassMasterBarangs> arrMakanan = new List.empty(growable: true);
  List<ClassMasterBarangs> arrMakananNonAktif = new List.empty(growable: true);
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  @override
  void initState() {
    super.initState();
    getAllMakanan(); 
    getAllMakananNonAktif();
    _tabController = new TabController(vsync: this, length: myTabs.length);
    _tabController.animateTo(0);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        int indexTab = _tabController.index;
        getAllMakanan();
        getAllMakananNonAktif();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget viewtab0() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.0),
        Expanded(
          flex:8,
          child:Padding(
          padding : EdgeInsets.only(left:15.0,right:15.0),
          child:
                ListView.builder(
                  itemCount: arrMakanan.length==0 ? 1 : arrMakanan.length,
                  itemBuilder: (context,index){
                    if(arrMakanan.length==0){
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
                        child: _buildMakananItem(arrMakanan[index])
                      );
                    }
                  }
                )
        ),
        )
      ],
    );
  }

  Widget viewtab1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.0),
        Expanded(
          flex:8,
          child:Padding(
          padding : EdgeInsets.only(left:15.0,right:15.0),
          child:
                ListView.builder(
                  itemCount: arrMakananNonAktif.length==0 ? 1 : arrMakananNonAktif.length,
                  itemBuilder: (context,index){
                    if(arrMakananNonAktif.length==0){
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
                        child: _buildMakananItem(arrMakananNonAktif[index])
                      );
                    }
                  }
                )
        ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Jangan Dibuang"),
        bottom: new TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body: new TabBarView(
        controller: _tabController,
        children: [viewtab0(), viewtab1()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(globals.isVerified=="0"){
            globals.buatToast("Verifikasi E-mail terlebih dahulu");
          }
          else if(globals.vendorTerverifikasi=="0"){
            globals.buatToast("Akun Anda belum diverifikasi oleh Admin");
          }
          else{
            tambahBarang();
          }
        },
        child: const Icon(Icons.add),
      )
    );
  }

  Widget _buildMakananItem(ClassMasterBarangs barang) {
    return 
      Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0,bottom: 10.0),
        child: InkWell(
            onTap: () {
            },
            child: Container(
                    child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment:CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child:Image.network(
                                        globals.imgAddMakanan+barang.foto,
                                        fit: BoxFit.cover,
                                        height: 75.0,
                                        width: 75.0
                                      ),
                              ),
                              SizedBox(width: 30.0),
                              Expanded(
                                flex:5,
                                child:Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(barang.namaBarang,
                                                style: TextStyle(
                                                    fontSize: 17.0,
                                                    fontWeight: FontWeight.bold)),
                                            SizedBox(height: 3.0),
                                            Text(barang.deskripsiBarang,
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    color: globals.customGrey)),
                                            SizedBox(height: 3.0),
                                            Text("Rp "+myFormat.format(barang.hargaBarangFoodWaste.toInt()).toString(),
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    color: globals.customGrey)),
                                            SizedBox(height: 3.0),
                                            ElevatedButton(
                                              onPressed: (){
                                                editItem(barang);
                                              },
                                              style:ElevatedButton.styleFrom(
                                                minimumSize: Size(225, 30)
                                              ),
                                              child : Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.edit),
                                                          SizedBox(width: 5.0),
                                                          Text("Ubah")
                                                        ],
                                                      ),
                                            ),
                                          ]
                                      ),
                              )
                            ]
                          )
                ),
          )
      );
  }

  void tambahBarang(){
    globals.modeAdd=1;
    globals.idAddMakanan=-1;
    globals.namaAddMakanan="";
    Navigator.pushNamed(context, "/addMasterBarangVendor").then((value) => refreshView());
  }

  void editItem(ClassMasterBarangs barang){
    globals.idAddMakanan = barang.idBarang;
    globals.namaAddMakanan = barang.namaBarang;
    globals.modeAdd = 0;
    Navigator.pushNamed(context, "/addMasterBarangVendor").then((value) => refreshView());
  }

  Future<String> getAllMakanan() async{
    setState(() {
      arrMakanan.clear();
    });
    var url = Uri.parse(globals.ipnumber+'getAllMakanan');
    await http
            .post(url, body: {'username':globals.loginuser,'status':'1'})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                print(data);
                for (int i = 0; i < data.length; i++) {
                  ClassMasterBarangs databaru = ClassMasterBarangs(data[i]['idBarang'].toInt(), data[i]['idKategori'].toInt(),
                                                                    data[i]['namaBarang'],data[i]['deskripsiBarang'],
                                                                    data[i]['hargaBarangAsli'].toInt(),data[i]['hargaBarangFoodWaste'].toInt(),
                                                                    data[i]['foto']);
                  setState(() {
                    arrMakanan.add(databaru);
                  }); 
                }
                print(arrMakanan.length.toString()+"-");
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
  Future<String> getAllMakananNonAktif() async{
    setState(() {
      arrMakananNonAktif.clear();
    });
    var url = Uri.parse(globals.ipnumber+'getAllMakanan');
    await http
            .post(url, body: {'username':globals.loginuser,'status':'0'})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                print(data);
                for (int i = 0; i < data.length; i++) {
                  ClassMasterBarangs databaru = ClassMasterBarangs(data[i]['idBarang'].toInt(), data[i]['idKategori'].toInt(),
                                                                    data[i]['namaBarang'],data[i]['deskripsiBarang'],
                                                                    data[i]['hargaBarangAsli'].toInt(),data[i]['hargaBarangFoodWaste'].toInt(),
                                                                    data[i]['foto']);
                  setState(() {
                    arrMakananNonAktif.add(databaru);
                  }); 
                }
                print(arrMakananNonAktif.length.toString()+"-");
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  refreshView() {
    getAllMakanan();
    getAllMakananNonAktif();
    //_tabController.animateTo(0);
  }
}