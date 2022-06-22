import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassLaporanPenerimaBantuan.dart';
import 'package:jangandibuang/detailPemberianBantuanAdmin.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LaporanDonasiAdmin extends StatefulWidget {
  final String tglAwal;
  final String tglAkhir;
  LaporanDonasiAdmin(
    {
      @required this.tglAwal,
      @required this.tglAkhir
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.tglAwal,this.tglAkhir);
}

class _MyHomePageState extends State<LaporanDonasiAdmin> {
  String tglAwal,tglAkhir;
  String tipePengurutan="Jumlah Penerimaan";
  int jenisPengurutan=0;
  _MyHomePageState(this.tglAwal,this.tglAkhir){}
  final _formKey = GlobalKey<FormState>();
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  List<ClassLaporanPenerimaBantuan> arrPenjualan = new List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    getPenjualan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Pemberian Bantuan"),
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
                                if(tipePengurutan=="Jumlah Penerimaan"){
                                  jenisPengurutan=0;
                                }
                                else{
                                  jenisPengurutan=1;
                                }
                                getPenjualan();
                              });
                            },
                            items:<String>['Jumlah Penerimaan','Jumlah Produk Diterima'].map((String value) {
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
                                onTap:(){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPemberianBantuanAdmin(
                                        id:arrPenjualan[index].id,
                                        nama:arrPenjualan[index].nama,
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
                                                              flex:6,
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(arrPenjualan[index].nama,
                                                                                  style:TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                                                  Text(arrPenjualan[index].alamat,
                                                                                  style:TextStyle(fontSize: 13,fontWeight: FontWeight.bold),)
                                                                ],
                                                              )
                                                            ),
                                                            SizedBox(width: 15.0,),
                                                            Expanded(
                                                              flex:3,
                                                              child:Column(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Container(
                                                                    child:Align(
                                                                          alignment: Alignment.topRight,
                                                                          child:Text(arrPenjualan[index].berapaKali.toString()+" x",
                                                                                  style:TextStyle(fontSize: 17,fontWeight: FontWeight.bold),)
                                                                        )
                                                                  ),
                                                                  Container(
                                                                    child:Align(
                                                                          alignment: Alignment.topRight,
                                                                          child:Text("Jumlah Produk : "+arrPenjualan[index].jumlahProduk.toString(),
                                                                                style:TextStyle(fontSize: 11))
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
    var url = Uri.parse(globals.ipnumber+'getLaporanDonasi');
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
                  int id = data[i]['id'].toInt();
                  String nama = data[i]['nama'];
                  String alamat = data[i]['alamat'];
                  int berapaKali = data[i]['berapaKali'];
                  int jumlahProduk = data[i]['jumlahProduk'];
                  ClassLaporanPenerimaBantuan dataBaru = new ClassLaporanPenerimaBantuan(id, nama, alamat, berapaKali, jumlahProduk);
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