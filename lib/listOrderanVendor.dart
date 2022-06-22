import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/detailListOrderanVendor.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'ClassDailyWaste.dart';
import 'ClassDetailWaste.dart';
import 'ClassHOrder.dart';
import 'package:intl/intl.dart';

class ListOrderanVendor extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ListOrderanVendor> 
with SingleTickerProviderStateMixin{
  final List<Tab> myTabs = <Tab>[
    new Tab(text: 'Kurir'),
    new Tab(text: 'Self Pickup'),
    new Tab(text: 'Ojek Online'),
  ];
  TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  String tanggal="";
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  List<ClassHOrder> myOrderKurir = new List.empty(growable: true);
  List<ClassHOrder> myOrderSelfPickUp = new List.empty(growable: true);
  List<ClassHOrder> myOrderOjekOnline = new List.empty(growable: true);
  List<String> ketStatusPengiriman = new List.empty(growable: true);
  final List<Color> warna = <Color>[globals.customBlue, globals.customBlue2,globals.customYellow,
                                    globals.customGreen];

  @override
  void initState() {
    super.initState();
    tanggal=DateFormat("dd-MM-yyyy").format(DateTime.now()).toString();
    this.ketStatusPengiriman.add("Menunggu diproses");
    this.ketStatusPengiriman.add("Sedang diproses");
    this.ketStatusPengiriman.add("Dalam perjalanan");
    this.ketStatusPengiriman.add("Terkirim");
    getListOrderanKurir();
    getListOrderanSelfPickup();
    getListOrderanOjekOnline();
    _tabController = new TabController(vsync: this, length: myTabs.length);
    _tabController.animateTo(0);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Your code goes here.
        // To get index of current tab use tabController.index
        int indexTab = _tabController.index;
        getListOrderanKurir();
        getListOrderanSelfPickup();
        getListOrderanOjekOnline();
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
        SizedBox(height:10.0),
        Expanded(
          flex:8,
          child:Padding(
          padding : EdgeInsets.only(left:15.0,right:15.0),
          child:
                ListView.builder(
                  itemCount: myOrderKurir.length==0 ? 1 : myOrderKurir.length,
                  itemBuilder: (context,index){
                    if(myOrderKurir.length==0){
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
                                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0,bottom: 10.0),
                                child: _buildDailyItemKurir(index)
                        )
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
        SizedBox(height: 10.0),
        Expanded(
          flex:8,
          child:Padding(
          padding : EdgeInsets.only(left:15.0,right:15.0),
          child:
                ListView.builder(
                  itemCount: myOrderSelfPickUp.length==0 ? 1 : myOrderSelfPickUp.length,
                  itemBuilder: (context,index){
                    if(myOrderSelfPickUp.length==0){
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
                                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0,bottom: 10.0),
                                child: _buildDailyItemSelfPickup(index)
                        )
                      );
                    }
                  }
                )
        ),
        )
      ],
    );
  }

  Widget viewtab2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.0),
        Expanded(
          flex:8,
          child:Padding(
          padding : EdgeInsets.only(left:15.0,right:15.0),
          child:
                ListView.builder(
                  itemCount: myOrderOjekOnline.length==0 ? 1 : myOrderOjekOnline.length,
                  itemBuilder: (context,index){
                    if(myOrderOjekOnline.length==0){
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
                                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0,bottom: 10.0),
                                child: _buildDailyItemOjekOnline(index)
                        )
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
        title: Text("Daftar Orderan "+globals.getDeskripsiTanggal(tanggal)),
        bottom: new TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body: new TabBarView(
        controller: _tabController,
        children: [viewtab0(), viewtab1(),viewtab2()],
      ),
    );
  }

  Widget _buildDailyItemKurir(int index) {
    double totalBiaya = (myOrderKurir[index].totalHargaBarang*(100-myOrderKurir[index].appFee)/100)+myOrderKurir[index].biayaOngkir;
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailListOrderanVendor(
              HOrder:myOrderKurir[index]
            )
          ) 
        ).then((value)=>refreshView());
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topRight,
            child: Text(ketStatusPengiriman[myOrderKurir[index].statusPengiriman-1],style:TextStyle(fontWeight:FontWeight.bold,color:Colors.white,backgroundColor: warna[myOrderKurir[index].statusPengiriman-1])),
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                Expanded(
                  flex: 4,
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(myOrderKurir[index].usernamePembeli,style:TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold)),
                      Text(myOrderKurir[index].alamatPengiriman),
                      Text("CP "+myOrderKurir[index].CP),
                      Text("Catatan "+(myOrderKurir[index].informasiTambahanPengiriman==''?'-':myOrderKurir[index].informasiTambahanPengiriman)),
                      Text("Jam order "+myOrderKurir[index].waktuOrder,style:TextStyle(fontWeight: FontWeight.bold)),
                    ]
                  )
                ),
                SizedBox(width: 5.0,),
                Expanded(
                  flex: 1,
                  child:Text("Rp "+myFormat.format(totalBiaya).toString(),style:TextStyle(fontWeight: FontWeight.bold,fontSize: 11))
                )
              ]
		  ),
        ],
      )
    );
  }

  Widget _buildDailyItemSelfPickup(int index) {
    double totalBiaya = (myOrderSelfPickUp[index].totalHargaBarang*(100-myOrderSelfPickUp[index].appFee)/100)+myOrderSelfPickUp[index].biayaOngkir;
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailListOrderanVendor(
              HOrder:myOrderSelfPickUp[index]
            )
          ) 
        ).then((value)=>refreshView());;
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topRight,
            child: Text(ketStatusPengiriman[myOrderSelfPickUp[index].statusPengiriman-1],style:TextStyle(fontWeight:FontWeight.bold,color:Colors.white,backgroundColor: warna[myOrderSelfPickUp[index].statusPengiriman-1])),
          ),
          Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  crossAxisAlignment: CrossAxisAlignment.center, 
                  children: [
                    Expanded(
                      flex: 4,
                      child:Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(myOrderSelfPickUp[index].usernamePembeli,style:TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold)),
                          Text(myOrderSelfPickUp[index].alamatPengiriman),
                          Text("CP "+myOrderSelfPickUp[index].CP),
                          Text("Catatan "+(myOrderSelfPickUp[index].informasiTambahanPengiriman==''?'-':myOrderSelfPickUp[index].informasiTambahanPengiriman)),
                          Text("Jam order "+myOrderSelfPickUp[index].waktuOrder,style:TextStyle(fontWeight: FontWeight.bold)),
                        ]
                      )
                    ),
                    SizedBox(width: 5.0,),
                    Expanded(
                      flex: 1,
                      child:Text("Rp "+myFormat.format(totalBiaya).toString(),style:TextStyle(fontWeight: FontWeight.bold,fontSize: 11))
                    )
                  ]
          ),
        ],
      )
    );
  }

  Widget _buildDailyItemOjekOnline(int index) {
    double totalBiaya = (myOrderOjekOnline[index].totalHargaBarang*(100-myOrderOjekOnline[index].appFee)/100)+myOrderOjekOnline[index].biayaOngkir;
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailListOrderanVendor(
              HOrder:myOrderOjekOnline[index]
            )
          ) 
        ).then((value)=>refreshView());;
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topRight,
            child: Text(ketStatusPengiriman[myOrderOjekOnline[index].statusPengiriman-1],style:TextStyle(fontWeight:FontWeight.bold,color:Colors.white,backgroundColor: warna[myOrderOjekOnline[index].statusPengiriman-1])),
          ),
          Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  crossAxisAlignment: CrossAxisAlignment.center, 
                  children: [
                    Expanded(
                      flex: 4,
                      child:Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(myOrderOjekOnline[index].usernamePembeli,style:TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold)),
                          Text(myOrderOjekOnline[index].alamatPengiriman),
                          Text("CP "+myOrderOjekOnline[index].CP),
                          Text("Catatan "+(myOrderOjekOnline[index].informasiTambahanPengiriman==''?'-':myOrderOjekOnline[index].informasiTambahanPengiriman)),
                          Text("Jam order "+myOrderOjekOnline[index].waktuOrder,style:TextStyle(fontWeight: FontWeight.bold)),
                        ]
                      )
                    ),
                    SizedBox(width: 5.0,),
                    Expanded(
                      flex: 1,
                      child:Text("Rp "+myFormat.format(totalBiaya).toString(),style:TextStyle(fontWeight: FontWeight.bold,fontSize: 11))
                    )
                  ]
          ),
        ],
      )
    );
  }

  Future<String> getListOrderanKurir() async{
    var url = Uri.parse(globals.ipnumber+'getListOrderan');
    setState(() {
      myOrderKurir.clear();
    });
    await http
            .post(url, body: {'username':globals.loginuser,'jenisPengiriman':'2'})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                print(data);
                for (int i = 0; i < data.length; i++) {
                  int idHOrder = data[i]['idHOrder'].toInt();
                  String tanggalOrder = data[i]['tanggalOrder'];
                  String waktuOrder = data[i]['waktuOrder'];
                  String usernamePembeli = data[i]['usernamePembeli'];
                  String usernamePenjual = globals.loginuser;
                  double totalHargaBarang = data[i]['totalHargaBarang'].toDouble();
                  double biayaOngkir = data[i]['biayaOngkir'].toDouble();
                  int isDonasi = data[i]['isDonasi'].toInt();
                  double appFee = data[i]['appFee'].toDouble();
                  int alamatDonasi=null;
                  if(data[i]['alamatDonasi']!=null){
                    alamatDonasi = data[i]['alamatDonasi'].toInt();
                  }
                  int alamatPribadi=null;
                  if(data[i]['alamatPribadi']!=null){
                    alamatPribadi = data[i]['alamatPribadi'].toInt();
                  }
                  String alamatPengiriman = result['alamat'][i];
                  String cp = result['cp'][i];
                  int jenisPengiriman = data[i]['jenisPengiriman'].toInt();
                  String informasiTambahanPengiriman = data[i]['informasiTambahanPengiriman'];
                  String informasiTambahanPenjual= data[i]['informasiTambahanPenjual'];
                  int statusPengiriman = data[i]['statusPengiriman'];
                  double rating = data[i]['rating'].toDouble();
                  String comment = data[i]['comment'];

                  ClassHOrder dataBaru = new ClassHOrder(idHOrder, tanggalOrder, waktuOrder, usernamePembeli, usernamePenjual, 
                                                          totalHargaBarang, biayaOngkir, isDonasi, alamatDonasi, alamatPribadi, 
                                                          alamatPengiriman,cp, jenisPengiriman, informasiTambahanPengiriman, 
                                                          statusPengiriman, informasiTambahanPenjual,rating,comment,appFee);
                  setState(() {
                    myOrderKurir.add(dataBaru);
                  });
                }
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> getListOrderanSelfPickup() async{
    var url = Uri.parse(globals.ipnumber+'getListOrderan');
    setState(() {
      myOrderSelfPickUp.clear();
    });
    await http
            .post(url, body: {'username':globals.loginuser,'jenisPengiriman':'0'})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                print(data);
                for (int i = 0; i < data.length; i++) {
                  int idHOrder = data[i]['idHOrder'].toInt();
                  String tanggalOrder = data[i]['tanggalOrder'];
                  String waktuOrder = data[i]['waktuOrder'];
                  String usernamePembeli = data[i]['usernamePembeli'];
                  String usernamePenjual = globals.loginuser;
                  double totalHargaBarang = data[i]['totalHargaBarang'].toDouble();
                  double biayaOngkir = data[i]['biayaOngkir'].toDouble();
                  int isDonasi = data[i]['isDonasi'].toInt();
                  double appFee = data[i]['appFee'].toDouble();
                  int alamatDonasi=null;
                  if(data[i]['alamatDonasi']!=null){
                    alamatDonasi = data[i]['alamatDonasi'].toInt();
                  }
                  int alamatPribadi=null;
                  if(data[i]['alamatPribadi']!=null){
                    alamatPribadi = data[i]['alamatPribadi'].toInt();
                  }
                  String alamatPengiriman = result['alamat'][i];
                  String cp = result['cp'][i];
                  int jenisPengiriman = data[i]['jenisPengiriman'].toInt();
                  String informasiTambahanPengiriman = data[i]['informasiTambahanPengiriman'];
                  String informasiTambahanPenjual= data[i]['informasiTambahanPenjual'];
                  int statusPengiriman = data[i]['statusPengiriman'];
                  double rating = data[i]['rating'].toDouble();
                  String comment = data[i]['comment'];

                  ClassHOrder dataBaru = new ClassHOrder(idHOrder, tanggalOrder, waktuOrder, usernamePembeli, usernamePenjual, 
                                                          totalHargaBarang, biayaOngkir, isDonasi, alamatDonasi, alamatPribadi, 
                                                          alamatPengiriman,cp, jenisPengiriman, informasiTambahanPengiriman, 
                                                          statusPengiriman, informasiTambahanPenjual,rating,comment,appFee);
                  setState(() {
                    myOrderSelfPickUp.add(dataBaru);
                  });
                }
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> getListOrderanOjekOnline() async{
    var url = Uri.parse(globals.ipnumber+'getListOrderan');
    setState(() {
      myOrderOjekOnline.clear();
    });
    await http
            .post(url, body: {'username':globals.loginuser,'jenisPengiriman':'1'})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                print(data);
                for (int i = 0; i < data.length; i++) {
                  int idHOrder = data[i]['idHOrder'].toInt();
                  String tanggalOrder = data[i]['tanggalOrder'];
                  String waktuOrder = data[i]['waktuOrder'];
                  String usernamePembeli = data[i]['usernamePembeli'];
                  String usernamePenjual = globals.loginuser;
                  double totalHargaBarang = data[i]['totalHargaBarang'].toDouble();
                  double biayaOngkir = data[i]['biayaOngkir'].toDouble();
                  int isDonasi = data[i]['isDonasi'].toInt();
                  double appFee = data[i]['appFee'].toDouble();
                  int alamatDonasi=null;
                  if(data[i]['alamatDonasi']!=null){
                    alamatDonasi = data[i]['alamatDonasi'].toInt();
                  }
                  int alamatPribadi=null;
                  if(data[i]['alamatPribadi']!=null){
                    alamatPribadi = data[i]['alamatPribadi'].toInt();
                  }
                  String alamatPengiriman = result['alamat'][i];
                  String cp = result['cp'][i];
                  int jenisPengiriman = data[i]['jenisPengiriman'].toInt();
                  String informasiTambahanPengiriman = data[i]['informasiTambahanPengiriman'];
                  String informasiTambahanPenjual= data[i]['informasiTambahanPenjual'];
                  int statusPengiriman = data[i]['statusPengiriman'];
                  double rating = data[i]['rating'].toDouble();
                  String comment = data[i]['comment'];

                  ClassHOrder dataBaru = new ClassHOrder(idHOrder, tanggalOrder, waktuOrder, usernamePembeli, usernamePenjual, 
                                                          totalHargaBarang, biayaOngkir, isDonasi, alamatDonasi, alamatPribadi, 
                                                          alamatPengiriman,cp, jenisPengiriman, informasiTambahanPengiriman, 
                                                          statusPengiriman, informasiTambahanPenjual,rating,comment,appFee);
                  setState(() {
                    myOrderOjekOnline.add(dataBaru);
                  });
                }
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  refreshView(){
    setState(() {
      getListOrderanKurir();
      getListOrderanSelfPickup();
      getListOrderanOjekOnline();
    });
      //_tabController.animateTo(0);
  }
}