import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassDetailShoppingCart.dart';
import 'package:jangandibuang/ClassKomentar.dart';
import 'package:jangandibuang/ClassShoppingCart.dart';
import 'package:jangandibuang/checkOutPembeli.dart';
import 'package:jangandibuang/registerEmailGuest.dart';
import 'package:jangandibuang/showChat.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'ClassDailyWaste.dart';
import 'ClassDailyWastePembeli.dart';
import 'ClassDetailWaste.dart';
import 'ClassAlamat.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ListDailyWasteTokoGuest extends StatefulWidget {
  final int itemChosen;
  final ClassDailyWastePembeli detailToko;
  ListDailyWasteTokoGuest(
    {
      @required this.itemChosen,
      @required this.detailToko
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.itemChosen,this.detailToko);
}

class _MyHomePageState extends State<ListDailyWasteTokoGuest> {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  Position position = null;
  final _formKey = GlobalKey<FormState>();
  int itemChosen=-1;
  String alamat="Memuat...";
  int ongkir=-1;
  String nama="Memuat...";
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  ClassDailyWastePembeli detailToko;
  List<ClassAlamat> arrAlamatPribadi = new List.empty(growable: true);
  List<ClassAlamat> arrAlamatBantuan = new List.empty(growable: true);
  double subTotalBarang=0.0;
  double longitudeToko=0.0;
  double latitudeToko=0.0;
  _MyHomePageState(this.itemChosen,this.detailToko){
    takeFirebase();
  }
  FirebaseFirestore _firestore;
  FirebaseMessaging _firebaseMessaging;
  String tokenKu;

