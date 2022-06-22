import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassDailyWasteTanggal.dart';
import 'package:jangandibuang/ClassDetailWaste.dart';
import 'package:jangandibuang/ClassKomentar.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DetailPostinganVendor extends StatefulWidget {
  final String username;
  final String tglAwal;
  final String tglAkhir;
  DetailPostinganVendor(
    {
      @required this.username,
      @required this.tglAwal,
      @required this.tglAkhir
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.username,this.tglAwal,this.tglAkhir);
}
class _MyHomePageState extends State<DetailPostinganVendor> {
  final _formKey = GlobalKey<FormState>();
  String username="";
  String tglAwal="";
  String tglAkhir="";
  List<ClassDailyWasteTanggal> arrWaste = new List.empty(growable: true);
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');

  @override
  void initState() {
    super.initState();
    getAllWaste();
  }
  _MyHomePageState(this.username,this.tglAwal,this.tglAkhir){
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text("Penjual Terpasif : "+this.username),
      ),
      body:Form(
        key:_formKey,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height:15.0),
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
                              flex: 1,
                              child:Text(arrWaste[index].kategori.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color:globals.customGrey)),
                            ),
                            Expanded(
                              flex: 1,
                              child:Container(
                                      alignment:Alignment.topRight,
                                      child: Text(arrWaste[index].tanggal,
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.bold,
                                                    color:globals.customGrey))
                                    )
                            )
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
                        Text("Terjual:"+arrWaste[index].stok.toString(),
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
                              flex: 1,
                              child:Text("PAKET",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color:globals.customGrey)),
                            ),
                            Expanded(
                              flex: 1,
                              child:Container(
                                      alignment:Alignment.topRight,
                                      child: Text(arrWaste[index].tanggal,
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.bold,
                                                    color:globals.customGrey))
                                    )
                            )
                          ],
                        ),
                          SizedBox(height: 3.0),
                          Text(arrWaste[index].namaBarang,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.0),
                          Text("Terjual:"+arrWaste[index].stok.toString(),
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
  Future<String> getAllWaste() async{
    var url = Uri.parse(globals.ipnumber+'getAllWasteInPeriode');
    setState(() {
      arrWaste.clear();
    });
    await http
            .post(url, body: {'username':this.username,'tglAwal':this.tglAwal,'tglAkhir':this.tglAkhir})
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
                  String tanggal = globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(data[i]['tanggal'])).toString());
                  ClassDailyWasteTanggal databaru = new ClassDailyWasteTanggal(id,isPaket,idBarang,namaBarang,stok,hargaWaste,arrFoto,arrDetail,totalRating,arrKomentar,kategori,deskripsi,tanggal);
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
}