import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassDetailWaste.dart';
import 'package:jangandibuang/ClassKomentar.dart';
import 'package:jangandibuang/ClassPenjualanTerbanyak.dart';
import 'package:jangandibuang/detailLaporanPenjualanTerbanyak.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'ClassDailyWaste.dart';
import 'ClassDetailWaste.dart';
import 'package:intl/intl.dart';

class LaporanPenjualanTerbanyak extends StatefulWidget {
  final String tglAwal;
  final String tglAkhir;
  LaporanPenjualanTerbanyak(
    {
      @required this.tglAwal,
      @required this.tglAkhir
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.tglAwal,this.tglAkhir);
}

class _MyHomePageState extends State<LaporanPenjualanTerbanyak> {
  String tglAwal,tglAkhir;
  String tipePengurutan="Jumlah Produk Terjual";
  int jenisPengurutan=0;
  _MyHomePageState(this.tglAwal,this.tglAkhir){}
  final _formKey = GlobalKey<FormState>();
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  List<ClassPenjualanTerbanyak> arrPenjualan = new List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    getPenjualan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Penjual Terlaris"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child:Column(
                            children:[
                              Text("Periode "+globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(tglAwal)).toString())+" s/d "+
                              globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(tglAkhir)).toString())
                              , style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                            ]
                          )
                        ),
                        SizedBox(height: 10.0,),
                        Text("Variabel Pengurutan"),
                        DropdownButton<String>(
                            hint:Text("Pilih Variabel Pengurutan"),
                            isExpanded: true,
                            value:tipePengurutan,
                            onChanged: (value){
                              setState(() {
                                tipePengurutan=value;
                                if(tipePengurutan=="Jumlah Produk Terjual"){
                                  jenisPengurutan=0;
                                }
                                else{
                                  jenisPengurutan=1;
                                }
                                getPenjualan();
                              });
                            },
                            items:<String>['Jumlah Produk Terjual','Jumlah Pendapatan'].map((String value) {
                              return new DropdownMenuItem<String>(
                                value: value,
                                child: new Text(value)
                              );
                            }).toList()
                          ),
                        ListView.builder(
                          itemCount: arrPenjualan.length==0 ? 1 : arrPenjualan.length,
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemBuilder: (context,index){
                            if(arrPenjualan.length==0){
                              return Text("no data");
                            }
                            else{
                              return GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailLaporanPenjualanTerbanyak(
                                        username:arrPenjualan[index].username,
                                        tglAwal: tglAwal,
                                        tglAkhir: tglAkhir,
                                      )
                                    ) 
                                  );
                                },
                                child:Card(
                                        elevation: 10,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                        ),
                                        shadowColor: Colors.black,
                                        color: globals.customLightBlue,
                                        child: Padding(
                                                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0,bottom: 10.0),
                                                child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Expanded(
                                                              flex:1,
                                                              child:CircleAvatar(
                                                                minRadius: 25,
                                                                backgroundColor: globals.customDarkBlue,
                                                                child: CircleAvatar(
                                                                  backgroundImage: NetworkImage(globals.imgAdd+arrPenjualan[index].logo),
                                                                  minRadius: 20,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 15.0,),
                                                            Expanded(
                                                              flex:4,
                                                              child:Text(arrPenjualan[index].username,style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)
                                                            ),
                                                            Expanded(
                                                              flex:3,
                                                              child:Column(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Container(
                                                                    child:Align(
                                                                          alignment: Alignment.topRight,
                                                                          child:Text("Rp "+myFormat.format(arrPenjualan[index].nominal).toString(),
                                                                                  style:TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)
                                                                        )
                                                                  ),
                                                                  Container(
                                                                    child:Align(
                                                                          alignment: Alignment.topRight,
                                                                          child:Text("Produk Terjual : "+arrPenjualan[index].terjual.toString(), style: TextStyle(fontSize: 10.0),)
                                                                        )
                                                                  )
                                                                ],
                                                              )
                                                            ),
                                                            Expanded(
                                                              flex:1,
                                                              child:Icon(Icons.chevron_right)
                                                            )
                                                          ],
                                                        )
                                        )
                                      )
                              );
                            }
                          }
                        )
                      ]
                    ),
                    
          )
        ],
      )
    );
  }
  Future<String> getPenjualan() async{
    var url = Uri.parse(globals.ipnumber+'getPenjualanTerbanyak');
    setState(() {
      arrPenjualan.clear();
    });
    await http
            .post(url, body: {'tglAwal':tglAwal,'tglAkhir':tglAkhir,'jenisPengurutan':jenisPengurutan.toString()})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                print(data);
                for(int i=0;i<data.length;i++){
                  String username = data[i]['username'];
                  String logo = data[i]['logo'];
                  double nominal = data[i]['nominal'].toDouble();
                  int terjual = data[i]['terjual'].toInt();
                  ClassPenjualanTerbanyak dataBaru = new ClassPenjualanTerbanyak(username, terjual, nominal,logo);
                  setState(() {
                    arrPenjualan.add(dataBaru);
                  });
                }
                print("size:"+arrPenjualan.length.toString());
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
}