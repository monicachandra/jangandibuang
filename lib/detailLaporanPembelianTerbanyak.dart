import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassDailyWasteTanggal.dart';
import 'package:jangandibuang/ClassDetailWaste.dart';
import 'package:jangandibuang/ClassHOrder.dart';
import 'package:jangandibuang/ClassKomentar.dart';
import 'package:jangandibuang/DetailListOrderanAdmin.dart';
import 'package:jangandibuang/detailListOrderanVendorLaporan.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DetailLaporanPembelianTerbanyak extends StatefulWidget {
  final String username;
  final String tglAwal;
  final String tglAkhir;
  DetailLaporanPembelianTerbanyak(
    {
      @required this.username,
      @required this.tglAwal,
      @required this.tglAkhir
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.username,this.tglAwal,this.tglAkhir);
}
class _MyHomePageState extends State<DetailLaporanPembelianTerbanyak> {
  final _formKey = GlobalKey<FormState>();
  String username="";
  String tglAwal="";
  String tglAkhir="";
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  List<ClassHOrder> myOrder = new List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    getListOrderan();
  }
  _MyHomePageState(this.username,this.tglAwal,this.tglAkhir){
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text("Pembeli Terbanyak : "+this.username),
      ),
      body:Form(
        key:_formKey,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.0,),
              Center(
                child:Column(
                  children:[
                    Text("Periode "+globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(tglAwal)).toString())+" s/d "+
                    globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(tglAkhir)).toString())
                    , style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                  ]
                )
              ),
              Expanded(
                flex:8,
                child:Padding(
                padding : EdgeInsets.only(top:10.0,left:15.0,right:15.0),
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
              ),
              )
            ],
          ),
        ),
    );
  }

  Widget _buildDailyItem(int index) {
    double totalBiaya = (myOrder[index].totalHargaBarang)+myOrder[index].biayaOngkir;
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailListOrderanAdmin(
              HOrder:myOrder[index]
            )
          ) 
        );
      },
      child: Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                Expanded(
                  flex: 4,
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Toko : "+myOrder[index].usernamePenjual,style:TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold)),
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
                  child:Text("Rp "+myFormat.format(totalBiaya).toString(),style:TextStyle(fontWeight: FontWeight.bold,fontSize:11))
                )
              ]
		  ),
    );
  }
  Future<String> getListOrderan() async{
    var url = Uri.parse(globals.ipnumber+'getListOrderanLaporanPembeli');
    setState(() {
      myOrder.clear();
    });
    await http
            .post(url, body: {'username':this.username,'tglAwal':tglAwal,'tglAkhir':tglAkhir,'jenisPengiriman':'-1'})
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
                  String usernamePenjual = data[i]['usernamePenjual'];
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
}