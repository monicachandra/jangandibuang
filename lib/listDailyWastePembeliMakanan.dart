import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:jangandibuang/ClassKomentar.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'ClassDailyWaste.dart';
import 'ClassDailyWastePembeli.dart';
import 'ClassDetailWaste.dart';
import 'listDailyWasteToko.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ListDailyWastePembeliMakanan extends StatefulWidget {
  final String filter;
  final int kodeList;
  ListDailyWastePembeliMakanan(
    {
      @required this.filter,
      @required this.kodeList
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.filter,this.kodeList);
}

class _MyHomePageState extends State<ListDailyWastePembeliMakanan> {
  final _formKey = GlobalKey<FormState>();
  List<ClassDailyWastePembeli> arrWaste = new List.empty(growable: true);
  String tanggal="";
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  String filter="";
  int kodeList=-1;
  XFile _image;
  ImagePicker picker = ImagePicker();
  bool isLoading = false;

 _MyHomePageState(this.filter,this.kodeList){
    print("filter adl "+this.filter+"-"+this.kodeList.toString());
  }

  @override
  void initState() {
    super.initState();
    tanggal=DateFormat("dd-MM-yyyy").format(DateTime.now()).toString();
    if(this.kodeList!=6){
      getAllWastePembeli(filter,kodeList);
    }
    else{
      getImageFromCamera();
    }
  }

