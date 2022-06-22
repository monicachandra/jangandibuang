import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jangandibuang/ClassDailyWaste.dart';
import 'package:jangandibuang/ClassDailyWastePembeli.dart';
import 'package:jangandibuang/ClassDetailShoppingCart.dart';
import 'package:jangandibuang/ClassDetailWaste.dart';
import 'package:jangandibuang/ClassKomentar.dart';
import 'package:jangandibuang/ClassShoppingCart.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'ClassAlamat.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';

class CheckOutPembeli extends StatefulWidget {
  final ClassDailyWastePembeli detailToko;
  final int ongkirperkm;
  final double longitudeToko;
  final double latitudeToko;
  CheckOutPembeli(
    {
      @required this.detailToko,
      @required this.ongkirperkm,
      @required this.longitudeToko,
      @required this.latitudeToko
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.detailToko,this.ongkirperkm,this.longitudeToko,this.latitudeToko);
}

class _MyHomePageState extends State<CheckOutPembeli> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController infoTambahan  = new TextEditingController();
  int jenisPengiriman;
  List<ClassAlamat> arrAlamatPribadi = new List.empty(growable: true);
  List<ClassAlamat> arrAlamatBantuan = new List.empty(growable: true);
  ClassAlamat alamatChosen;
  double jarakPengiriman;
  double ongkosKirim;
  int ongkirperkm;
  double longitudeToko,latitudeToko;
  double saldoUser=0.0;
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  ClassDailyWastePembeli detailToko;
  PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  _MyHomePageState(this.detailToko,this.ongkirperkm,this.longitudeToko,this.latitudeToko){}

