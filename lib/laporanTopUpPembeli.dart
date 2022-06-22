import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassDetailWaste.dart';
import 'package:jangandibuang/ClassKomentar.dart';
import 'package:jangandibuang/ClassUbahSaldo.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'ClassDailyWaste.dart';
import 'ClassDetailWaste.dart';
import 'package:intl/intl.dart';

class LaporanTopUpPembeli extends StatefulWidget {
  final String tglAwal;
  final String tglAkhir;
  LaporanTopUpPembeli(
    {
      @required this.tglAwal,
      @required this.tglAkhir
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.tglAwal,this.tglAkhir);
}

class _MyHomePageState extends State<LaporanTopUpPembeli> {
  String tglAwal,tglAkhir;
  _MyHomePageState(this.tglAwal,this.tglAkhir){}
  final _formKey = GlobalKey<FormState>();
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  List<ClassUbahSaldo> arrTopUp = new List.empty(growable: true);
  double totalTopUp=0.0;

  @override
  void initState() {
    super.initState();
    getTopUp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Top Up"),
      ),
      body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height:10.0),
              Expanded(
                flex:1,
                child: Center(
                  child:Column(
                    children:[
                      Text("Daftar Top Up "+globals.loginuser, style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                      Text("Periode "+globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(tglAwal)).toString())+" s/d "+
                      globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(tglAkhir)).toString())
                      , style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                      SizedBox(height:10.0),
                      Text("Total Top Up : Rp "+myFormat.format(this.totalTopUp).toString(), style: TextStyle(fontSize: 22.0,fontWeight: FontWeight.bold))
                    ]
                  )
                ),
              ),
              SizedBox(height: 20.0,),
              Expanded(
                flex:6,
                child:Padding(
                  padding: EdgeInsets.only(left: 15.0,right: 15.0),
                  child:ListView.builder(
                        itemCount: arrTopUp.length==0 ? 1 : arrTopUp.length,
                        itemBuilder: (context,index){
                          if(arrTopUp.length==0){
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
                                padding:EdgeInsets.only(left:15.0,right:15.0,top:15.0,bottom:15.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(arrTopUp[index].tanggal)).toString())),
                                          Text(arrTopUp[index].waktu)
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                              alignment: Alignment.centerRight,
                                              child:Text("Rp "+myFormat.format(arrTopUp[index].nominal).toString(), style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0,color: Colors.blue.shade900))
                                            )
                                    ),
                                  ],
                                )
                              )
                            );
                          }
                        }
                      ),
                )
              )
            ]
          )
    );
  }
  Future<String> getTopUp() async{
    var url = Uri.parse(globals.ipnumber+'getTopUp');
    setState(() {
      arrTopUp.clear();
    });
    await http
            .post(url, body: {'username':globals.loginuser,'tglAwal':tglAwal,'tglAkhir':tglAkhir})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                this.totalTopUp = result['total'].toDouble();
                var data   = result['data'];
                print(data);
                for(int i=0;i<data.length;i++){
                  int idTopUp = data[i]['idUbahSaldo'].toInt();
                  double nominal = data[i]['nominal'].toDouble();
                  String invoiceUbahSaldo = data[i]['invoiceUbahSaldo'];
                  String tanggal = data[i]['tanggal'];
                  String waktu   = data[i]['waktu'];
                  ClassUbahSaldo dataBaru = new ClassUbahSaldo(idTopUp, 0, invoiceUbahSaldo, nominal, tanggal, waktu, "", "", 1,"");
                  setState(() {
                    arrTopUp.add(dataBaru);
                  });
                }
                print("size:"+arrTopUp.length.toString());
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
}