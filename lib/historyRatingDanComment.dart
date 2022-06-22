import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:jangandibuang/ClassDetailOrder.dart';
import 'package:jangandibuang/ClassDetailShoppingCart.dart';
import 'package:jangandibuang/ClassHOrder.dart';
import 'package:jangandibuang/ClassRateCommentwithId.dart';
import 'package:jangandibuang/ClassShoppingCart.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'ClassDailyWaste.dart';
import 'ClassDailyWastePembeli.dart';
import 'ClassDetailWaste.dart';
import 'ClassAlamat.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HistoryRatingDanComment extends StatefulWidget {
  final ClassHOrder HOrder;
  HistoryRatingDanComment(
    {
      @required this.HOrder
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.HOrder);
}

class _MyHomePageState extends State<HistoryRatingDanComment> {
  
  final _formKey = GlobalKey<FormState>();
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  ClassHOrder HOrder;
  List<ClassDetailOrder> arrDetailOrder = new List.empty(growable: true);
  double _ratingValueAll;
  List<double> arrRating = new List.empty(growable: true);
  TextEditingController ctrlCommentAll=new TextEditingController();
  _MyHomePageState(this.HOrder){
  }

  @override
  void initState() {
    super.initState();
    getDetailWaste();
    _ratingValueAll=this.HOrder.rating;
    ctrlCommentAll.text=this.HOrder.comment;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Rating & Comment"),
      ),
      body:ListView(
        children: <Widget>[
          Form(
            key:_formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10.0,),
                Text("Pelayanan Vendor ( "+this.HOrder.usernamePenjual+" ) Secara Keseluruhan",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0),),
                SizedBox(height: 10.0),
                RatingBar(
                  initialRating: _ratingValueAll,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  ratingWidget: RatingWidget(
                      full: Icon(Icons.star, color: Colors.orange),
                      half: Icon(
                        Icons.star_half,
                        color: Colors.orange,
                      ),
                      empty: Icon(
                        Icons.star_outline,
                        color: Colors.orange,
                      )
                    ),
                ),
                SizedBox(height: 10.0,),
                Padding(
                  padding:EdgeInsets.only(left:25.0,right:25.0),
                  child:Card(
                    color: Colors.grey.shade400,
                    child:Padding(
                          padding:EdgeInsets.all(10.0),
                          child: TextField(
                                    maxLines: 4,
                                    readOnly: true,
                                    keyboardType: TextInputType.multiline,
                                    decoration: InputDecoration.collapsed(hintText: "Yuk, ceritain pengalaman berbelanja kamu"),
                                    controller: ctrlCommentAll,
                                  ),
                          )
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
                                  color: Colors.lightGreen.shade50,
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
              ],
            )
          )
        ],
      ),
    );
  }

  Widget _buildMenuItem(int idx) {
    if(arrDetailOrder[idx].isPaket==0){
      return Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                Expanded(
                  flex:2,
                  child:Image.network(
                            globals.imgAddMakanan+arrDetailOrder[idx].arrFoto[0],
                            fit: BoxFit.cover,
                            height: 75.0,
                            width: 75.0)
                ),
                SizedBox(width:10.0),
                Expanded(
                  flex:7,
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
                            color: Colors.grey)),
                        SizedBox(height:3.0),
                        RatingBar(
                          initialRating: arrDetailOrder[idx].rating,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          ratingWidget: RatingWidget(
                              full: Icon(Icons.star, color: Colors.orange),
                              half: Icon(
                                Icons.star_half,
                                color: Colors.orange,
                              ),
                              empty: Icon(
                                Icons.star_outline,
                                color: Colors.orange,
                              )),
                          ),
                        Card(
                            color: Colors.grey.shade400,
                            child:Padding(
                                  padding:EdgeInsets.all(10.0),
                                  child: TextField(
                                            maxLines: 2,
                                            readOnly: true,
                                            keyboardType: TextInputType.multiline,
                                            decoration: InputDecoration.collapsed(hintText: "Komentar"),
                                            controller: arrDetailOrder[idx].ctrlComment,
                                          ),
                                  )
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
                    flex:2,
                    child:Container(
                      child: CarouselSlider(
                      options: CarouselOptions(),
                      items: arrDetailOrder[idx].arrFoto
                          .map((item) => Container(
                                child: Center(
                                    child:
                                        Image.network(globals.imgAddMakanan+item, fit: BoxFit.cover, width: 75.0)),
                              ))
                          .toList(),
                    ))
                    
                    /*Image.network(
                              globals.imgAddMakanan+arrDetailOrder[idx].arrFoto[0],
                              fit: BoxFit.cover,
                              height: 75.0,
                              width: 75.0)*/
                  ),
                  SizedBox(width:10.0),
                  Expanded(
                    flex:7,
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
                              color: Colors.grey)),
                          SizedBox(height:3.0),
                          RatingBar(
                            initialRating: arrDetailOrder[idx].rating,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            ratingWidget: RatingWidget(
                                full: Icon(Icons.star, color: Colors.orange),
                                half: Icon(
                                  Icons.star_half,
                                  color: Colors.orange,
                                ),
                                empty: Icon(
                                  Icons.star_outline,
                                  color: Colors.orange,
                                )),
                            ),
                          Card(
                            color: Colors.grey.shade400,
                            child:Padding(
                                  padding:EdgeInsets.all(10.0),
                                  child: TextField(
                                            maxLines: 2,
                                            readOnly: true,
                                            keyboardType: TextInputType.multiline,
                                            decoration: InputDecoration.collapsed(hintText: "Komentar"),
                                            controller: arrDetailOrder[idx].ctrlComment,
                                          ),
                                  )
                          )
                          ],
                        ),
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
                  var foto = data[i]['foto'];
                  int idDOrder = data[i]['idDOrder'].toInt();
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
                  ClassDetailOrder databaru = new ClassDetailOrder(idDailyWaste, isPaket, idBarang, namaBarang, 
                                                                    qty, harga, arrFoto, arrDetail,rating,comment,
                                                                    idDOrder);
                  databaru.ctrlComment.text=comment;
                  setState(() {
                    arrDetailOrder.add(databaru);
                    arrRating.add(0.0);
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
}