  @override
  void initState() {
    super.initState();
    isiShoppingCart();
    getProfilToko(detailToko.username);
    getDataPengiriman();
  }
  void isiShoppingCart(){
    if(globals.myShoppingCart!=null){
      bool ganti = false;
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
            ganti=true;
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
              ganti=true;
            }
          }
        }
      }
      if(ganti==true){
        globals.buatToast("Terjadi perubahan pada Cart Anda karena terdapat penyesuaian stok");
      }
      hitungTotalBayar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Jangan Dibuang"),
      ),
      body:ListView(
            children:<Widget>[
              Column(
                  mainAxisAlignment:MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:<Widget>[
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color:globals.customLightBlue
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 15.0,right:15.0,top:15.0,bottom:15.0),
                        child:Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child:CircleAvatar(
                                            minRadius: 60,
                                            backgroundColor: globals.customDarkBlue,
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(globals.imgAdd+detailToko.logo),
                                              minRadius: 50,
                                            ),
                                          ),
                                  ),
                                  SizedBox(width: 20.0,),
                                  Expanded(
                                    flex: 5,
                                    child:Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                detailToko.username,
                                                style: TextStyle(fontSize: 22.0,fontWeight:FontWeight.bold),
                                              ),
                                              Text(
                                                this.nama,
                                                style: TextStyle(fontSize: 14.0),
                                              ),
                                              Text(
                                                this.alamat,
                                                style: TextStyle(fontSize: 14.0),
                                              ),
                                              Text(
                                                "Ongkir/km : Rp "+myFormat.format(this.ongkir.toInt()).toString(),
                                                style: TextStyle(fontSize: 14.0),
                                              )
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                      )
                    ),
                  SizedBox(height:5.0),
                  ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        physics: ScrollPhysics(),
                        itemCount: detailToko.arrWasteDaily.length==0 ? 1 : detailToko.arrWasteDaily.length,
                        itemBuilder: (context,idx){
                          if(detailToko.arrWasteDaily.length==0){
                            return Text("no data");
                          }
                          else{
                            return Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              shadowColor: Colors.black,
                              color: detailToko.arrWasteDaily[idx].id==itemChosen?Colors.pink.shade100:Colors.white,
                              child: Padding(
                                      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0,bottom: 10.0),
                                      child: _buildMenuItem(idx)
                                    )
                            );
                          }
                        }
                      ),
                  ]
            ),
            ]
      ),
      bottomNavigationBar: Padding(
                    padding: EdgeInsets.only(left:5.0,right:5.0),
                    child: ElevatedButton(
                            onPressed: () {
                                //pilihPengiriman(context);
                                pindahCheckOut();
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                            ),
                            child: Text('Selesaikan Pesanan (Rp '+ myFormat.format(subTotalBarang).toString()+')'),
                          )
                  ),
    );
  }

  Widget _buildMenuItem(int idx) {
    if(detailToko.arrWasteDaily[idx].isPaket==0){
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
                        Image.network(
                            globals.imgAddMakanan+detailToko.arrWasteDaily[idx].arrFoto[0],
                            fit: BoxFit.cover,
                            height: 100.0,
                            width: 100.0),
                        SizedBox(height:5.0),
                        detailToko.arrWasteDaily[idx].totalRatingMakanan==0.0?SizedBox(height: 0.0,):
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 24.0,
                              ),
                              GestureDetector(
                                onTap: (){
                                  bacaKomentar(idx);
                                },
                                child:Text(double.parse(detailToko.arrWasteDaily[idx].totalRatingMakanan.toStringAsFixed(2)).toString(),
                                          style:TextStyle(
                                            decoration: TextDecoration.underline,
                                            color:Colors.blue
                                          ))
                              )
                            ],
                          ),
                      ]
                    )
                ),
                SizedBox(width:20.0),
                Expanded(
                  flex:4,
                  child:Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(detailToko.arrWasteDaily[idx].kategori,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold)),
                        SizedBox(height: 3.0),
                        Text(detailToko.arrWasteDaily[idx].namaBarang,
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold)),
                        SizedBox(height: 3.0),
                        Text(detailToko.arrWasteDaily[idx].deskripsi,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold)),
                        SizedBox(height: 3.0),
                        Text("Stok : "+detailToko.arrWasteDaily[idx].stok.toString(),
                          style: TextStyle(
                            fontSize: 15.0,
                            color: globals.customGrey,
                            fontWeight:FontWeight.bold)),
                        SizedBox(height:3.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children:<Widget>[
                            SizedBox(
                              width:30.0,
                              child:ElevatedButton(
                                    onPressed: (){
                                      if(globals.myShoppingCart==null){
                                        globals.myShoppingCart = new ClassShoppingCart(detailToko.username, globals.loginuser, 
                                          0, 0, 0, null, null, 2, new List.empty(growable: true),new List.empty(growable: true),this.ongkir.toDouble());
                                        if(detailToko.arrWasteDaily[idx].stokPesan>0){
                                          int posisi=-1;
                                          for(int i=0;i<globals.myShoppingCart.arrDetailShoppingCart.length;i++){
                                            if(globals.myShoppingCart.arrDetailShoppingCart[i].idBarang==detailToko.arrWasteDaily[idx].id){
                                              posisi=i;
                                            }
                                          }
                                          setState(() {
                                           detailToko.arrWasteDaily[idx].stokPesan--;
                                            if(detailToko.arrWasteDaily[idx].stokPesan!=0){
                                              if(posisi!=-1){
                                                globals.myShoppingCart.arrDetailShoppingCart[posisi].qty=detailToko.arrWasteDaily[idx].stokPesan;
                                              }
                                              else{
                                                ClassDetailShoppingCart dataBaru = new ClassDetailShoppingCart(detailToko.arrWasteDaily[idx].id, detailToko.arrWasteDaily[idx].stokPesan, detailToko.arrWasteDaily[idx].hargaWaste.toDouble());
                                                globals.myShoppingCart.arrDetailShoppingCart.add(dataBaru);
                                                globals.myShoppingCart.arrDetailBarang.add(detailToko.arrWasteDaily[idx]);
                                              }
                                            }
                                            else{
                                              //hapus
                                              globals.myShoppingCart.arrDetailShoppingCart.removeAt(posisi);
                                              globals.myShoppingCart.arrDetailBarang.removeAt(posisi);
                                            }
                                          });
                                        }
                                        hitungTotalBayar();
                                      }
                                      else{
                                        if(globals.myShoppingCart.usernamePenjual!=detailToko.username){
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Bersihkan Shopping Cart'),
                                                content: Text("Cart Anda berisi makanan dari toko lain. Bersihkan Cart dan Mulai Berbelanja di toko ini ?"),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Text("Ya"),
                                                    onPressed: () {
                                                      globals.myShoppingCart = new ClassShoppingCart(detailToko.username, globals.loginuser, 
                                                        0, 0, 0, null, null, 2, new List.empty(growable: true),new List.empty(growable: true),this.ongkir.toDouble());
                                                      Navigator.of(context).pop();
                                                      if(detailToko.arrWasteDaily[idx].stokPesan>0){
                                                        int posisi=-1;
                                                        for(int i=0;i<globals.myShoppingCart.arrDetailShoppingCart.length;i++){
                                                          if(globals.myShoppingCart.arrDetailShoppingCart[i].idBarang==detailToko.arrWasteDaily[idx].id){
                                                            posisi=i;
                                                          }
                                                        }
                                                        setState(() {
                                                          detailToko.arrWasteDaily[idx].stokPesan--;
                                                          if(detailToko.arrWasteDaily[idx].stokPesan!=0){
                                                            if(posisi!=-1){
                                                              globals.myShoppingCart.arrDetailShoppingCart[posisi].qty=detailToko.arrWasteDaily[idx].stokPesan;
                                                            }
                                                            else{
                                                              ClassDetailShoppingCart dataBaru = new ClassDetailShoppingCart(detailToko.arrWasteDaily[idx].id, detailToko.arrWasteDaily[idx].stokPesan, detailToko.arrWasteDaily[idx].hargaWaste.toDouble());
                                                              globals.myShoppingCart.arrDetailShoppingCart.add(dataBaru);
                                                              globals.myShoppingCart.arrDetailBarang.add(detailToko.arrWasteDaily[idx]);
                                                            }
                                                          }
                                                          else{
                                                            //hapus
                                                            globals.myShoppingCart.arrDetailShoppingCart.removeAt(posisi);
                                                            globals.myShoppingCart.arrDetailBarang.removeAt(posisi);
                                                          }
                                                        });
                                                      }
                                                      hitungTotalBayar();
                                                    },
                                                  ),
                                                  FlatButton(
                                                    child: Text("Tidak"),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                        else{
                                          if(detailToko.arrWasteDaily[idx].stokPesan>0){
                                            int posisi=-1;
                                            for(int i=0;i<globals.myShoppingCart.arrDetailShoppingCart.length;i++){
                                              if(globals.myShoppingCart.arrDetailShoppingCart[i].idBarang==detailToko.arrWasteDaily[idx].id){
                                                posisi=i;
                                              }
                                            }
                                            setState(() {
                                              detailToko.arrWasteDaily[idx].stokPesan--;
                                              if(detailToko.arrWasteDaily[idx].stokPesan!=0){
                                                if(posisi!=-1){
                                                  globals.myShoppingCart.arrDetailShoppingCart[posisi].qty=detailToko.arrWasteDaily[idx].stokPesan;
                                                }
                                                else{
                                                  ClassDetailShoppingCart dataBaru = new ClassDetailShoppingCart(detailToko.arrWasteDaily[idx].id, detailToko.arrWasteDaily[idx].stokPesan, detailToko.arrWasteDaily[idx].hargaWaste.toDouble());
                                                  globals.myShoppingCart.arrDetailShoppingCart.add(dataBaru);
                                                  globals.myShoppingCart.arrDetailBarang.add(detailToko.arrWasteDaily[idx]);
                                                }
                                              }
                                              else{
                                                //hapus
                                                globals.myShoppingCart.arrDetailShoppingCart.removeAt(posisi);
                                                globals.myShoppingCart.arrDetailBarang.removeAt(posisi);
                                              }
                                            });
                                          }
                                          hitungTotalBayar();
                                        }
                                      }
                                    },
                                    child: Text('-'),
                                  ),
                            ),
                            SizedBox(width:5.0),
                            Text(detailToko.arrWasteDaily[idx].stokPesan.toString()),
                            SizedBox(width:5.0),
                            SizedBox(
                              width:30.0,
                              child:ElevatedButton(
                                    onPressed: (){
                                        if(globals.myShoppingCart==null){
                                          globals.myShoppingCart = new ClassShoppingCart(detailToko.username, globals.loginuser, 
                                            0, 0, 0, null, null, 2, new List.empty(growable: true),new List.empty(growable: true),this.ongkir.toDouble());
                                          if(detailToko.arrWasteDaily[idx].stokPesan+1<=detailToko.arrWasteDaily[idx].stok){
                                            int posisi=-1;
                                            for(int i=0;i<globals.myShoppingCart.arrDetailShoppingCart.length;i++){
                                              if(globals.myShoppingCart.arrDetailShoppingCart[i].idBarang==detailToko.arrWasteDaily[idx].id){
                                                posisi=i;
                                              }
                                            }
                                            setState(() {
                                              detailToko.arrWasteDaily[idx].stokPesan++;
                                              if(detailToko.arrWasteDaily[idx].stokPesan!=0){
                                                if(posisi!=-1){
                                                  globals.myShoppingCart.arrDetailShoppingCart[posisi].qty=detailToko.arrWasteDaily[idx].stokPesan;
                                                }
                                                else{
                                                  ClassDetailShoppingCart dataBaru = new ClassDetailShoppingCart(detailToko.arrWasteDaily[idx].id, detailToko.arrWasteDaily[idx].stokPesan, detailToko.arrWasteDaily[idx].hargaWaste.toDouble());
                                                  globals.myShoppingCart.arrDetailShoppingCart.add(dataBaru);
                                                  globals.myShoppingCart.arrDetailBarang.add(detailToko.arrWasteDaily[idx]);
                                                }
                                              }
                                              else{
                                                //hapus
                                                globals.myShoppingCart.arrDetailShoppingCart.removeAt(posisi);
                                                globals.myShoppingCart.arrDetailBarang.removeAt(posisi);
                                              }
                                            });
                                          }
                                          else{
                                            globals.buatToast("Stok tidak mencukupi");
                                          }
                                          hitungTotalBayar();
                                        }
                                        else{
                                          if(globals.myShoppingCart.usernamePenjual!=detailToko.username){
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Bersihkan Shopping Cart'),
                                                  content: Text("Cart Anda berisi makanan dari toko lain. Bersihkan Cart dan Mulai Berbelanja di toko ini ?"),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      child: Text("Ya"),
                                                      onPressed: () {
                                                        globals.myShoppingCart = new ClassShoppingCart(detailToko.username, globals.loginuser, 
                                                          0, 0, 0, null, null, 2, new List.empty(growable: true),new List.empty(growable: true),this.ongkir.toDouble());
                                                        Navigator.of(context).pop();
                                                        if(detailToko.arrWasteDaily[idx].stokPesan+1<=detailToko.arrWasteDaily[idx].stok){
                                                          int posisi=-1;
                                                          for(int i=0;i<globals.myShoppingCart.arrDetailShoppingCart.length;i++){
                                                            if(globals.myShoppingCart.arrDetailShoppingCart[i].idBarang==detailToko.arrWasteDaily[idx].id){
                                                              posisi=i;
                                                            }
                                                          }
                                                          setState(() {
                                                            detailToko.arrWasteDaily[idx].stokPesan++;
                                                            if(detailToko.arrWasteDaily[idx].stokPesan!=0){
                                                              if(posisi!=-1){
                                                                globals.myShoppingCart.arrDetailShoppingCart[posisi].qty=detailToko.arrWasteDaily[idx].stokPesan;
                                                              }
                                                              else{
                                                                ClassDetailShoppingCart dataBaru = new ClassDetailShoppingCart(detailToko.arrWasteDaily[idx].id, detailToko.arrWasteDaily[idx].stokPesan, detailToko.arrWasteDaily[idx].hargaWaste.toDouble());
                                                                globals.myShoppingCart.arrDetailShoppingCart.add(dataBaru);
                                                                globals.myShoppingCart.arrDetailBarang.add(detailToko.arrWasteDaily[idx]);
                                                              }
                                                            }
                                                            else{
                                                              //hapus
                                                              globals.myShoppingCart.arrDetailShoppingCart.removeAt(posisi);
                                                              globals.myShoppingCart.arrDetailBarang.removeAt(posisi);
                                                            }
                                                          });
                                                        }
                                                        else{
                                                          globals.buatToast("Stok tidak mencukupi");
                                                        }
                                                        hitungTotalBayar();
                                                      },
                                                    ),
                                                    FlatButton(
                                                      child: Text("Tidak"),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                          else{
                                            if(detailToko.arrWasteDaily[idx].stokPesan+1<=detailToko.arrWasteDaily[idx].stok){
                                              int posisi=-1;
                                              for(int i=0;i<globals.myShoppingCart.arrDetailShoppingCart.length;i++){
                                                if(globals.myShoppingCart.arrDetailShoppingCart[i].idBarang==detailToko.arrWasteDaily[idx].id){
                                                  posisi=i;
                                                }
                                              }
                                              setState(() {
                                                detailToko.arrWasteDaily[idx].stokPesan++;
                                                if(detailToko.arrWasteDaily[idx].stokPesan!=0){
                                                  if(posisi!=-1){
                                                    globals.myShoppingCart.arrDetailShoppingCart[posisi].qty=detailToko.arrWasteDaily[idx].stokPesan;
                                                  }
                                                  else{
                                                    ClassDetailShoppingCart dataBaru = new ClassDetailShoppingCart(detailToko.arrWasteDaily[idx].id, detailToko.arrWasteDaily[idx].stokPesan, detailToko.arrWasteDaily[idx].hargaWaste.toDouble());
                                                    globals.myShoppingCart.arrDetailShoppingCart.add(dataBaru);
                                                    globals.myShoppingCart.arrDetailBarang.add(detailToko.arrWasteDaily[idx]);
                                                  }
                                                }
                                                else{
                                                  //hapus
                                                  globals.myShoppingCart.arrDetailShoppingCart.removeAt(posisi);
                                                  globals.myShoppingCart.arrDetailBarang.removeAt(posisi);
                                                }
                                              });
                                            }
                                            else{
                                              globals.buatToast("Stok tidak mencukupi");
                                            }
                                            hitungTotalBayar();
                                          }
                                        }
                                    },
                                    child: Text('+'),
                                  ),
                            ),
                          ]
                        ),
                        ]
                      ),
                ),
                Expanded(
                  flex:2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:[
                      Text("Rp "+myFormat.format(detailToko.arrWasteDaily[idx].hargaWaste).toString()),
                    ]
                  )
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
                          items: detailToko.arrWasteDaily[idx].arrFoto
                              .map((item) => Container(
                                    child: Center(
                                        child:
                                            Image.network(globals.imgAddMakanan+item, fit: BoxFit.cover, width: 75.0)),
                                  ))
                              .toList(),
                        )),
                        SizedBox(height:5.0),
                        detailToko.arrWasteDaily[idx].totalRatingMakanan==0.0?SizedBox(height: 0.0,):
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
                                bacaKomentar(idx);
                              },
                              child: Text(double.parse(detailToko.arrWasteDaily[idx].totalRatingMakanan.toStringAsFixed(2)).toString(),
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
                    flex:4,
                    child:Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text("PAKET",
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.0),
                          Text(detailToko.arrWasteDaily[idx].namaBarang,
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.0),
                          Text("Stok : "+detailToko.arrWasteDaily[idx].stok.toString(),
                            style: TextStyle(
                              fontSize: 15.0,
                              color: globals.customGrey,
                              fontWeight:FontWeight.bold)),
                          SizedBox(height:3.0),
                          ListView.builder(
                              shrinkWrap: true,
                              primary: false,
                              physics: ScrollPhysics(),
                              itemCount: detailToko.arrWasteDaily[idx].arrDetail.length==0 ? 1 : detailToko.arrWasteDaily[idx].arrDetail.length,
                              itemBuilder: (context,idxx){
                              if(detailToko.arrWasteDaily[idx].arrDetail.length==0){
                                return Text("no data");
                              }
                              else{
                                //return Text("+");
                                return Text(detailToko.arrWasteDaily[idx].arrDetail[idxx].qty.toString()+" - "+detailToko.arrWasteDaily[idx].arrDetail[idxx].namaBarang);
                              }
                              }
                          ),
                          SizedBox(height:3.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children:<Widget>[
                              SizedBox(
                                width:30.0,
                                child:ElevatedButton(
                                      onPressed: (){
                                          if(globals.myShoppingCart==null){
                                            globals.myShoppingCart = new ClassShoppingCart(detailToko.username, globals.loginuser, 
                                              0, 0, 0, null, null, 2, new List.empty(growable: true),new List.empty(growable: true),this.ongkir.toDouble());
                                            if(detailToko.arrWasteDaily[idx].stokPesan>0){
                                              int posisi=-1;
                                              for(int i=0;i<globals.myShoppingCart.arrDetailShoppingCart.length;i++){
                                                if(globals.myShoppingCart.arrDetailShoppingCart[i].idBarang==detailToko.arrWasteDaily[idx].id){
                                                  posisi=i;
                                                }
                                              }
                                              setState(() {
                                                detailToko.arrWasteDaily[idx].stokPesan--;
                                                if(detailToko.arrWasteDaily[idx].stokPesan!=0){
                                                  if(posisi!=-1){
                                                    globals.myShoppingCart.arrDetailShoppingCart[posisi].qty=detailToko.arrWasteDaily[idx].stokPesan;
                                                  }
                                                  else{
                                                    ClassDetailShoppingCart dataBaru = new ClassDetailShoppingCart(detailToko.arrWasteDaily[idx].id, detailToko.arrWasteDaily[idx].stokPesan, detailToko.arrWasteDaily[idx].hargaWaste.toDouble());
                                                    globals.myShoppingCart.arrDetailShoppingCart.add(dataBaru);
                                                    globals.myShoppingCart.arrDetailBarang.add(detailToko.arrWasteDaily[idx]);
                                                  }
                                                }
                                                else{
                                                  //hapus
                                                  globals.myShoppingCart.arrDetailShoppingCart.removeAt(posisi);
                                                  globals.myShoppingCart.arrDetailBarang.removeAt(posisi);
                                                }
                                              });
                                            }
                                            hitungTotalBayar();
                                          }
                                          else{
                                            if(globals.myShoppingCart.usernamePenjual!=detailToko.username){
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text('Bersihkan Shopping Cart'),
                                                    content: Text("Cart Anda berisi makanan dari toko lain. Bersihkan Cart dan Mulai Berbelanja di toko ini ?"),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        child: Text("Ya"),
                                                        onPressed: () {
                                                          globals.myShoppingCart = new ClassShoppingCart(detailToko.username, globals.loginuser, 
                                                            0, 0, 0, null, null, 2, new List.empty(growable: true),new List.empty(growable: true),this.ongkir.toDouble());
                                                          Navigator.of(context).pop();
                                                          if(detailToko.arrWasteDaily[idx].stokPesan>0){
                                                            int posisi=-1;
                                                            for(int i=0;i<globals.myShoppingCart.arrDetailShoppingCart.length;i++){
                                                              if(globals.myShoppingCart.arrDetailShoppingCart[i].idBarang==detailToko.arrWasteDaily[idx].id){
                                                                posisi=i;
                                                              }
                                                            }
                                                            setState(() {
                                                              detailToko.arrWasteDaily[idx].stokPesan--;
                                                              if(detailToko.arrWasteDaily[idx].stokPesan!=0){
                                                                if(posisi!=-1){
                                                                  globals.myShoppingCart.arrDetailShoppingCart[posisi].qty=detailToko.arrWasteDaily[idx].stokPesan;
                                                                }
                                                                else{
                                                                  ClassDetailShoppingCart dataBaru = new ClassDetailShoppingCart(detailToko.arrWasteDaily[idx].id, detailToko.arrWasteDaily[idx].stokPesan, detailToko.arrWasteDaily[idx].hargaWaste.toDouble());
                                                                  globals.myShoppingCart.arrDetailShoppingCart.add(dataBaru);
                                                                  globals.myShoppingCart.arrDetailBarang.add(detailToko.arrWasteDaily[idx]);
                                                                }
                                                              }
                                                              else{
                                                                //hapus
                                                                globals.myShoppingCart.arrDetailShoppingCart.removeAt(posisi);
                                                                globals.myShoppingCart.arrDetailBarang.removeAt(posisi);
                                                              }
                                                            });
                                                          }
                                                          hitungTotalBayar();
                                                        },
                                                      ),
                                                      FlatButton(
                                                        child: Text("Tidak"),
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                            else{
                                              if(detailToko.arrWasteDaily[idx].stokPesan>0){
                                                int posisi=-1;
                                                for(int i=0;i<globals.myShoppingCart.arrDetailShoppingCart.length;i++){
                                                  if(globals.myShoppingCart.arrDetailShoppingCart[i].idBarang==detailToko.arrWasteDaily[idx].id){
                                                    posisi=i;
                                                  }
                                                }
                                                setState(() {
                                                  detailToko.arrWasteDaily[idx].stokPesan--;
                                                  if(detailToko.arrWasteDaily[idx].stokPesan!=0){
                                                    if(posisi!=-1){
                                                      globals.myShoppingCart.arrDetailShoppingCart[posisi].qty=detailToko.arrWasteDaily[idx].stokPesan;
                                                    }
                                                    else{
                                                      ClassDetailShoppingCart dataBaru = new ClassDetailShoppingCart(detailToko.arrWasteDaily[idx].id, detailToko.arrWasteDaily[idx].stokPesan, detailToko.arrWasteDaily[idx].hargaWaste.toDouble());
                                                      globals.myShoppingCart.arrDetailShoppingCart.add(dataBaru);
                                                      globals.myShoppingCart.arrDetailBarang.add(detailToko.arrWasteDaily[idx]);
                                                    }
                                                  }
                                                  else{
                                                    //hapus
                                                    globals.myShoppingCart.arrDetailShoppingCart.removeAt(posisi);
                                                    globals.myShoppingCart.arrDetailBarang.removeAt(posisi);
                                                  }
                                                });
                                              }
                                              hitungTotalBayar();
                                            }
                                          }
                                      },
                                      child: Text('-'),
                                    ),
                              ),
                              SizedBox(width:5.0),
                              Text(detailToko.arrWasteDaily[idx].stokPesan.toString()),
                              SizedBox(width:5.0),
                              SizedBox(
                                width:30.0,
                                child:ElevatedButton(
                                      onPressed: (){
                                          if(globals.myShoppingCart==null){
                                            globals.myShoppingCart = new ClassShoppingCart(detailToko.username, globals.loginuser, 
                                              0, 0, 0, null, null, 2, new List.empty(growable: true),new List.empty(growable: true),this.ongkir.toDouble());
                                            if(detailToko.arrWasteDaily[idx].stokPesan+1<=detailToko.arrWasteDaily[idx].stok){
                                              int posisi=-1;
                                              for(int i=0;i<globals.myShoppingCart.arrDetailShoppingCart.length;i++){
                                                if(globals.myShoppingCart.arrDetailShoppingCart[i].idBarang==detailToko.arrWasteDaily[idx].id){
                                                  posisi=i;
                                                }
                                              }
                                              setState(() {
                                                detailToko.arrWasteDaily[idx].stokPesan++;
                                                if(detailToko.arrWasteDaily[idx].stokPesan!=0){
                                                  if(posisi!=-1){
                                                    globals.myShoppingCart.arrDetailShoppingCart[posisi].qty=detailToko.arrWasteDaily[idx].stokPesan;
                                                  }
                                                  else{
                                                    ClassDetailShoppingCart dataBaru = new ClassDetailShoppingCart(detailToko.arrWasteDaily[idx].id, detailToko.arrWasteDaily[idx].stokPesan, detailToko.arrWasteDaily[idx].hargaWaste.toDouble());
                                                    globals.myShoppingCart.arrDetailShoppingCart.add(dataBaru);
                                                    globals.myShoppingCart.arrDetailBarang.add(detailToko.arrWasteDaily[idx]);
                                                  }
                                                }
                                                else{
                                                  //hapus
                                                  globals.myShoppingCart.arrDetailShoppingCart.removeAt(posisi);
                                                  globals.myShoppingCart.arrDetailBarang.removeAt(posisi);
                                                }
                                              });
                                            }
                                            else{
                                              globals.buatToast("Stok tidak mencukupi");
                                            }
                                            hitungTotalBayar();
                                          }
                                          else{
                                            if(globals.myShoppingCart.usernamePenjual!=detailToko.username){
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text('Bersihkan Shopping Cart'),
                                                    content: Text("Cart Anda berisi makanan dari toko lain. Bersihkan Cart dan Mulai Berbelanja di toko ini ?"),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        child: Text("Ya"),
                                                        onPressed: () {
                                                          globals.myShoppingCart = new ClassShoppingCart(detailToko.username, globals.loginuser, 
                                                            0, 0, 0, null, null, 2, new List.empty(growable: true),new List.empty(growable: true),this.ongkir.toDouble());
                                                          Navigator.of(context).pop();
                                                          if(detailToko.arrWasteDaily[idx].stokPesan+1<=detailToko.arrWasteDaily[idx].stok){
                                                            int posisi=-1;
                                                            for(int i=0;i<globals.myShoppingCart.arrDetailShoppingCart.length;i++){
                                                              if(globals.myShoppingCart.arrDetailShoppingCart[i].idBarang==detailToko.arrWasteDaily[idx].id){
                                                                posisi=i;
                                                              }
                                                            }
                                                            setState(() {
                                                              detailToko.arrWasteDaily[idx].stokPesan++;
                                                              if(detailToko.arrWasteDaily[idx].stokPesan!=0){
                                                                if(posisi!=-1){
                                                                  globals.myShoppingCart.arrDetailShoppingCart[posisi].qty=detailToko.arrWasteDaily[idx].stokPesan;
                                                                }
                                                                else{
                                                                  ClassDetailShoppingCart dataBaru = new ClassDetailShoppingCart(detailToko.arrWasteDaily[idx].id, detailToko.arrWasteDaily[idx].stokPesan, detailToko.arrWasteDaily[idx].hargaWaste.toDouble());
                                                                  globals.myShoppingCart.arrDetailShoppingCart.add(dataBaru);
                                                                  globals.myShoppingCart.arrDetailBarang.add(detailToko.arrWasteDaily[idx]);
                                                                }
                                                              }
                                                              else{
                                                                //hapus
                                                                globals.myShoppingCart.arrDetailShoppingCart.removeAt(posisi);
                                                                globals.myShoppingCart.arrDetailBarang.removeAt(posisi);
                                                              }
                                                            });
                                                          }
                                                          else{
                                                            globals.buatToast("Stok tidak mencukupi");
                                                          }
                                                          hitungTotalBayar();
                                                        },
                                                      ),
                                                      FlatButton(
                                                        child: Text("Tidak"),
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                            else{
                                              if(detailToko.arrWasteDaily[idx].stokPesan+1<=detailToko.arrWasteDaily[idx].stok){
                                                int posisi=-1;
                                                for(int i=0;i<globals.myShoppingCart.arrDetailShoppingCart.length;i++){
                                                  if(globals.myShoppingCart.arrDetailShoppingCart[i].idBarang==detailToko.arrWasteDaily[idx].id){
                                                    posisi=i;
                                                  }
                                                }
                                                setState(() {
                                                  detailToko.arrWasteDaily[idx].stokPesan++;
                                                  if(detailToko.arrWasteDaily[idx].stokPesan!=0){
                                                    if(posisi!=-1){
                                                      globals.myShoppingCart.arrDetailShoppingCart[posisi].qty=detailToko.arrWasteDaily[idx].stokPesan;
                                                    }
                                                    else{
                                                      ClassDetailShoppingCart dataBaru = new ClassDetailShoppingCart(detailToko.arrWasteDaily[idx].id,detailToko.arrWasteDaily[idx].stokPesan, detailToko.arrWasteDaily[idx].hargaWaste.toDouble());
                                                      globals.myShoppingCart.arrDetailShoppingCart.add(dataBaru);
                                                      globals.myShoppingCart.arrDetailBarang.add(detailToko.arrWasteDaily[idx]);
                                                    }
                                                  }
                                                  else{
                                                    //hapus
                                                    globals.myShoppingCart.arrDetailShoppingCart.removeAt(posisi);
                                                    globals.myShoppingCart.arrDetailBarang.removeAt(posisi);
                                                  }
                                                });
                                              }
                                              else{
                                                globals.buatToast("Stok tidak mencukupi");
                                              }
                                              hitungTotalBayar();
                                            }
                                          }
                                      },
                                      child: Text('+'),
                                    ),
                              ),
                            ]
                          ),
                          ]
                        ),
                  ),
                  Expanded(
                    flex:2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:[
                        Text("Rp "+myFormat.format(detailToko.arrWasteDaily[idx].hargaWaste).toString()),
                      ]
                    )
                  ),
                ]
		          );
    }
  }

  bacaKomentar(int idx){
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
                      itemCount: detailToko.arrWasteDaily[idx].arrKomentar.length==0 ? 1 : detailToko.arrWasteDaily[idx].arrKomentar.length,
                      itemBuilder: (context,ind){
                        if(detailToko.arrWasteDaily[idx].arrKomentar.length==0){
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
                                        child:Text(detailToko.arrWasteDaily[idx].arrKomentar[ind].username,style: TextStyle(fontWeight: FontWeight.bold),)
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
                                              Text(double.parse(detailToko.arrWasteDaily[idx].arrKomentar[ind].rating.toStringAsFixed(2)).toString())
                                            ],
                                          )
                                        ),
                                      )
                                    ],
                                  ),
                                  detailToko.arrWasteDaily[idx].arrKomentar[ind].komentar.length==0?Text("-"):
                                  Text(detailToko.arrWasteDaily[idx].arrKomentar[ind].komentar)
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
  Future<String> getProfilToko(username) async{
    var url = Uri.parse(globals.ipnumber+'getProfilToko');
    await http
            .post(url, body: {'username': username})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var almt = result['alamat'];
                setState(() {
                  this.alamat = almt[0]['alamat'];
                  this.longitudeToko = almt[0]['longitude'].toDouble();
                  this.latitudeToko = almt[0]['latitude'].toDouble();
                });

                var act = result['actor'];
                setState(() {
                  this.nama = act[0]['nama'];
                  this.ongkir = int.parse(act[0]['ongkir'].toString());
                });
                print(this.nama+"nama");
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
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
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  pilihPengiriman(BuildContext context){
    bool lanjut = false;
    for(int i=0;i<detailToko.arrWasteDaily.length;i++){
      if(detailToko.arrWasteDaily[i].stokPesan>0){
        lanjut=true;
      }
    }
    if(lanjut==false){
      globals.buatToast("Belum Ada Item yang Dipilih");
    }
    else{
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
                      Text("Pilih Lokasi Pengiriman Makanan",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),)
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
                              color: Colors.lightBlue.shade100,
                              child: Padding(
                                padding:EdgeInsets.only(left:15.0,right:15.0,top:15.0,bottom:15.0),
                                child: 
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start, 
                                    crossAxisAlignment: CrossAxisAlignment.start, 
                                    children: [
                                      Text(arrAlamatPribadi[index].alamat,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                                      Text(arrAlamatPribadi[index].kota),
                                      Text(arrAlamatPribadi[index].kodePos),
                                    ]
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
                              color: Colors.yellow.shade100,
                              child: Padding(
                                padding:EdgeInsets.only(left:15.0,right:15.0,top:15.0,bottom:15.0),
                                child: 
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start, 
                                    crossAxisAlignment: CrossAxisAlignment.start, 
                                    children: [
                                      Text(arrAlamatBantuan[index].namaPenerima,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                                      Text(arrAlamatBantuan[index].alamat),
                                      Text(arrAlamatBantuan[index].kota),
                                      Text(arrAlamatBantuan[index].kodePos),
                                      Text("CP : "+arrAlamatBantuan[index].cp+" - "+arrAlamatBantuan[index].telp),
                                    ]
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
  }

  void ambilLongitudeLatitude() async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) {
      return;
    }

    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      position = currentPosition;
      globals.longitude=position.longitude;
      globals.latitude = position.latitude;
      print("lat"+globals.latitude.toString());
      print("long"+globals.longitude.toString());
    });
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return true;
  }

  takeFirebase() async {
      await Firebase.initializeApp();
      _firestore = FirebaseFirestore.instance;
      _firebaseMessaging = FirebaseMessaging.instance;
      firebaseCloudMessaging_Listeners();
    }

    void firebaseCloudMessaging_Listeners() {
      _firebaseMessaging.getToken().then((token) {
        print("token di home dart = " + token);
        tokenKu = token;
        FirebaseFirestore.instance
            .collection("chatting")
            .get()
            .then((QuerySnapshot snapshot) {
          snapshot.docs.forEach((f) {});
        });
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('on message $message');
      });
    }
  void pindahCheckOut(){
    bool lanjut = false;
    for(int i=0;i<detailToko.arrWasteDaily.length;i++){
      if(detailToko.arrWasteDaily[i].stokPesan>0){
        lanjut=true;
      }
    }
    if(lanjut==false){
      globals.buatToast("Belum Ada Item yang Dipilih");
    }
    else{
      ambilLongitudeLatitude();
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterEmailGuest(
          detailToko:detailToko,
          ongkirperkm:ongkir,
          longitudeToko:longitudeToko,
          latitudeToko:latitudeToko,
          token:tokenKu
        )
      ) 
    ).then((value) => refreshView());
      //Navigator.pushNamed(context, "/checkOutPembeli").then((value) => refreshView());
    }
  }

  refreshView(){
    ambilDataMakanan();
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

  hitungTotalBayar(){
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