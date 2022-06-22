import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassDetailWaste.dart';
import 'package:jangandibuang/ClassHOrder.dart';
import 'package:jangandibuang/ClassKomentar.dart';
import 'package:jangandibuang/detailListOrderanVendorLaporan.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'ClassDailyWaste.dart';
import 'ClassDetailWaste.dart';
import 'package:intl/intl.dart';

class LaporanPenjualanVendor extends StatefulWidget {
  final String tglAwal;
  final String tglAkhir;
  LaporanPenjualanVendor(
    {
      @required this.tglAwal,
      @required this.tglAkhir
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.tglAwal,this.tglAkhir);
}

class _MyHomePageState extends State<LaporanPenjualanVendor> {
  String tipePengiriman="Semua";
  int jenisPengiriman=-1;
  String tglAwal,tglAkhir;
  _MyHomePageState(this.tglAwal,this.tglAkhir){}
  final _formKey = GlobalKey<FormState>();
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  List<ClassHOrder> myOrder = new List.empty(growable: true);
  double totalPenjualan=0.0;
  List<String> ketStatusPengiriman = new List.empty(growable: true);
  final List<Color> warna = <Color>[globals.customBlue, globals.customBlue2,globals.customYellow,
                                    globals.customLightGreen,globals.customGreen];

  @override
  void initState() {
    super.initState();
    this.ketStatusPengiriman.add("Menunggu diproses");
    this.ketStatusPengiriman.add("Sedang diproses");
    this.ketStatusPengiriman.add("Dalam perjalanan");
    this.ketStatusPengiriman.add("Terkirim");
    this.ketStatusPengiriman.add("Sudah diterima");
    getListOrderanLaporan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Laporan Penjualan"),
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
                      Text("Periode "+globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(tglAwal)).toString())+" s/d "+
                      globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(tglAkhir)).toString())
                      , style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                      SizedBox(height:10.0),
                      Text("Total Pendapatan : Rp "+myFormat.format(this.totalPenjualan).toString(), style: TextStyle(fontSize: 22.0,fontWeight: FontWeight.bold))
                    ]
                  )
                ),
              ),
              Expanded(
                flex:1,
                child:Padding(
                      padding:EdgeInsets.only(left:15.0,right: 15.0),
                      child:DropdownButton<String>(
                        hint:Text("Pilih jenis pengiriman"),
                        isExpanded: true,
                        value:tipePengiriman,
                        onChanged: (value){
                          setState(() {
                            tipePengiriman=value;
                            if(tipePengiriman=="Semua"){
                              jenisPengiriman=-1;
                            }
                            else if(tipePengiriman=="Self Pick Up"){
                              jenisPengiriman=0;
                            }
                            else if(tipePengiriman=="Ojek Online"){
                              jenisPengiriman=1;
                            }
                            else{
                              jenisPengiriman=2;
                            }
                            getListOrderanLaporan();
                          });
                        },
                        items:<String>['Semua','Self Pick Up','Ojek Online','Kurir'].map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value)
                          );
                        }).toList()
                      ),
                )
              ),
              Expanded(
                flex:6,
                child:Padding(
                  padding: EdgeInsets.only(left: 15.0,right: 15.0),
                  child:ListView.builder(
                  itemCount: myOrder.length==0 ? 1 : myOrder.length,
                  itemBuilder: (context,index){
                    if(myOrder.length==0){
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
                                child: _buildDailyItem(index)
                        )
                      );
                    }
                  }
                )
                )
              )
            ]
          )
    );
  }
  Widget _buildDailyItem(int index) {
    double totalBiaya = (myOrder[index].totalHargaBarang*(100-myOrder[index].appFee)/100)+myOrder[index].biayaOngkir;
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailListOrderanVendorLaporan(
              HOrder:myOrder[index]
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
            child: Text(ketStatusPengiriman[myOrder[index].statusPengiriman-1],style:TextStyle(fontWeight:FontWeight.bold,color:Colors.white,backgroundColor: warna[myOrder[index].statusPengiriman-1])),
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
                          Text(myOrder[index].usernamePembeli,style:TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold)),
                          Text(myOrder[index].alamatPengiriman),
                          Text("CP "+myOrder[index].CP),
                          Text("Keterangan Tambahan "+(myOrder[index].informasiTambahanPengiriman==''?'-':myOrder[index].informasiTambahanPengiriman)),
                          Text("Tanggal order "+myOrder[index].waktuOrder,style:TextStyle(fontWeight: FontWeight.bold)),
                        ]
                      )
                    ),
                    SizedBox(width:5.0),
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
  Future<String> getListOrderanLaporan() async{
    var url = Uri.parse(globals.ipnumber+'getListOrderanLaporan');
    setState(() {
      myOrder.clear();
      totalPenjualan=0.0;
    });
    await http
            .post(url, body: {'username':globals.loginuser,'tglAwal':tglAwal,'tglAkhir':tglAkhir,'jenisPengiriman':jenisPengiriman.toString()})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                print(data);
                for (int i = 0; i < data.length; i++) {
                  int idHOrder = data[i]['idHOrder'].toInt();
                  String tanggalOrder = data[i]['tanggalOrder'];
                  String waktuOrder = globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(tanggalOrder)).toString())+" "+data[i]['waktuOrder'];
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
                  this.totalPenjualan+= (dataBaru.totalHargaBarang*(100-dataBaru.appFee)/100)+dataBaru.biayaOngkir;                                
                  setState(() {
                    myOrder.add(dataBaru);
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
    getListOrderanLaporan();
  }
}