  void generatePolyLine(double latitudePenjual,double longitudePenjual, double latitudePembeli, double longitudePembeli) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      globals.apiKeyGoogleMap,
      PointLatLng(latitudePenjual, longitudePenjual),
      PointLatLng(latitudePembeli, longitudePembeli),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    print("longi"+longitudeToko.toString());
    print("lati"+latitudeToko.toString());
    print("longi2"+longitudePembeli.toString());
    print("lati2"+latitudePembeli.toString());
    print("ongkiriperkm"+ongkirperkm.toString());
    polylines[id] = polyline;
    double totalDistance = 0.0;
    ongkosKirim=0.0;
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += calculateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }

    print("masuksini");
    print("totaldistance "+totalDistance.toString());
    totalDistance = totalDistance.ceilToDouble();
    setState(() {
      jarakPengiriman = totalDistance;
      ongkosKirim = totalDistance*ongkirperkm;
      if(ongkosKirim<10000){
        ongkosKirim=10000;
      }
      if(jenisPengiriman==0){
        ongkosKirim=0;
      }
      print("ong:"+ongkosKirim.toString());
    });
    setState(() {
      globals.myShoppingCart.biayaOngkir = ongkosKirim;
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  void initState() {
    super.initState();
    globals.myShoppingCart.usernamePembeli=globals.loginuser;
    globals.isVerified="1";
    getSaldoUser();
    getDataPengiriman();
    this.jenisPengiriman=globals.myShoppingCart.jenisPengiriman;
    print("sizearr:"+globals.myShoppingCart.arrDetailShoppingCart.length.toString());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Jangan Dibuang"),
        actions: <Widget>[
          IconButton(
            icon:Icon(Icons.attach_money),
            onPressed: (){
              Navigator.pushNamed(context, "/topUp").then((value) => getSaldoUser());
            },
          )
        ],
      ),
      body: ListView(
        children: [
          Form(
            key:_formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Padding(
                    padding: EdgeInsets.only(left:15.0,right: 15.0,top: 20.0),
                    child:Container(
                      decoration: BoxDecoration(
                          color:globals.customLightBlue,
                          borderRadius: BorderRadius.circular(12)
                        ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 3.0,right: 5.0,top: 15.0,bottom:15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Jenis Pengiriman", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0),),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Radio(value: 2, groupValue: jenisPengiriman, onChanged: handlerRadioGroup),
                                Text('Kurir'),
                                Radio(value: 0, groupValue: jenisPengiriman, onChanged: handlerRadioGroup),
                                Text('Self Pick Up'),
                                Radio(value: 1, groupValue: jenisPengiriman, onChanged: handlerRadioGroup),
                                Text('Ojek Online'),
                              ],
                            ),
                            SizedBox(height: 10.0,),
                            this.jenisPengiriman==0 ? 
                              TextFormField(
                                  controller: infoTambahan,
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
                                    hintText: "Pengambil Pesanan (Nama / telp / plat nomer)",
                                    hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontFamily: "verdana_regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                    labelText: 'Pengambil Pesanan (Nama / telp / plat nomer)',
                                    labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontFamily: "verdana_regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ) : SizedBox(height: 1.0,),
                          ],
                        ),
                      ),
                    ),
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
                        child: this.jenisPengiriman==0 ? 
                        Row(
                          mainAxisAlignment:MainAxisAlignment.start,
                          crossAxisAlignment:CrossAxisAlignment.start,
                          children:[
                            Expanded(
                              flex: 1,
                              child:Text("Tidak perlu memilih Alamat, karena self pick up")
                            )
                          ]
                        )
                        :
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child:Text("Alamat Pengiriman", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0),)
                                ),
                                Expanded(
                                  flex:1,
                                  child : GestureDetector(
                                    onTap: (){
                                      pilihPengiriman(context);
                                    },
                                    child:Container(
                                      alignment: Alignment.topRight,
                                      child:Text("Pilih Alamat Lain", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0,color: Colors.blue.shade900))
                                    )
                                  )
                                )
                              ],
                            ),
                            Divider(
                              color: Colors.black,
                              height: 20,
                            ),
                            this.alamatChosen==null?Text("Belum ada alamat yang dapat dipilih"):
                              this.alamatChosen.statusPribadi==0?
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children: [
                                    Text(alamatChosen.alamat,style:TextStyle(fontWeight: FontWeight.bold)),
                                    Text(alamatChosen.kota+", "+alamatChosen.kodePos),
                                  ],
                                )
                              :
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children: [
                                    Text(alamatChosen.namaPenerima,style:TextStyle(fontWeight: FontWeight.bold)),
                                    Text(alamatChosen.alamat),
                                    Text(alamatChosen.kota+", "+alamatChosen.kodePos),
                                    Text("CP:"+alamatChosen.cp+" - "+alamatChosen.telp)
                                  ],
                              ),
                              SizedBox(height: 10.0,),
                              TextFormField(
                                  controller: infoTambahan,
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
                                    hintText: "Informasi Tambahan",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontFamily: "verdana_regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                    labelText: 'Informasi Tambahan',
                                    labelStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontFamily: "verdana_regular",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left:15.0,right: 15.0,top: 20.0),
                    child:Container(
                      decoration: BoxDecoration(
                          color:globals.customLightBlue,
                          borderRadius: BorderRadius.circular(12)
                        ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.0,right: 5.0,top: 15.0,bottom:15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Daftar Pesanan", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0),),
                            ListView.builder(
                              shrinkWrap: true,
                              primary: false,
                              physics: ScrollPhysics(),
                              itemCount: globals.myShoppingCart.arrDetailShoppingCart.length==0 ? 1 : globals.myShoppingCart.arrDetailShoppingCart.length,
                              itemBuilder: (context,idx){
                                if(globals.myShoppingCart.arrDetailShoppingCart.length==0){
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
                                            padding: EdgeInsets.only(left: 3.0, right: 3.0, top: 10.0,bottom: 10.0),
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
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
                                              child:Text("Saldo")
                                            ),
                                            Expanded(
                                              flex:1,
                                              child:Container(
                                                alignment:Alignment.topRight,
                                                child: Text("Rp "+myFormat.format(this.saldoUser.toInt()).toString())
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
                                              child:Text("Subtotal Barang")
                                            ),
                                            Expanded(
                                              flex:1,
                                              child:Container(
                                                alignment:Alignment.topRight,
                                                child: Text("Rp "+myFormat.format(globals.myShoppingCart.totalHargaBarang.toInt()).toString())
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
                                                alignment:Alignment.topRight,
                                                child: Text("Rp "+myFormat.format(globals.myShoppingCart.biayaOngkir.toInt()).toString())
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
                                                alignment:Alignment.topRight,
                                                child: Text("Rp "+myFormat.format((globals.myShoppingCart.biayaOngkir.toInt()+globals.myShoppingCart.totalHargaBarang.toInt())).toString())
                                              )
                                            )
                                          ],
                                        ),
                                      ],
                                    )
                                  ),
                                ),
                        )
                      ]
                    )
                    
                  ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar:Padding(
        padding:EdgeInsets.all(15.0),
        child: ElevatedButton(
              onPressed: (){
                  //
                  simpanPembelian();
              },
              child: Text('Bayar'),
            ),
      )
    );
  }

  Future<String> simpanPembelian() async{
    if(globals.myShoppingCart.arrDetailShoppingCart.length==0){
      globals.buatToast("Tidak ada item untuk diCheckOut");
      Navigator.of(context).pop();
    }
    else{
      if(globals.myShoppingCart.idAlamat==null && globals.myShoppingCart.idDonasi==null && this.jenisPengiriman!=0){
        globals.buatToast("Belum ada alamat yang dipilih");
      }
      else if(this.saldoUser-globals.myShoppingCart.totalHargaBarang-globals.myShoppingCart.biayaOngkir<0){
        globals.buatToast("Saldo tidak mencukupi");
      }
      else if(this.jenisPengiriman==0 && infoTambahan.text==""){
        globals.buatToast("Harap mengisi data pengambil orderan");
      }
      else{
        var url = Uri.parse(globals.ipnumber+'checkOut');
        var cart = json.encode(globals.myShoppingCart);
        print(cart);
        await http
                .post(url, body: {'cart': cart,'infoTambahan':infoTambahan.text.length==0?"-":infoTambahan.text})
                .then((res){
                  print(res.body);
                  var result = json.decode(res.body);
                  var status = result['status'];
                  if(status!="Sukses"){
                    ambilDataMakanan();
                    globals.buatToast(status);
                  }
                  else{
                    globals.buatPushNotif(globals.myShoppingCart.usernamePenjual, "Ada Pesanan Baru", "Cek Daftar Orderan Anda");
                    globals.myShoppingCart=null;
                    globals.selectedIndexBottomNavBarPembeli=2;
                    Navigator.of(context).pushNamedAndRemoveUntil('/pembeli', (Route<dynamic> route) => false);
                  }
                })
                .catchError((err){
                  print(err);
                });
      }
    }
    return "suksess";
  }
  Future<String> ambilDataMakanan() async{
    ClassDailyWastePembeli dataWastePembeli;
    var url = Uri.parse(globals.ipnumber+'getAllWastebyUsername');
    await http
            .post(url, body: {'username':detailToko.username})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                print(data);
                for (int i = 0; i < data.length; i++) {
                  String username = data[i]['username'];
                  String logo     = data[i]['logo'];
                  double rating   = data[i]['totalRating'].toDouble();
                  List<ClassKomentar> myKomentar = List.empty(growable: true);
                  var komentarVendor = data[i]['komentar'];
                  for(int j=0;j<komentarVendor.length;j++){
                    String pembeli = komentarVendor[j]['pembeli'];
                    String komen   = komentarVendor[j]['komentar'];
                    double star   = komentarVendor[j]['star'].toDouble();
                    ClassKomentar dataKomen = new ClassKomentar(pembeli, komen, star);
                    setState(() {
                      myKomentar.add(dataKomen);
                    });
                  }
                  List<ClassDailyWaste> menu = List.empty(growable: true);
                  for(int j=0;j<data[i]['menu'].length;j++){
                    int id = int.parse(data[i]['menu'][j]['idDailyWaste'].toString());
                    int isPaket = data[i]['menu'][j]['isPaket'].toInt();
                    int idBarang = null;
                    if(data[i]['menu'][j]['idBarang']!=null){
                      idBarang = data[i]['menu'][j]['idBarang'].toInt();
                    }
                    String namaBarang = data[i]['menu'][j]['namaBarang'].toString();
                    int stok = int.parse(data[i]['menu'][j]['stok'].toString());
                    int hargaWaste = data[i]['menu'][j]['hargaWaste'].toInt();
                    int hargaAsli = data[i]['menu'][j]['hargaAsli'].toInt();

                    var foto = data[i]['menu'][j]['foto'];
                    List<String> arrFoto = List.empty(growable: true);
                    for(int k=0;k<foto.length;k++){
                      arrFoto.add(foto[k]);
                    }
                    
                    var detailPaket = data[i]['menu'][j]['detailBarang'];
                    List<ClassDetailWaste> arrDetail = List.empty(growable: true);
                    for(int k=0;k<detailPaket.length;k++){
                      ClassDetailWaste baru = ClassDetailWaste(detailPaket[k]['idBarang'].toInt(),detailPaket[k]['namaBarang'].toString(),
                                                  detailPaket[k]['qty'].toInt());
                      setState(() {
                        arrDetail.add(baru);
                      });
                    }
                    double totalRating = data[i]['menu'][j]['totalRatingMakanan'].toDouble();
                    List<ClassKomentar> arrKomentar = new List.empty(growable: true);
                    var komentar = data[i]['menu'][j]['komentarMakanan'];
                    for(int k=0;k<komentar.length;k++){
                      String pembelii = komentar[k]['pembeli'];
                      String komm     = komentar[k]['komentar'];
                      double ratestar = komentar[k]['star'].toDouble();
                      setState(() {
                        arrKomentar.add(new ClassKomentar(pembelii, komm, ratestar));
                      });
                    }
                    String kategori  = data[i]['menu'][j]['kategori'];
                    String deskripsi = data[i]['menu'][j]['deskripsi'];
                    ClassDailyWaste databaru = ClassDailyWaste(id,isPaket,idBarang,namaBarang,stok,hargaWaste,arrFoto,arrDetail,totalRating,arrKomentar,kategori,deskripsi);
                    databaru.hargaAsli=hargaAsli;
                    setState(() {
                      menu.add(databaru);
                    });
                  }
                  setState(() {
                    detailToko = new ClassDailyWastePembeli(username,logo,menu,rating,myKomentar);                    
                  });
                  isiShoppingCart();
                }
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
  
  void isiShoppingCart(){
    if(globals.myShoppingCart!=null){
      if(globals.myShoppingCart.usernamePenjual==detailToko.username){
        for(int i=globals.myShoppingCart.arrDetailShoppingCart.length-1;i>=0;i--){
          int posisiArrDetailToko = -1;
          int stokRealToko = -1;
          for(int j=0;j<detailToko.arrWasteDaily.length;j++){
            if(globals.myShoppingCart.arrDetailShoppingCart[i].idBarang==detailToko.arrWasteDaily[j].id){
              posisiArrDetailToko=j;
              stokRealToko = detailToko.arrWasteDaily[j].stok;
            }
          }
          //klo ada di shopping cart tapi di arr sdh tdk ada dihapus
          if(posisiArrDetailToko==-1){
            //hapus
            globals.myShoppingCart.arrDetailShoppingCart.removeAt(i);
            globals.myShoppingCart.arrDetailBarang.removeAt(i);
          }
          else{
            //klo ada di shopping cart dan ada di arr
            int stokCart = globals.myShoppingCart.arrDetailShoppingCart[i].qty;
            //klo stok mencukupi
            if(stokCart<=stokRealToko){
              detailToko.arrWasteDaily[posisiArrDetailToko].stokPesan=stokCart;
            }
            else{
              //klo tidak mencukupi
              detailToko.arrWasteDaily[posisiArrDetailToko].stokPesan=stokRealToko;
              globals.myShoppingCart.arrDetailShoppingCart[i].qty=stokRealToko;
            }
          }
        }
      }
      hitungTotalBayar();
    }
  }

  void handlerRadioGroup(int jenis){
    setState(() {
      this.jenisPengiriman=jenis;
      globals.myShoppingCart.jenisPengiriman=this.jenisPengiriman;
      this.infoTambahan.text="";
    });
    if(this.jenisPengiriman==0){
      //self pickup
      this.setState(() {
        alamatChosen=null;
        globals.myShoppingCart.isDonasi=0;
        globals.myShoppingCart.biayaOngkir=0;
        globals.myShoppingCart.idDonasi=null;
        globals.myShoppingCart.idAlamat=null;
      });
    }
    else{
      getDataPengiriman();
    }
  }
  Future<String> getDataPengiriman() async{
    var url = Uri.parse(globals.ipnumber+'getAlamatPengiriman');
    await http
            .post(url, body: {'username': globals.loginuser})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var alamatPribadi = result['dataPribadi'];
                for(int i=0;i<alamatPribadi.length;i++){
                  ClassAlamat alamatBaru = new ClassAlamat(0, alamatPribadi[i]['idAlamat'], alamatPribadi[i]['alamat'], 
                                                alamatPribadi[i]['kota'], alamatPribadi[i]['kodePos'], 
                                                alamatPribadi[i]['longitude'].toDouble(), alamatPribadi[i]['latitude'].toDouble(), 
                                                "", "", "", 0);
                  setState(() {
                    arrAlamatPribadi.add(alamatBaru);
                  });
                }

                var alamatBantuan = result['dataBantuan'];
                for(int i=0;i<alamatBantuan.length;i++){
                  ClassAlamat alamatBaru = new ClassAlamat(1, alamatBantuan[i]['idPenerimaBantuan'], alamatBantuan[i]['alamat'], 
                                                alamatBantuan[i]['kota'], alamatBantuan[i]['kodePos'], 
                                                alamatBantuan[i]['longitude'].toDouble(), alamatBantuan[i]['latitude'].toDouble(), 
                                                alamatBantuan[i]['namaPenerimaBantuan'], alamatBantuan[i]['contactPerson'], 
                                                alamatBantuan[i]['noTelp'], alamatBantuan[i]['jumlahPenerimaBantuan']);
                  setState(() {
                    arrAlamatBantuan.add(alamatBaru);
                  });
                }

                setState(() {
                  if(arrAlamatPribadi.length>0){
                    alamatChosen=arrAlamatPribadi[0];
                    globals.myShoppingCart.idAlamat=arrAlamatPribadi[0];
                    globals.myShoppingCart.idDonasi=null;
                    globals.myShoppingCart.isDonasi=0;
                    generatePolyLine(latitudeToko,longitudeToko,arrAlamatPribadi[0].latitude,arrAlamatPribadi[0].longitude);
                  }
                  else if(arrAlamatBantuan.length>0){
                    alamatChosen=arrAlamatBantuan[0];
                    globals.myShoppingCart.idDonasi=arrAlamatBantuan[0];
                    globals.myShoppingCart.idAlamat=null;
                    globals.myShoppingCart.isDonasi=1;
                    generatePolyLine(latitudeToko,longitudeToko,arrAlamatBantuan[0].latitude,arrAlamatBantuan[0].longitude);
                  }
                  else{
                    alamatChosen=null;
                  }
                });
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> getSaldoUser() async{
    var url = Uri.parse(globals.ipnumber+'getSaldo');
    await http
            .post(url, body: {'username': globals.loginuser})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var actor = result['actor'];
                setState(() {
                  this.saldoUser = actor['saldo'].toDouble();
                });
                print("saldo:"+saldoUser.toInt().toString());
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
  pilihPengiriman(BuildContext context){
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0)), //this right here
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex:2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[
                    Text("Pilih Lokasi Pengiriman Makanan",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),)
                  ]
                ),
              ),
              Expanded(
                flex:1,
                child: Padding(
                  padding: EdgeInsets.only(left:15.0,right: 15.0),
                  child: Text("Antar ke Alamat",style:TextStyle(fontWeight: FontWeight.bold)),
                )
              ),
              Expanded(
                flex:4,
                child: Padding(
                  padding:EdgeInsets.only(left:15.0,right:15.0,),
                  child: ListView.builder(
                      itemCount: arrAlamatPribadi.length==0 ? 1 : arrAlamatPribadi.length,
                      itemBuilder: (context,index){
                        if(arrAlamatPribadi.length==0){
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
                              child: GestureDetector(
                                      onTap:(){
                                        print("alamat pilih:"+arrAlamatPribadi[index].statusPribadi.toString()+"-"+arrAlamatPribadi[index].alamat);
                                        this.setState((){
                                          this.alamatChosen=new ClassAlamat.fromClassAlamat(arrAlamatPribadi[index]);
                                          generatePolyLine(latitudeToko,longitudeToko,arrAlamatPribadi[index].latitude,arrAlamatPribadi[index].longitude);
                                          globals.myShoppingCart.idAlamat=alamatChosen;
                                          globals.myShoppingCart.idDonasi=null;
                                          globals.myShoppingCart.isDonasi=0;
                                        });
                                        print(this.alamatChosen.statusPribadi.toString()+"-"+this.alamatChosen.alamat);
                                        Navigator.pop(context);
                                      },
                                      child:Column(
                                        mainAxisAlignment: MainAxisAlignment.start, 
                                        crossAxisAlignment: CrossAxisAlignment.start, 
                                        children: [
                                          Text(arrAlamatPribadi[index].alamat,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                                          Text(arrAlamatPribadi[index].kota+", "+arrAlamatPribadi[index].kodePos),
                                        ]
                                      )
                                    )
                            )
                          );
                        }
                      }
                    ),
                )
              ),
              SizedBox(height: 30.0,),
              Expanded(
                flex:1,
                child: Padding(
                  padding: EdgeInsets.only(left:15.0,right: 15.0),
                  child: Text("Beli untuk Donasi",style: TextStyle(fontWeight: FontWeight.bold),),
                )
              ),
              Expanded(
                flex:4,
                child: Padding(
                  padding:EdgeInsets.only(left:15.0,right:15.0,),
                  child: ListView.builder(
                      itemCount: arrAlamatBantuan.length==0 ? 1 : arrAlamatBantuan.length,
                      itemBuilder: (context,index){
                        if(arrAlamatBantuan.length==0){
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
                              child: GestureDetector(
                                      onTap:(){
                                        print("alamatbantu pilih:"+arrAlamatBantuan[index].statusPribadi.toString()+"-"+arrAlamatBantuan[index].alamat);
                                        this.setState((){
                                          this.alamatChosen=new ClassAlamat.fromClassAlamat(arrAlamatBantuan[index]);
                                          generatePolyLine(latitudeToko,longitudeToko,arrAlamatBantuan[index].latitude,arrAlamatBantuan[index].longitude);
                                          globals.myShoppingCart.idDonasi=alamatChosen;
                                          globals.myShoppingCart.idAlamat=null;
                                          globals.myShoppingCart.isDonasi=1;
                                        });
                                        print(this.alamatChosen.statusPribadi.toString()+"-"+this.alamatChosen.alamat);
                                        Navigator.pop(context);
                                      },
                                      child:Column(
                                          mainAxisAlignment: MainAxisAlignment.start, 
                                          crossAxisAlignment: CrossAxisAlignment.start, 
                                          children: [
                                            Text(arrAlamatBantuan[index].namaPenerima,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                                            Text(arrAlamatBantuan[index].alamat),
                                            Text(arrAlamatBantuan[index].kota+", "+arrAlamatBantuan[index].kodePos),
                                            Text("CP : "+arrAlamatBantuan[index].cp+" - "+arrAlamatBantuan[index].telp),
                                          ]
                                        )
                                    )
                            )
                          );
                        }
                      }
                    ),
                )
              ),
              SizedBox(height: 15.0,)
            ],
          )
        );
      });
    },
    );
  }
  Widget _buildMenuItem(int idx) {
    if(globals.myShoppingCart.arrDetailBarang[idx].isPaket==0){
      return Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                Expanded(
                  flex:2,
                  child:Image.network(
                            globals.imgAddMakanan+globals.myShoppingCart.arrDetailBarang[idx].arrFoto[0],
                            fit: BoxFit.cover,
                            height: 50.0,
                            width: 50.0)
                ),
                SizedBox(width:3.0),
                Expanded(
                  flex:5,
                  child:Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(globals.myShoppingCart.arrDetailBarang[idx].namaBarang,
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold)),
                        SizedBox(height: 3.0),
                        Text("Rp "+myFormat.format(globals.myShoppingCart.arrDetailShoppingCart[idx].harga.toInt()).toString(),
                          style: TextStyle(
                            fontSize: 15.0,
                            color: globals.customGrey)),
                        ]
                      ),
                ),
                Expanded(
                    flex:2,
                    child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width:25.0,
                                child:ElevatedButton(
                                  onPressed: (){
                                    if(globals.myShoppingCart.arrDetailShoppingCart[idx].qty>0){
                                      int posisi=-1;
                                      for(int i=0;i<detailToko.arrWasteDaily.length;i++){
                                        if(globals.myShoppingCart.arrDetailShoppingCart[idx].idBarang==detailToko.arrWasteDaily[i].id){
                                          posisi=i;
                                          print("pos:"+posisi.toString());
                                        }
                                      }
                                      setState(() {
                                        detailToko.arrWasteDaily[posisi].stokPesan--;
                                      });
                                      if(detailToko.arrWasteDaily[posisi].stokPesan!=0){
                                        setState(() {
                                          globals.myShoppingCart.arrDetailShoppingCart[idx].qty=detailToko.arrWasteDaily[posisi].stokPesan;
                                        });
                                      }
                                      else{
                                        //hapus
                                        setState(() {
                                          globals.myShoppingCart.arrDetailShoppingCart.removeAt(idx);
                                          globals.myShoppingCart.arrDetailBarang.removeAt(idx);
                                        });
                                        if(globals.myShoppingCart.arrDetailShoppingCart.length==0){
                                          globals.buatToast("Tidak ada item untuk diCheckOut");
                                          Navigator.of(context).pop();
                                        }
                                      }
                                    }
                                    hitungTotalBayar();
                                  },
                                  child:Text("-")
                                )
                              ),
                              SizedBox(width:3.0),
                              Text(globals.myShoppingCart.arrDetailShoppingCart[idx].qty.toString()),
                              SizedBox(width:3.0),
                              SizedBox(
                                width:25.0,
                                child:ElevatedButton(
                                  onPressed: (){
                                    int posisi=-1;
                                    for(int i=0;i<detailToko.arrWasteDaily.length;i++){
                                      if(globals.myShoppingCart.arrDetailShoppingCart[idx].idBarang==detailToko.arrWasteDaily[i].id){
                                        posisi=i;
                                        print("pos:"+posisi.toString());
                                      }
                                    }
                                    if(detailToko.arrWasteDaily[posisi].stokPesan+1<=detailToko.arrWasteDaily[posisi].stok){
                                      setState(() {
                                        detailToko.arrWasteDaily[posisi].stokPesan++;
                                      });
                                      if(detailToko.arrWasteDaily[idx].stokPesan!=0){
                                        setState(() {
                                          globals.myShoppingCart.arrDetailShoppingCart[idx].qty=detailToko.arrWasteDaily[posisi].stokPesan;
                                        });
                                      }
                                    }
                                    else{
                                      globals.buatToast("Stok tidak mencukupi");
                                    }
                                    hitungTotalBayar();
                                  },
                                  child:Text("+")
                                )
                              ),
                            ],
                          )
                    //Text(globals.myShoppingCart.arrDetailShoppingCart[idx].qty.toString()+"x")
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
                    flex:2,
                    child:Container(
                      child: CarouselSlider(
                      options: CarouselOptions(),
                      items: globals.myShoppingCart.arrDetailBarang[idx].arrFoto
                          .map((item) => Container(
                                child: Center(
                                    child:
                                        Image.network(globals.imgAddMakanan+item, fit: BoxFit.cover, width: 60.0)),
                              ))
                          .toList(),
                    ))
                  ),
                  SizedBox(width:3.0),
                  Expanded(
                    flex:5,
                    child:Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text(globals.myShoppingCart.arrDetailBarang[idx].namaBarang,
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.0),
                          ListView.builder(
                              shrinkWrap: true,
                              primary: false,
                              physics: ScrollPhysics(),
                              itemCount: globals.myShoppingCart.arrDetailBarang[idx].arrDetail.length==0 ? 1 : globals.myShoppingCart.arrDetailBarang[idx].arrDetail.length,
                              itemBuilder: (context,idxx){
                                if(globals.myShoppingCart.arrDetailBarang[idx].arrDetail.length==0){
                                  return Text("no data");
                                }
                                else{
                                  //return Text("+");
                                  return Text(globals.myShoppingCart.arrDetailBarang[idx].arrDetail[idxx].qty.toString()+" - "+globals.myShoppingCart.arrDetailBarang[idx].arrDetail[idxx].namaBarang);
                                }
                              }
                          ),
                          SizedBox(height:3.0),
                          Text("Rp "+myFormat.format(globals.myShoppingCart.arrDetailShoppingCart[idx].harga.toInt()).toString(),
                            style: TextStyle(
                              fontSize: 15.0,
                              color: globals.customGrey)),
                          ]
                        ),
                  ),
                  Expanded(
                    flex:2,
                    child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width:25.0,
                                child:ElevatedButton(
                                  onPressed: (){
                                    if(globals.myShoppingCart.arrDetailShoppingCart[idx].qty>0){
                                      int posisi=-1;
                                      for(int i=0;i<detailToko.arrWasteDaily.length;i++){
                                        if(globals.myShoppingCart.arrDetailShoppingCart[idx].idBarang==detailToko.arrWasteDaily[i].id){
                                          posisi=i;
                                          print("pos:"+posisi.toString());
                                        }
                                      }
                                      setState(() {
                                        detailToko.arrWasteDaily[posisi].stokPesan--;
                                      });
                                      if(detailToko.arrWasteDaily[posisi].stokPesan!=0){
                                        setState(() {
                                          globals.myShoppingCart.arrDetailShoppingCart[idx].qty=detailToko.arrWasteDaily[posisi].stokPesan;
                                        });
                                      }
                                      else{
                                        //hapus
                                        setState(() {
                                          globals.myShoppingCart.arrDetailShoppingCart.removeAt(idx);
                                          globals.myShoppingCart.arrDetailBarang.removeAt(idx);
                                        });
                                        if(globals.myShoppingCart.arrDetailShoppingCart.length==0){
                                          globals.buatToast("Tidak ada item untuk diCheckOut");
                                          Navigator.of(context).pop();
                                        }
                                      }
                                    }
                                    hitungTotalBayar();
                                  },
                                  child:Text("-")
                                )
                              ),
                              SizedBox(width:3.0),
                              Text(globals.myShoppingCart.arrDetailShoppingCart[idx].qty.toString()),
                              SizedBox(width:3.0),
                              SizedBox(
                                width:25.0,
                                child:ElevatedButton(
                                  onPressed: (){
                                    int posisi=-1;
                                    for(int i=0;i<detailToko.arrWasteDaily.length;i++){
                                      if(globals.myShoppingCart.arrDetailShoppingCart[idx].idBarang==detailToko.arrWasteDaily[i].id){
                                        posisi=i;
                                        print("pos:"+posisi.toString());
                                      }
                                    }
                                    if(detailToko.arrWasteDaily[posisi].stokPesan+1<=detailToko.arrWasteDaily[posisi].stok){
                                      setState(() {
                                        detailToko.arrWasteDaily[posisi].stokPesan++;
                                      });
                                      if(detailToko.arrWasteDaily[idx].stokPesan!=0){
                                        setState(() {
                                          globals.myShoppingCart.arrDetailShoppingCart[idx].qty=detailToko.arrWasteDaily[posisi].stokPesan;
                                        });
                                      }
                                    }
                                    else{
                                      globals.buatToast("Stok tidak mencukupi");
                                    }
                                    hitungTotalBayar();
                                  },
                                  child:Text("+")
                                )
                              ),
                            ],
                          )
                    //Text(globals.myShoppingCart.arrDetailShoppingCart[idx].qty.toString()+"x")
                  ),
                ]
		          );
    }
  }
  hitungTotalBayar(){
    double subTotalBarang=0.0;
    setState(() {
      subTotalBarang=0.0;
    });
    for(int i=0;i<detailToko.arrWasteDaily.length;i++){
      if(detailToko.arrWasteDaily[i].stokPesan>0){
        setState(() {
          subTotalBarang+=(detailToko.arrWasteDaily[i].hargaWaste.toDouble()*detailToko.arrWasteDaily[i].stokPesan);
        });
      }
    }
    setState(() {
      globals.myShoppingCart.totalHargaBarang=subTotalBarang;
    });
  }
}