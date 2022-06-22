import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:jangandibuang/ClassDetailOrder.dart';
import 'package:jangandibuang/ClassDetailShoppingCart.dart';
import 'package:jangandibuang/ClassHOrder.dart';
import 'package:jangandibuang/ClassShoppingCart.dart';
import 'package:jangandibuang/showChat.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'ClassDailyWaste.dart';
import 'ClassDailyWastePembeli.dart';
import 'ClassDetailWaste.dart';
import 'ClassAlamat.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DetailListOrderanVendor extends StatefulWidget {
  final ClassHOrder HOrder;
  DetailListOrderanVendor(
    {
      @required this.HOrder
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.HOrder);
}

class _MyHomePageState extends State<DetailListOrderanVendor> {
  
  final _formKey = GlobalKey<FormState>();
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  ClassHOrder HOrder;
  List<ClassDetailOrder> arrDetailOrder = new List.empty(growable: true);
  List<String> ketStatusPengiriman = new List.empty(growable: true);
  TextEditingController infoTambahanPenjual  = new TextEditingController();
  _MyHomePageState(this.HOrder){
  }

  @override
  void initState() {
    super.initState();
    this.ketStatusPengiriman.add("Proses");
    this.ketStatusPengiriman.add("Kirim");
    this.ketStatusPengiriman.add("Terkirim");
    infoTambahanPenjual.text=this.HOrder.keteranganPenjual;
    getDetailWaste();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Detail Order"),
        actions: <Widget>[
          IconButton(
            icon:Icon(Icons.chat),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShowChat(
                    nama:this.HOrder.usernamePembeli
                  )
                ) 
              );
            },
          )
        ],
      ),
      body:ListView(
        children: <Widget>[
          Form(
            key:_formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left:15.0,right: 15.0,top: 20.0),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex:1,
                        child:Container(
                                decoration: BoxDecoration(
                                    color:globals.customLightBlue,
                                    borderRadius: BorderRadius.circular(12)
                                  ),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 15.0,right: 15.0,top: 15.0,bottom: 15.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(this.HOrder.usernamePembeli, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),),
                                      SizedBox(height: 3.0,),
                                      Text(this.HOrder.alamatPengiriman),
                                      Text("CP : "+this.HOrder.CP),
                                      Text("Catatan : "+this.HOrder.informasiTambahanPengiriman),
                                      Text("Tanggal Order "+globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(this.HOrder.tanggalOrder)).toString())+" "+this.HOrder.waktuOrder,
                                              style:TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                      )
                    ],
                  )
                ),
                Padding(
                  padding: EdgeInsets.only(left:15.0,right: 15.0,top: 20.0),
                  child:Container(
                    decoration: BoxDecoration(
                        color:globals.customLightBlue,
                        borderRadius: BorderRadius.circular(12)
                      ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.0,right: 15.0,top: 15.0,bottom:15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Daftar Pesanan", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0),),
                          ListView.builder(
                            shrinkWrap: true,
                            primary: false,
                            physics: ScrollPhysics(),
                            itemCount: arrDetailOrder.length==0 ? 1 : arrDetailOrder.length,
                            itemBuilder: (context,idx){
                              if(arrDetailOrder.length==0){
                                return Text("no data");
                              }
                              else{
                                return Card(
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                  shadowColor: Colors.black,
                                  color: globals.customYellow,
                                  child: Padding(
                                          padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0,bottom: 10.0),
                                          child: _buildMenuItem(idx)
                                        )
                                );
                              }
                            }
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left:15.0,right: 15.0,top: 20.0,),
                  child:Row(
                    mainAxisAlignment:MainAxisAlignment.start,
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex:1,
                        child:Container(
                              decoration: BoxDecoration(
                                  color:globals.customLightBlue,
                                  borderRadius: BorderRadius.circular(12)
                                ),
                              child: Padding(
                                padding: EdgeInsets.only(left: 15.0,right: 15.0,top: 15.0,bottom:15.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex:1,
                                          child:Text("Subtotal Barang")
                                        ),
                                        Expanded(
                                          flex:1,
                                          child:Container(
                                            child:Align(
                                              alignment: Alignment.topRight,
                                              child:Text("Rp "+myFormat.format(this.HOrder.totalHargaBarang.toInt()).toString())
                                            )
                                          )
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex:1,
                                          child:Text("Biaya Aplikasi")
                                        ),
                                        Expanded(
                                          flex:1,
                                          child:Container(
                                            child:Align(
                                              alignment: Alignment.topRight,
                                              child:Text("Rp "+myFormat.format(this.HOrder.totalHargaBarang.toInt()*this.HOrder.appFee.toDouble()/100).toString())
                                            )
                                          )
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex:1,
                                          child:Text("Ongkos Kirim")
                                        ),
                                        Expanded(
                                          flex:1,
                                          child:Container(
                                            child:Align(
                                              alignment: Alignment.topRight,
                                              child:Text("Rp "+myFormat.format(this.HOrder.biayaOngkir.toInt()).toString())
                                            )
                                          )
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex:1,
                                          child:Text("Total")
                                        ),
                                        Expanded(
                                          flex:1,
                                          child:Container(
                                            child:Align(
                                              alignment: Alignment.topRight,
                                              child:Text("Rp "+myFormat.format(this.HOrder.biayaOngkir.toInt()+this.HOrder.totalHargaBarang.toInt()).toString())
                                            )
                                          )
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ),
                            ),
                      )
                    ],
                  )
                ),
                Padding(
                  padding: EdgeInsets.only(left:15.0,right: 15.0,top: 20.0,),
                  child:Container(
                    decoration: BoxDecoration(
                        color:globals.customLightBlue,
                        borderRadius: BorderRadius.circular(12)
                      ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.0,right: 15.0,top: 15.0,bottom:15.0),
                      child: TextFormField(
                              controller: infoTambahanPenjual,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                focusColor: Colors.white,
                                prefixIcon: Icon(
                                  Icons.note_add,
                                  color: Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.blue, width: 1.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                fillColor: Colors.black,
                                hintText: "Informasi Tambahan Pengiriman",
                                hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontFamily: "verdana_regular",
                                  fontWeight: FontWeight.w400,
                                ),
                                labelText: 'Informasi Tambahan Pengiriman',
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontFamily: "verdana_regular",
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )
                    ),
                  ),
                ),
              ],
            )
          )
        ],
      ),
      bottomNavigationBar:Padding(
        padding:EdgeInsets.all(15.0),
        child: this.HOrder.jenisPengiriman!=0?
              (
                this.HOrder.statusPengiriman!=4?
                  ElevatedButton(
                    onPressed: (){
                        updateDariPenjual();
                    },
                    child: Text(ketStatusPengiriman[this.HOrder.statusPengiriman-1]),
                  )
                  :
                  SizedBox()
              )
            :
            ElevatedButton(
              onPressed: (){
                  //
                  sudahDiambil();
              },
              child: Text("Sudah Diambil"),
            )
      )
    );
  }

  Widget _buildMenuItem(int idx) {
    if(arrDetailOrder[idx].isPaket==0){
      return Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                Expanded(
                  flex:3,
                  child:Image.network(
                            globals.imgAddMakanan+arrDetailOrder[idx].arrFoto[0],
                            fit: BoxFit.cover,
                            height: 75.0,
                            width: 75.0)
                ),
                SizedBox(width:20.0),
                Expanded(
                  flex:6,
                  child:Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(arrDetailOrder[idx].namaBarang,
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold)),
                        SizedBox(height: 3.0),
                        Text("Rp "+myFormat.format(arrDetailOrder[idx].harga.toInt()).toString(),
                          style: TextStyle(
                            fontSize: 15.0,
                            color: globals.customGrey,
                            fontWeight: FontWeight.bold)),
                        ]
                      ),
                ),
                Expanded(
                  flex:2,
                  child: Text(arrDetailOrder[idx].qty.toString()+"x")
                ),
              ]
		  );
    }
    else{
        return Row(
                mainAxisAlignment: MainAxisAlignment.center, 
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  Expanded(
                    flex:3,
                    child:Container(
                      child: CarouselSlider(
                      options: CarouselOptions(),
                      items: arrDetailOrder[idx].arrFoto
                          .map((item) => Container(
                                child: Center(
                                    child:
                                        Image.network(globals.imgAddMakanan+item, fit: BoxFit.cover, width: 60.0)),
                              ))
                          .toList(),
                    ))
                    
                    /*Image.network(
                              globals.imgAddMakanan+arrDetailOrder[idx].arrFoto[0],
                              fit: BoxFit.cover,
                              height: 75.0,
                              width: 75.0)*/
                  ),
                  SizedBox(width:20.0),
                  Expanded(
                    flex:6,
                    child:Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text(arrDetailOrder[idx].namaBarang,
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.0),
                          ListView.builder(
                              shrinkWrap: true,
                              primary: false,
                              physics: ScrollPhysics(),
                              itemCount: arrDetailOrder[idx].arrDetail.length==0 ? 1 : arrDetailOrder[idx].arrDetail.length,
                              itemBuilder: (context,idxx){
                              if(arrDetailOrder[idx].arrDetail.length==0){
                                return Text("no data");
                              }
                              else{
                                //return Text("+");
                                return Text(arrDetailOrder[idx].arrDetail[idxx].qty.toString()+" - "+arrDetailOrder[idx].arrDetail[idxx].namaBarang);
                              }
                              }
                          ),
                          SizedBox(height:3.0),
                          Text("Rp "+myFormat.format(arrDetailOrder[idx].harga.toInt()).toString(),
                            style: TextStyle(
                              fontSize: 15.0,
                              color: globals.customGrey,
                              fontWeight:FontWeight.bold)),
                          ]
                        ),
                  ),
                  Expanded(
                    flex:2,
                    child: Text(arrDetailOrder[idx].qty.toString()+"x")
                  ),
                ]
		          );
    }
  }

  Future<String> getDetailWaste() async{
    var url = Uri.parse(globals.ipnumber+'getDetailListOrderan');
    setState(() {
      arrDetailOrder.clear();
    });
    await http
            .post(url, body: {'horder':HOrder.idHOrder.toString()})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                print(data);
                for (int i = 0; i < data.length; i++) {
                  int idDailyWaste = int.parse(data[i]['idDailyWaste'].toString());
                  int isPaket = int.parse(data[i]['isPaket'].toString());
                  int idBarang = null;
                  if(data[i]['idBarang']!=null){
                    idBarang = int.parse(data[i]['idBarang'].toString());
                  }
                  String namaBarang = data[i]['namaBarang'];
                  int qty = int.parse(data[i]['qty'].toString());
                  double harga = (data[i]['harga'].toInt()).toDouble();
                  double rating = data[i]['rating'].toDouble();
                  String comment = data[i]['comment'].toString();
                  int idDOrder = data[i]['idDOrder'].toInt();
                  var foto = data[i]['foto'];
                  List<String> arrFoto = List.empty(growable: true);
                  for(int j=0;j<foto.length;j++){
                    arrFoto.add(foto[j]);
                  }
                  
                  var detailPaket = data[i]['detailPaket'];
                  List<ClassDetailWaste> arrDetail = List.empty(growable: true);
                  for(int j=0;j<detailPaket.length;j++){
                    ClassDetailWaste baru = ClassDetailWaste(detailPaket[j]['idBarang'],detailPaket[j]['namaBarang'],detailPaket[j]['qty']);
                    arrDetail.add(baru);
                  }
                  ClassDetailOrder databaru = new ClassDetailOrder(idDailyWaste, isPaket, idBarang, 
                                                                    namaBarang, qty, harga, arrFoto, 
                                                                    arrDetail,rating,comment,idDOrder);
                  setState(() {
                    arrDetailOrder.add(databaru);
                  }); 
                }
                //print("no:"+arrDetailOrder.length.toString());
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
  Future<String> updateDariPenjual() async{
    int statusPengiriman = HOrder.statusPengiriman;
    var url = Uri.parse(globals.ipnumber+'updateHOrderPenjual');
    print(this.HOrder.idHOrder.toString()+"-"+this.infoTambahanPenjual.text);
    await http
            .post(url, body: {'idHOrder': HOrder.idHOrder.toString(), 'informasi': infoTambahanPenjual.text})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(statusPengiriman==1){
                globals.buatPushNotif(HOrder.usernamePembeli, "Pesanan Anda Diproses", "Toko "+HOrder.usernamePenjual+" sedang memproses pesanan Anda");
              }
              else if(statusPengiriman==2){
                globals.buatPushNotif(HOrder.usernamePembeli, "Pesanan Anda Dalam Perjalanan", "Silakan Menunggu Pesanan Anda");
              }
              else{
                globals.buatPushNotif(HOrder.usernamePembeli, "Pesanan Anda Telah Terkirim", "Selamat Menikmati Pesanan Anda");
              }
              Navigator.pop(context);
              //print(res);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> sudahDiambil() async{
    var url = Uri.parse(globals.ipnumber+'sudahDiambil');
    await http
            .post(url, body: {'idHOrder': HOrder.idHOrder.toString()})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              globals.buatPushNotif(HOrder.usernamePembeli, "Pesanan Telah Diterima", "Anda telah menerima Pesanan Anda. Selamat menikmati");
              Navigator.pop(context);
              //print(res);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
}