  Future getImageFromCamera() async{
    var image = await picker.pickImage(source:ImageSource.camera);
    setState((){
      _image = image;
    });
    kirimFotokeWebService(this.context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text("DAFTAR WASTE "+globals.getDeskripsiTanggal(tanggal)),
      ),
      body:ModalProgressHUD(
        child:Form(
                key:_formKey,
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.0),
                    Expanded(
                      flex:8,
                      child:Padding(
                      padding : EdgeInsets.only(left:15.0,right:15.0,top:15.0),
                      child:ListView.builder(
                              itemCount: arrWaste.length==0 ? 1 : arrWaste.length,
                              itemBuilder: (context,index){
                                if(arrWaste.length==0){
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
                                            child: _buildWasteItem(index,context)
                                    )
                                  );
                                }
                              }
                            )
                      ),
                    )
                  ],
                )
              ),inAsyncCall: isLoading
      )
    );
  }

  Widget _buildWasteItem(int index,BuildContext context) {
    return GestureDetector(
      onTap: (){
        pindahDetail(index,-1,context);
        //print(index);
      },
      child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    crossAxisAlignment: CrossAxisAlignment.center, 
                    children: [
                      Expanded(
                        flex:2,
                        child:
                        CircleAvatar(
                          minRadius: 40,
                          backgroundColor: globals.customDarkBlue,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(globals.imgAdd+arrWaste[index].logo),
                            minRadius: 35,
                          ),
                        ),
                      ),
                      SizedBox(width:20.0),
                      Expanded(
                        flex:5,
                        child:Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(arrWaste[index].username,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                            arrWaste[index].rating==0.0?SizedBox(height:0.0):
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 24.0,
                                ),
                                //Text(arrWaste[index].rating.toString())
                                GestureDetector(
                                  onTap:(){
                                    bacaKomentar(index,context);
                                  },
                                  child: Text(double.parse(arrWaste[index].rating.toStringAsFixed(2)).toString(),
                                              style:TextStyle(
                                                decoration: TextDecoration.underline,
                                                color:Colors.blue
                                              )),
                                )
                              ],
                            )
                          ],
                        )
                      ),
                    ]
                ),
                ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: ScrollPhysics(),
                  itemCount: arrWaste[index].arrWasteDaily.length==0 ? 1 : arrWaste[index].arrWasteDaily.length,
                  itemBuilder: (context,idx){
                    if(arrWaste[index].arrWasteDaily==0){
                      return Text("no data");
                    }
                    else{
                      return Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        shadowColor: Colors.black,
                        color: Colors.white,
                        child: Padding(
                                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0,bottom: 10.0),
                                child: _buildMenuItem(index,idx,context)//Text("halo")//_buildMenuItem(index,idx)//Text("halo")
                              )
                      );
                    }
                  }
                ),
              ],
            ),
    );
  }

  Widget _buildMenuItem(int index,int idx,BuildContext context) {
    if(arrWaste[index].arrWasteDaily[idx].isPaket==0){
      return GestureDetector(
        onTap: (){
          pindahDetail(index, arrWaste[index].arrWasteDaily[idx].id,context);
        },
        child: Row(
                mainAxisAlignment: MainAxisAlignment.center, 
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  Expanded(
                    flex:3,
                    child:Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment:CrossAxisAlignment.center,
                          children:[
                            FittedBox(child: 
                              Image.network(
                                globals.imgAddMakanan+arrWaste[index].arrWasteDaily[idx].arrFoto[0],
                                fit: BoxFit.fill,
                                height: 100.0,
                                width: 100.0),
                              fit: BoxFit.fill,
                            ),
                            SizedBox(height:5.0),
                            arrWaste[index].arrWasteDaily[idx].totalRatingMakanan==0.0?SizedBox(height: 0.0,):
                            Row(
                              mainAxisAlignment:MainAxisAlignment.start,
                              crossAxisAlignment:CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 24.0,
                                ),
                                GestureDetector(
                                  onTap:(){
                                    bacaKomentarMakanan(index,idx,context);
                                  },
                                  child: Text(double.parse(arrWaste[index].arrWasteDaily[idx].totalRatingMakanan.toStringAsFixed(2)).toString(),
                                              style:TextStyle(
                                                decoration: TextDecoration.underline,
                                                color:Colors.blue
                                              )),
                                )
                              ],
                            )
                          ]
                        )
                  ),
                  SizedBox(width:20.0),
                  Expanded(
                    flex:6,
                    child:Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text(arrWaste[index].arrWasteDaily[idx].kategori.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.0),
                          Text(arrWaste[index].arrWasteDaily[idx].namaBarang,
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.0),
                          Text(arrWaste[index].arrWasteDaily[idx].deskripsi,
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.0),
                          Text("Stok : "+arrWaste[index].arrWasteDaily[idx].stok.toString(),
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.grey)),
                          Align(
                            alignment:Alignment.bottomRight,
                            child:Text("Rp "+myFormat.format(arrWaste[index].arrWasteDaily[idx].hargaWaste).toString(),
                                        style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold))
                          )
                          ]
                        ),
                  ),
                ]
              )
      );
    }
    else{
      return GestureDetector(
        onTap: (){
          pindahDetail(index, arrWaste[index].arrWasteDaily[idx].id,context);
        },
        child: Row(
                mainAxisAlignment: MainAxisAlignment.center, 
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  Expanded(
                    flex:3,
                    child:Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment:CrossAxisAlignment.center,
                            children:[
                              Container(
                                child: CarouselSlider(
                                options: CarouselOptions(),
                                items: arrWaste[index].arrWasteDaily[idx].arrFoto
                                    .map((item) => Container(
                                          child: Center(
                                              child:
                                                  Image.network(globals.imgAddMakanan+item, fit: BoxFit.cover, width: 75.0)),
                                        ))
                                    .toList(),
                              )),
                              SizedBox(height:5.0),
                              arrWaste[index].arrWasteDaily[idx].totalRatingMakanan==0.0?SizedBox(height: 0.0,):
                              Row(
                                mainAxisAlignment:MainAxisAlignment.start,
                                crossAxisAlignment:CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 24.0,
                                  ),
                                  GestureDetector(
                                    onTap:(){
                                      bacaKomentarMakanan(index,idx,context);
                                    },
                                    child: Text(double.parse(arrWaste[index].arrWasteDaily[idx].totalRatingMakanan.toStringAsFixed(2)).toString(),
                                                style:TextStyle(
                                                  decoration: TextDecoration.underline,
                                                  color:Colors.blue
                                                )),
                                  )
                                ],
                              )
                            ]
                          )
                  ),
                  SizedBox(width:20.0),
                  Expanded(
                    flex:6,
                    child:Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text("PAKET",
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.0),
                          Text(arrWaste[index].arrWasteDaily[idx].namaBarang,
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.0),
                          Text("Stok : "+arrWaste[index].arrWasteDaily[idx].stok.toString(),
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.grey)),
                          SizedBox(height:3.0),
                          ListView.builder(
                              shrinkWrap: true,
                              primary: false,
                              physics: ScrollPhysics(),
                              itemCount: arrWaste[index].arrWasteDaily[idx].arrDetail.length==0 ? 1 : arrWaste[index].arrWasteDaily[idx].arrDetail.length,
                              itemBuilder: (context,idxx){
                              if(arrWaste[index].arrWasteDaily[idx].arrDetail.length==0){
                                return Text("no data");
                              }
                              else{
                                //return Text("+");
                                return Text(arrWaste[index].arrWasteDaily[idx].arrDetail[idxx].qty.toString()+" - "+arrWaste[index].arrWasteDaily[idx].arrDetail[idxx].namaBarang);
                              }
                              }
                          ),
                          Align(
                            alignment:Alignment.bottomRight,
                            child:Text("Rp "+myFormat.format(arrWaste[index].arrWasteDaily[idx].hargaWaste).toString(),
                                        style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold))
                          )
                          ]
                        ),
                  ),
                ]
              ),
      );
    }
  }

  Future<String> getAllWastePembeli(String filter,int kodeList) async{
    print("filter yg dipakai : "+filter);
    var url = Uri.parse(globals.ipnumber+'getAllWastePembeli');
    setState(() {
      arrWaste.clear();
    });
    await http
            .post(url, body: {'filter':filter,'kodeList':kodeList.toString(),'loginUser':globals.loginuser,'longitude':globals.longitude.toString(),'latitude':globals.latitude.toString()})
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
                  List<ClassDailyWaste> menu = List.empty(growable: true);
                  List<ClassKomentar> myKomentar = List.empty(growable: true);
                  var komentarVendor = data[i]['komentar'];
                  for(int j=0;j<komentarVendor.length;j++){
                    String pembeli = komentarVendor[j]['pembeli'];
                    String komen="";
                    if(komentarVendor[j]['komentar']=="" || komentarVendor[j]['komentar']==null){
                      komen="-";
                    }
                    else{
                      komen=komentarVendor[j]['komentar'].toString();
                    }
                    double star   = komentarVendor[j]['star'].toDouble();
                    ClassKomentar dataKomen = new ClassKomentar(pembeli, komen,star);
                    setState(() {
                      myKomentar.add(dataKomen);
                    });
                  }
                  for(int j=0;j<data[i]['menu'].length;j++){
                    int id = data[i]['menu'][j]['idDailyWaste'].toInt();
                    int isPaket = data[i]['menu'][j]['isPaket'].toInt();
                    int idBarang = null;
                    if(data[i]['menu'][j]['idBarang']!=null){
                      idBarang = data[i]['menu'][j]['idBarang'].toInt();
                    }
                    String namaBarang = data[i]['menu'][j]['namaBarang'].toString();
                    int stok = data[i]['menu'][j]['stok'].toInt();
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
                      ClassDetailWaste baru = ClassDetailWaste(detailPaket[k]['idBarang'].toInt(),detailPaket[k]['namaBarang'],
                                                  detailPaket[k]['qty'].toInt());
                      arrDetail.add(baru);
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
                    ClassDailyWaste databaru = ClassDailyWaste(id,isPaket,idBarang,namaBarang,
                                                stok,hargaWaste,arrFoto,arrDetail,totalRating,arrKomentar,kategori,deskripsi);
                    databaru.hargaAsli=hargaAsli;
                    setState(() {
                      menu.add(databaru);
                    });
                  }
                  ClassDailyWastePembeli dataWastePembeli = ClassDailyWastePembeli(username,logo,menu,rating,myKomentar);
                  setState(() {
                    arrWaste.add(dataWastePembeli);
                  }); 
                }
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> kirimFotokeWebService(BuildContext context) async{
    String base64Image = "";
    String namaFile = "";
    if(_image!=null){
      setState(() {
        arrWaste.clear();
        isLoading=true;
      });
      base64Image = base64Encode(File(_image.path).readAsBytesSync());
      namaFile = _image.path.split("/").last;
      var url = Uri.parse(globals.ipnumber+'compareFotoMakanan');
      await http
                .post(url,
                      body:{'username':globals.loginuser,'m_image':base64Image,'m_filename':namaFile})
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
                      List<ClassDailyWaste> menu = List.empty(growable: true);
                      List<ClassKomentar> myKomentar = List.empty(growable: true);
                      var komentarVendor = data[i]['komentar'];
                      for(int j=0;j<komentarVendor.length;j++){
                        String pembeli = komentarVendor[j]['pembeli'];
                        String komen="";
                        if(komentarVendor[j]['komentar']=="" || komentarVendor[j]['komentar']==null){
                          komen="-";
                        }
                        else{
                          komen=komentarVendor[j]['komentar'].toString();
                        }
                        double star   = komentarVendor[j]['star'].toDouble();
                        ClassKomentar dataKomen = new ClassKomentar(pembeli, komen,star);
                        setState(() {
                          myKomentar.add(dataKomen);
                        });
                      }
                      for(int j=0;j<data[i]['menu'].length;j++){
                        int id = data[i]['menu'][j]['idDailyWaste'].toInt();
                        int isPaket = data[i]['menu'][j]['isPaket'].toInt();
                        int idBarang = null;
                        if(data[i]['menu'][j]['idBarang']!=null){
                          idBarang = data[i]['menu'][j]['idBarang'].toInt();
                        }
                        String namaBarang = data[i]['menu'][j]['namaBarang'].toString();
                        int stok = data[i]['menu'][j]['stok'].toInt();
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
                          ClassDetailWaste baru = ClassDetailWaste(detailPaket[k]['idBarang'].toInt(),detailPaket[k]['namaBarang'],
                                                      detailPaket[k]['qty'].toInt());
                          arrDetail.add(baru);
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
                        ClassDailyWaste databaru = ClassDailyWaste(id,isPaket,idBarang,namaBarang,
                                                    stok,hargaWaste,arrFoto,arrDetail,totalRating,arrKomentar,kategori,deskripsi);
                        databaru.hargaAsli=hargaAsli;
                        setState(() {
                          menu.add(databaru);
                        });
                      }
                      ClassDailyWastePembeli dataWastePembeli = ClassDailyWastePembeli(username,logo,menu,rating,myKomentar);
                      setState(() {
                        arrWaste.add(dataWastePembeli);
                      }); 
                    }
                    setState(() {
                      isLoading = false;
                    });
                  }
                })
                .catchError((err){
                  print(err);
                });
      _image=null;
      return "Sukses";
    }
    else{
      globals.buatToast("Anda belum memilih foto");
      Navigator.of(context).pop();
      return "Cancel";
    }
  }
  
  Future<String> pindahDetail(int index,int idMakanan,BuildContext context) async{
    ClassDailyWastePembeli dataWastePembeli;
    var url = Uri.parse(globals.ipnumber+'getAllWastebyUsername');
    await http
            .post(url, body: {'username':arrWaste[index].username})
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
                    dataWastePembeli = new ClassDailyWastePembeli(username,logo,menu,rating,myKomentar);                    
                  });
                }
              }
            })
            .catchError((err){
              print(err);
            });
    if(kodeList!=6){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListDailyWasteToko(
            itemChosen:idMakanan,
            detailToko:dataWastePembeli
          )
        ) 
      ).then((value) => getAllWastePembeli(filter, kodeList));
    }
    else{
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListDailyWasteToko(
            itemChosen:idMakanan,
            detailToko:dataWastePembeli
          )
        ) 
      ).then((value) => Navigator.of(context).pop());
    }
    return "suksess";
  }

  bacaKomentar(int index,BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)), //this right here
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment:CrossAxisAlignment.start,
              children: [
                SizedBox(height:10.0),
                Center(
                  child:Text("Apa kata mereka?",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex:6,
                  child: Padding(
                    padding:EdgeInsets.all(10.0),
                    child:ListView.builder(
                      itemCount: arrWaste[index].arrKomentar.length==0 ? 1 : arrWaste[index].arrKomentar.length,
                      itemBuilder: (context,ind){
                        if(arrWaste[index].arrKomentar.length==0){
                          return Text("no data");
                        }
                        else{
                          //if(arrWaste[index].arrKomentar[ind].komentar.length>0){
                            return Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              shadowColor: Colors.black,
                              color: globals.customLightBlue,
                              child: Padding(
                                padding:EdgeInsets.only(left:15.0,right:15.0,top:15.0,bottom:15.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:[
                                    Row(
                                      mainAxisAlignment:MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex:1,
                                          child:Text(arrWaste[index].arrKomentar[ind].username,style: TextStyle(fontWeight: FontWeight.bold),)
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            alignment: Alignment.topRight,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 24.0,
                                                ),
                                                Text(double.parse(arrWaste[index].arrKomentar[ind].rating.toStringAsFixed(2)).toString())
                                              ],
                                            )
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(arrWaste[index].arrKomentar[ind].komentar)
                                  ]
                                )
                              )
                            );
                          //}
                        }
                      }
                    ),
                  )
                ),
              ],
            )
          );
        });
      }
    );
  }

  bacaKomentarMakanan(int index,int idx,BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)), //this right here
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment:CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0,),
                Center(child: Text("Apa kata mereka?",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),),
                Expanded(
                  flex:6,
                  child: Padding(
                    padding:EdgeInsets.all(10.0),
                    child:ListView.builder(
                      itemCount: arrWaste[index].arrWasteDaily[idx].arrKomentar.length==0 ? 1 : arrWaste[index].arrWasteDaily[idx].arrKomentar.length,
                      itemBuilder: (context,ind){
                        if(arrWaste[index].arrWasteDaily[idx].arrKomentar.length==0){
                          return Text("no data");
                        }
                        else{
                          //if(arrWaste[index].arrWasteDaily[idx].arrKomentar[ind].komentar.length>0){
                            return Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              shadowColor: Colors.black,
                              color: globals.customLightBlue,
                              child: Padding(
                                padding:EdgeInsets.only(left:15.0,right:15.0,top:15.0,bottom:15.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:[
                                    Row(
                                      mainAxisAlignment:MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex:1,
                                          child:Text(arrWaste[index].arrWasteDaily[idx].arrKomentar[ind].username,style: TextStyle(fontWeight: FontWeight.bold),)
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            alignment: Alignment.topRight,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 24.0,
                                                ),
                                                Text(double.parse(arrWaste[index].arrWasteDaily[idx].arrKomentar[ind].rating.toStringAsFixed(2)).toString())
                                              ],
                                            )
                                          ),
                                        )
                                      ],
                                    ),
                                    arrWaste[index].arrWasteDaily[idx].arrKomentar[ind].komentar.length==0?Text("-"):
                                    Text(arrWaste[index].arrWasteDaily[idx].arrKomentar[ind].komentar)
                                  ]
                                )
                              )
                            );
                          //}
                        }
                      }
                    ),
                  )
                ),
              ],
            )
          );
        });
      }
    );
  }
}