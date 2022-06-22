import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassDetailWaste.dart';
import 'package:jangandibuang/ClassKomentar.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'ClassDailyWaste.dart';
import 'ClassDetailWaste.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ListDailyWaste extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ListDailyWaste> {
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  List<ClassDailyWaste> arrWaste = new List.empty(growable: true);
  String tanggal="";
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  int idArrAdjust = -1;
  int realStokAdjust = -1;
  int adjustStok = 0;
  bool _isObscure = true;
  TextEditingController pwd       = new TextEditingController();

  @override
  void initState() {
    super.initState();
    tanggal=DateFormat("dd-MM-yyyy").format(DateTime.now()).toString();
    getAllWaste();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text("Daftar Waste "+globals.getDeskripsiTanggal(tanggal)),
      ),
      body: Form(
        key:_formKey,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex:8,
                child:Padding(
                padding : EdgeInsets.only(top:10.0,left:15.0,right:15.0),
                child:
                      ListView.builder(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(globals.isVerified=="0"){
            globals.buatToast("Verifikasi E-mail terlebih dahulu");
          }
          else if(globals.vendorTerverifikasi=="0"){
            globals.buatToast("Akun Anda belum diverifikasi oleh Admin");
          }
          else{
            tambahDailyWaste();
          }
        },
        child: const Icon(Icons.add),
      )
    );
  }

  Widget _buildDailyItem(int index) {
    if(arrWaste[index].isPaket==0){
      return Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                Expanded(
                  flex:3,
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment:CrossAxisAlignment.center,
                    children:[
                      FittedBox(
                        child: Image.network(
                                globals.imgAddMakanan+arrWaste[index].arrFoto[0],
                                fit: BoxFit.fill,
                                width:100.0,
                                height:100.0
                                ),
                        fit: BoxFit.fill,
                      ),
                      SizedBox(height:5.0),
                      arrWaste[index].totalRatingMakanan==0.0?SizedBox(height: 0.0,):
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
                              bacaKomentarMakanan(index);
                            },
                            child: Text(double.parse(arrWaste[index].totalRatingMakanan.toStringAsFixed(2)).toString(),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex:1,
                              child:Text(arrWaste[index].kategori.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        color:globals.customGrey)),
                            ),
                            Expanded(
                              flex:1,
                              child:Container(
                                child:Align(
                                  alignment:Alignment.topRight,
                                  child:GestureDetector(
                                    onTap: (){
                                      if(arrWaste[index].stok>0){
                                        openDialogAdjust(index);
                                      }
                                      else{
                                        globals.buatToast("Stok 0, tidak bisa melakukan sinkronisasi penjualan offline");
                                      }
                                    },
                                    child:Icon(
                                          Icons.sync,
                                          color: Colors.black,
                                          size: 24.0,
                                        ),
                                  )
                                )
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.0),
                        Text(arrWaste[index].namaBarang,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold)),
                        SizedBox(height: 3.0),
                        Text(arrWaste[index].deskripsi,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: globals.customGrey,
                            fontWeight: FontWeight.bold)),
                        SizedBox(height: 3.0),
                        Text("Stok:"+arrWaste[index].stok.toString(),
                          style: TextStyle(
                            fontSize: 15.0,
                            color: globals.customGrey,
                            fontWeight: FontWeight.bold)),
                        SizedBox(height:3.0),
                        Align(
                          alignment:Alignment.bottomRight,
                          child:Text("Rp "+myFormat.format(arrWaste[index].hargaWaste).toString(),
                                      style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold))
                        )
                        ]
                      ),
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
                    child:Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment:CrossAxisAlignment.center,
                      children:[
                        Container(
                          child: CarouselSlider(
                          options: CarouselOptions(),
                          items: arrWaste[index].arrFoto
                              .map((item) => Container(
                                    child: Center(
                                        child:
                                            Image.network(globals.imgAddMakanan+item, fit: BoxFit.fill, width: 75.0, height:100.0)),
                                  ))
                              .toList(),
                        )),
                        SizedBox(height:5.0),
                        arrWaste[index].totalRatingMakanan==0.0?SizedBox(height: 0.0,):
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
                                bacaKomentarMakanan(index);
                              },
                              child: Text(double.parse(arrWaste[index].totalRatingMakanan.toStringAsFixed(2)).toString(),
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
                          Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex:1,
                              child:Text('PAKET',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        color:globals.customGrey)),
                            ),
                            Expanded(
                              flex:1,
                              child:Container(
                                child:Align(
                                  alignment:Alignment.topRight,
                                  child:GestureDetector(
                                    onTap: (){
                                      if(arrWaste[index].stok>0){
                                        openDialogAdjust(index);
                                      }
                                      else{
                                        globals.buatToast("Stok 0, tidak bisa melakukan sinkronisasi penjualan offline");
                                      }
                                    },
                                    child:Icon(
                                          Icons.sync,
                                          color: Colors.black,
                                          size: 24.0,
                                        ),
                                  )
                                )
                              ),
                            ),
                          ],
                        ),
                          SizedBox(height: 3.0),
                          Text(arrWaste[index].namaBarang,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.0),
                          Text("Stok:"+arrWaste[index].stok.toString(),
                            style: TextStyle(
                              fontSize: 15.0,
                              color: globals.customGrey,
                              fontWeight: FontWeight.bold)),
                          SizedBox(height:3.0),
                          ListView.builder(
                              shrinkWrap: true,
                              primary: false,
                              physics: ScrollPhysics(),
                              itemCount: arrWaste[index].arrDetail.length==0 ? 1 : arrWaste[index].arrDetail.length,
                              itemBuilder: (context,idx){
                              if(arrWaste[index].arrDetail.length==0){
                                return Text("no data");
                              }
                              else{
                                //return Text("+");
                                return Text(arrWaste[index].arrDetail[idx].qty.toString()+" - "+arrWaste[index].arrDetail[idx].namaBarang);
                              }
                              }
                          ),
                          Align(
                            alignment:Alignment.bottomRight,
                            child:Text("Rp "+myFormat.format(arrWaste[index].hargaWaste).toString(),
                                        style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold))
                          )
                        ]
                        ),
                  ),
                ]
		          );
    }
  }

  openDialogAdjust(int index){
    setState(() {
      idArrAdjust = arrWaste[index].id;
      realStokAdjust = arrWaste[index].stok;
      adjustStok = 0;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)), //this right here
            child: Form(
              key:_formKey2,
              child:Container(
                      height: 325,
                      child:Padding(
                        padding:EdgeInsets.all(15.0),
                        child:Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[
                                Center(
                                  child:Text("Penjualan Offline",style:TextStyle(fontWeight: FontWeight.bold,fontSize:16.0)),
                                ),
                                SizedBox(height:15.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children:[
                                    Expanded(
                                      flex:2,
                                      child:arrWaste[index].isPaket==0?
                                        FittedBox(
                                          child: Image.network(
                                                  globals.imgAddMakanan+arrWaste[index].arrFoto[0],
                                                  fit: BoxFit.fill,
                                                  width:100.0,
                                                  height:100.0
                                                  ),
                                          fit: BoxFit.fill,
                                        ):
                                        Container(
                                          child: CarouselSlider(
                                          options: CarouselOptions(),
                                          items: arrWaste[index].arrFoto
                                              .map((item) => Container(
                                                    child: Center(
                                                        child:
                                                            Image.network(globals.imgAddMakanan+item, fit: BoxFit.fill, width: 75.0, height:100.0)),
                                                  ))
                                              .toList(),
                                        )),
                                    ),
                                    SizedBox(width:10.0),
                                    Expanded(
                                      flex:5,
                                      child:Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(arrWaste[index].namaBarang,
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold)),
                                          SizedBox(height: 3.0),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex:4,
                                                child: Text('Stok Saat Ini'),
                                              ),
                                              Expanded(
                                                flex:4,
                                                child: Text(realStokAdjust.toString())
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex:4,
                                                child: Text('Qty Jual'),
                                              ),
                                              Expanded(
                                                flex:4,
                                                child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children:<Widget>[
                                                          SizedBox(
                                                            width:30.0,
                                                            child:ElevatedButton(
                                                                  onPressed: (){
                                                                    setState(() {
                                                                      //arrChosen[index].stok--;
                                                                      if(adjustStok>0){
                                                                        adjustStok--;
                                                                      }
                                                                    });
                                                                  },
                                                                  child: Text('-'),
                                                                ),
                                                          ),
                                                          SizedBox(width:5.0),
                                                          Text(adjustStok.toString()),
                                                          SizedBox(width:5.0),
                                                          SizedBox(
                                                            width:30.0,
                                                            child:ElevatedButton(
                                                                  onPressed: (){
                                                                    setState(() {
                                                                      //arrChosen[index].stok++;
                                                                      if(adjustStok+1<=realStokAdjust){
                                                                        adjustStok++;
                                                                      }
                                                                      else{
                                                                        globals.buatToast("Penambahan qty melebihi kapasitas stok");
                                                                      }
                                                                    });
                                                                  },
                                                                  child: Text('+'),
                                                                ),
                                                          ),
                                                        ]
                                                      ),
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                      
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
                                      child:TextFormField(
                                                controller: pwd,
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Password belum terisi';
                                                  }
                                                  else if(!(value.contains(RegExp(r'[a-z]')))){
                                                    return 'Password belum mengandung huruf kecil';
                                                  }
                                                  else if(!(value.contains(RegExp(r'[A-Z]')))){
                                                    return 'Password belum mengandung huruf besar';
                                                  }
                                                  else if(!(value.contains(RegExp(r'[0-9]')))){
                                                    return 'Password minimal mengandung 1 angka';
                                                  }
                                                  return null;
                                                },
                                                obscureText: _isObscure,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                decoration: InputDecoration(
                                                  focusColor: Colors.white,
                                                  prefixIcon: Icon(
                                                    Icons.lock_outline,
                                                    color: Colors.grey,
                                                  ),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      _isObscure ? Icons.visibility : Icons.visibility_off,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _isObscure = !_isObscure;
                                                      });
                                                    },
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
                                                  hintText: "Password",
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                    fontFamily: "verdana_regular",
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  labelText: 'Password',
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
                                                if (_formKey2.currentState.validate()) {
                                                  // If the form is valid, display a snackbar. In the real world,
                                                  // you'd often call a server or save the information in a database.
                                                  /*ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Processing Data')),
                                                  );*/
                                                  adjustStokVendor();
                                                }
                                              },
                                              child: const Text('Sinkronisasi Stok'),
                                            ),
                                    )
                                  ]
                                )
                              ]
                            )
                      )
                    )
            )
          );
        });
      }
    );
  }
  bacaKomentarMakanan(int index){
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
                Center(
                  child:Text("Apa kata mereka?",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
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
                                  arrWaste[index].arrKomentar[ind].komentar.length==0?Text("-"):Text(arrWaste[index].arrKomentar[ind].komentar)
                                ]
                              )
                            )
                          );
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
  void tambahDailyWaste(){
    Navigator.pushNamed(context, "/addDailyWaste").then((value) => refreshView());
  }
  
  refreshView() {
    getAllWaste();
    setState((){});
  }

  Future<String> getAllWaste() async{
    var url = Uri.parse(globals.ipnumber+'getAllWaste');
    setState(() {
      arrWaste.clear();
    });
    await http
            .post(url, body: {'username':globals.loginuser})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                print(data);
                for (int i = 0; i < data.length; i++) {
                  int id = data[i]['idDaily'].toInt();
                  int isPaket = data[i]['isPaket'].toInt();
                  int idBarang = null;
                  if(data[i]['idBarang']!=null){
                    idBarang = data[i]['idBarang'].toInt();
                  }
                  String namaBarang = data[i]['namaBarang'].toString();
                  int stok = data[i]['stok'].toInt();
                  int hargaWaste = data[i]['hargaWaste'].toInt();
                  
                  var foto = data[i]['foto'];
                  List<String> arrFoto = List.empty(growable: true);
                  for(int j=0;j<foto.length;j++){
                    arrFoto.add(foto[j]);
                  }
                  
                  var detailPaket = data[i]['detailPaket'];
                  List<ClassDetailWaste> arrDetail = List.empty(growable: true);
                  for(int j=0;j<detailPaket.length;j++){
                    ClassDetailWaste baru = ClassDetailWaste(detailPaket[j]['idBarang'].toInt(),
                                                              detailPaket[j]['namaBarang'].toString(),
                                                              detailPaket[j]['qty'].toInt());
                    arrDetail.add(baru);
                  }
                  double totalRating = data[i]['totalRatingMakanan'].toDouble();
                  List<ClassKomentar> arrKomentar = new List.empty(growable: true);
                  var komentar = data[i]['komentarMakanan'];
                  for(int j=0;j<komentar.length;j++){
                    String pembelii = komentar[j]['pembeli'];
                    String komm     = komentar[j]['komentar'];
                    double ratestar= komentar[j]['star'].toDouble();
                    setState(() {
                      arrKomentar.add(new ClassKomentar(pembelii, komm, ratestar));
                    });
                  }
                  String kategori  = data[i]['kategori'];
                  String deskripsi = data[i]['deskripsi'];
                  ClassDailyWaste databaru = ClassDailyWaste(id,isPaket,idBarang,namaBarang,stok,hargaWaste,arrFoto,arrDetail,totalRating,arrKomentar,kategori,deskripsi);
                  setState(() {
                    arrWaste.add(databaru);
                  }); 
                }
                print("halo");
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> adjustStokVendor() async{
    var url = Uri.parse(globals.ipnumber+'adjustStokVendor');
    await http
            .post(url, body: {'idDailyWaste': idArrAdjust.toString(),'qty': adjustStok.toString(),'password':pwd.text.toString()})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status!="Sukses"){
                globals.buatToast(status);
              }
              else{
                pwd.text="";
                globals.buatToast("Sukses Sinkronisasi Stok");
                Navigator.of(context).pop();
              }
              getAllWaste();
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
}