import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:jangandibuang/ClassUbahSaldo.dart';
import 'globals.dart' as globals;
import 'ClassActors.dart';
import 'package:http/http.dart' as http;
import 'stackKonfirmasiAdmin.dart';
import 'package:jangandibuang/main.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:intl/intl.dart';


class KonfirmasiAdmin extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<KonfirmasiAdmin> with SingleTickerProviderStateMixin{
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  List<ClassActors> arrVendors = new List.empty(growable: true);
  List<ClassUbahSaldo> arrWD = new List.empty(growable:true);
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  TextEditingController alasanPenolakan       = new TextEditingController();

  final List<Tab> myTabs = <Tab>[
    new Tab(text: 'Konfirmasi Identitas'),
    new Tab(text: 'Konfirmasi Withdrawal'),
  ];
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    getDataVendor();
    getDataKonfirmasiWD();
    _tabController = new TabController(vsync: this, length: myTabs.length);
    _tabController.animateTo(0);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        int indexTab = _tabController.index;
        getDataVendor();
        getDataKonfirmasiWD();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget viewtab0(BuildContext context){
    return Form(
        key:_formKey,
        child: Padding(
                padding : EdgeInsets.only(left:25.0,right:25.0,top:25.0),
                child:
                      ListView.builder(
                        itemCount: arrVendors.length==0 ? 1 : arrVendors.length,
                        itemBuilder: (context,index){
                          if(arrVendors.length==0){
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
                              child: _buildVendorItem(arrVendors[index].logo, arrVendors[index].username, arrVendors[index].nama,context)
                            );
                          }
                          
                        }
                      )
              ),
              );
  }

  Widget viewtab1(BuildContext context){
    return Form(
        key:_formKey2,
        child: Padding(
          padding:EdgeInsets.all(10.0),
          child: ListView.builder(
                  itemCount: arrWD.length==0 ? 1 : arrWD.length,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemBuilder: (context,index){
                    if(arrWD.length==0){
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
                                  padding:EdgeInsets.all(15.0),
                                  child:Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:MainAxisAlignment.start,
                                              crossAxisAlignment:CrossAxisAlignment.center,
                                              children: [
                                                CircleAvatar(
                                                  minRadius: 27,
                                                  backgroundColor: globals.customDarkBlue,
                                                  child: CircleAvatar(
                                                    backgroundImage: NetworkImage(globals.imgAdd+arrWD[index].logo),
                                                    minRadius: 25,
                                                  ),
                                                ),
                                                SizedBox(width:10.0),
                                                Text(arrWD[index].username,style:TextStyle(fontWeight: FontWeight.bold,fontSize: 18))
                                              ],
                                            ),
                                            SizedBox(height: 10.0,),
                                            Text("Pengajuan : "+globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(arrWD[index].tanggal)).toString())+" "+arrWD[index].waktu,
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
                                                      Text(arrWD[index].namaBank+" "+arrWD[index].invoiceUbahSaldo),
                                                      Text("a.n. "+arrWD[index].namaRekening),
                                                      arrWD[index].status==3?Text("Alasan Penolakan : "+arrWD[index].catatan):SizedBox()
                                                    ],
                                                  )
                                                ),
                                                Expanded(
                                                  flex:1,
                                                  child:Container(
                                                    alignment: Alignment.topRight,
                                                    child:Text("Rp "+myFormat.format(arrWD[index].nominal).toString(),style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13)),
                                                  )
                                                )
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child:ElevatedButton(
                                                    onPressed: (){
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return StatefulBuilder(builder: (context, setState) {
                                                            return Dialog(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(15.0)), //this right here
                                                              child: 
                                                              Form(
                                                                key:_formKey3,
                                                                child:
                                                                Container(
                                                                  height: 180,
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(15.0),
                                                                    child: Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                SizedBox(height: 5.0),
                                                                                Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children:[
                                                                                      Expanded(
                                                                                        flex:1,
                                                                                        child:TextFormField(
                                                                                                  controller: alasanPenolakan,
                                                                                                  validator: (value) {
                                                                                                    if (value == null || value.isEmpty) {
                                                                                                      return 'Alasan Penolakan belum terisi';
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
                                                                                                      Icons.note_add,
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
                                                                                                    hintText: "Alasan Penolakan",
                                                                                                    hintStyle: TextStyle(
                                                                                                      color: Colors.grey,
                                                                                                      fontSize: 12,
                                                                                                      fontFamily: "verdana_regular",
                                                                                                      fontWeight: FontWeight.w400,
                                                                                                    ),
                                                                                                    labelText: 'Alasan Penolakan',
                                                                                                    labelStyle: TextStyle(
                                                                                                      color: Colors.grey,
                                                                                                      fontSize: 12,
                                                                                                      fontFamily: "verdana_regular",
                                                                                                      fontWeight: FontWeight.w400,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                      )
                                                                                    ]
                                                                                  ),
                                                                                  SizedBox(height:10.0),
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children:[
                                                                                      Expanded(
                                                                                        flex:1,
                                                                                        child:ElevatedButton(
                                                                                                onPressed: () {
                                                                                                  // Validate returns true if the form is valid, or false otherwise.
                                                                                                  if (_formKey3.currentState.validate()) {
                                                                                                    // If the form is valid, display a snackbar. In the real world,
                                                                                                    // you'd often call a server or save the information in a database.
                                                                                                    /*ScaffoldMessenger.of(context).showSnackBar(
                                                                                                      const SnackBar(content: Text('Processing Data')),
                                                                                                    );*/
                                                                                                    tolakWD(arrWD[index].idTopUp,context);
                                                                                                  }
                                                                                                },
                                                                                                child: const Text('Lanjutkan Penolakan WD'),
                                                                                              ),
                                                                                      )
                                                                                    ]
                                                                                  )
                                                                              ],
                                                                          )
                                                                  ),
                                                                ),
                                                              )
                                                            );
                                                          });
                                                        }
                                                      );
                                                    },
                                                    child: Text("Tolak"),
                                                    style: ElevatedButton.styleFrom(
                                                      primary:Colors.red
                                                    )
                                                  )
                                                ),
                                                SizedBox(width: 10.0,),
                                                Expanded(
                                                  flex:1,
                                                  child:ElevatedButton(
                                                    onPressed: (){
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            title: Text('Konfirmasi'),
                                                            content: Text("Anda yakin mengkonfirmasi WD ini?"),
                                                            actions: <Widget>[
                                                              FlatButton(
                                                                child: Text("Ya"),
                                                                onPressed: () {
                                                                  approveWD(arrWD[index].idTopUp);
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
                                                    child: Text("Konfirmasi"),
                                                    style: ElevatedButton.styleFrom(
                                                      primary:Colors.lightGreen
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Konfirmasi Penyedia Makanan", style:TextStyle(fontSize: 18.0)),
        bottom: new TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body: new TabBarView(
        controller: _tabController,
        children: [viewtab0(context), viewtab1(context)],
      ),
    );
  }

  Widget _buildVendorItem(String imgPath, String username, String nama,BuildContext context) {
    return 
      Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0,bottom: 10.0),
        child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StackKonfirmasiAdmin(
                    username:username
                  )
                ) 
              ).then((value)=>refreshView());
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child:Image.network(
                          globals.imgAdd+imgPath,
                          fit: BoxFit.cover,
                          height: 75.0,
                          width: 75.0),
                ),
                SizedBox(width: 15.0),
                Expanded(
                  flex:5,
                  child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(username,
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 5.0),
                          Text(nama,
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: globals.customGrey))
                        ]
                    ),
                ),
                SizedBox(width: 30.0),
                Expanded(
                  flex:1,
                  child:Icon(Icons.chevron_right)
                ),
              ],
            )
          )
      );
  }

  Future<String> getDataVendor() async{
    var url = Uri.parse(globals.ipnumber+'getVendorWoConfirmation');
    await http
            .get(url)
            .then((res){
              setState(() {
                arrVendors.clear();
              });
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                print(data);
                for (int i = 0; i < data.length; i++) {
                  ClassActors databaru = ClassActors(data[i]['username'], data[i]['nama'],data[i]['logo'],data[i]['email'],data[i]['noHP'],data[i]['tipeActor']);
                  setState(() {
                    arrVendors.add(databaru);
                  }); 
                }
                print(arrVendors.length);
              }
              print(status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> getDataKonfirmasiWD() async{
    setState(() {
      arrWD.clear();
    });
    var url = Uri.parse(globals.ipnumber+'getDataKonfirmasiWD');
    await http
            .get(url)
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                var foto   = result['foto'];
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
                  dataBaru.username=data[i]['username'];
                  dataBaru.logo=foto[i];
                  setState(() {
                    arrWD.add(dataBaru);
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

  Future<String> approveWD(int id) async{
    var url = Uri.parse(globals.ipnumber+'approveWD');
    await http
            .post(url,body: {'id':id.toString()})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                globals.buatToast("Sukses Mengkonfirmasi WD");
              }
              print(status);
              refreshView();
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> tolakWD(int id,BuildContext context) async{
    var url = Uri.parse(globals.ipnumber+'tolakWD');
    await http
            .post(url,body: {'id':id.toString(),'catatan':alasanPenolakan.text.toString()})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                globals.buatToast("Sukses Menolak WD");
                alasanPenolakan.text="";
              }
              print(status);
              Navigator.pop(context);
              refreshView();
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  refreshView() {
    getDataVendor();
    getDataKonfirmasiWD();
    setState((){});
  }

}