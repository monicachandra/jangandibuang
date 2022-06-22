import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:jangandibuang/ClassKomentar.dart';
import 'package:jangandibuang/listDailyWastePembeliMakananGuest.dart';
import 'package:jangandibuang/listDailyWastePembeliMakanan.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'ClassDailyWaste.dart';
import 'ClassDailyWastePembeli.dart';
import 'ClassDetailWaste.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geolocator/geolocator.dart';

class DashboardGuest extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<DashboardGuest> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController searchFilter  = new TextEditingController();
  List<ClassDailyWastePembeli> arrWaste = new List.empty(growable: true);
  String tanggal="";
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  String filter;

  List<String> keterangan = new List.empty(growable: true);
  List<String> imageAdd = new List.empty(growable: true);
  final List<Color> warna = <Color>[Colors.amber.shade200, Colors.lightGreen.shade200,Colors.lightBlue.shade200,
                                    Colors.purple.shade200,Colors.pink.shade100,Colors.yellow.shade100];

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  Position position = null;

  @override
  void initState() {
    super.initState();
    globals.selectedIndexBottomNavBarPembeli=0;
    filter="";
    tanggal=DateFormat("dd-MM-yyyy").format(DateTime.now()).toString();

    keterangan.add("Lokasi Terdekat");keterangan.add("Beli Lagi");keterangan.add("Best Seller");
    keterangan.add("Paling Murah");keterangan.add("Paling Laku");keterangan.add("Produk Sejenis");

    imageAdd.add("location.png");imageAdd.add("belilagi.png");imageAdd.add("bintang.png");
    imageAdd.add("murah.png");imageAdd.add("pita.png");imageAdd.add("kaca.png");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Jangan Dibuang"),
      ),
      body:Form(
        key:_formKey,
        child:Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 25.0),
            Expanded(
              flex:1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  Text("DAFTAR WASTE", style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold),)
                ]
              ),
            ),
            Expanded(
              flex:1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  Text(globals.getDeskripsiTanggal(tanggal),style: TextStyle(fontSize: 15.0))
                ]
              ),
            ),
            Expanded(
              flex:1,
              child: Padding(
                padding:  EdgeInsets.only(left:25.0,right:25.0),
                child:TextFormField(
                    onChanged: (text) {
                      setState(() {
                        filter=text;
                      });
                    },
                    onFieldSubmitted:(text){
                      pindahFilter(filter, 0,context);
                    },
                    controller: searchFilter,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      focusColor: Colors.white,
                      prefixIcon: Icon(
                        Icons.search,
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
                      hintText: "Filter",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: "verdana_regular",
                        fontWeight: FontWeight.w400,
                      ),
                      labelText: 'Filter',
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: "verdana_regular",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              )
            ),
            SizedBox(height:15.0),
            Expanded(
              flex:8,
              child:Padding(
              padding : EdgeInsets.only(left:15.0,right:15.0,top:15.0),
              child:
                    GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          shrinkWrap: true,
                          primary: false,
                          physics:ClampingScrollPhysics(),
                          children: List.generate(keterangan.length, (index) {
                            return GestureDetector(
                              onTap: (){
                                int idIndex = index+1;
                                pindahFilter(filter, idIndex,context);
                              },
                              child:Card(
                                      elevation: 10.0,
                                      shape: RoundedRectangleBorder(  
                                        borderRadius: BorderRadius.circular(15.0),  
                                      ),
                                      color: warna[index],  
                                      child:
                                          Padding(
                                            padding: EdgeInsets.only(left: 2.0, right: 2.0, top: 10.0,bottom: 2.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  flex:5,
                                                  child:Image.asset('assets/'+imageAdd[index],
                                                        height:100,
                                                        width:100),
                                                ),
                                                SizedBox(height: 10.0,),
                                                Expanded(
                                                  flex: 2,
                                                  child:Text(keterangan[index],style:TextStyle(fontWeight: FontWeight.bold,fontSize: 12.0)),
                                                )
                                              ],
                                            )
                                          )
                                    )
                            );
                            
                            
                          }))
              ),
            )
          ],
        )
      )
    );
  }

  Widget _buildWasteItem(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.center, 
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              Expanded(
                flex:3,
                child:Image.network(
                          globals.imgAddMakanan+arrWaste[index].logo,
                          fit: BoxFit.cover,
                          height: 75.0,
                          width: 75.0)
              ),
              SizedBox(width:20.0),
              Expanded(
                flex:6,
                child:Text(arrWaste[index].username,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),)
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
                        child: _buildMenuItem(index,idx)
                      )
              );
            }
          }
        ),
      ],
    );
    
  }

  Widget _buildMenuItem(int index,int idx) {
    if(arrWaste[index].arrWasteDaily[idx].isPaket==0){
      return Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                Expanded(
                  flex:3,
                  child:Image.network(
                            globals.imgAddMakanan+arrWaste[index].arrWasteDaily[idx].arrFoto[0],
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
                        Text(arrWaste[index].arrWasteDaily[idx].namaBarang,
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold)),
                        SizedBox(height: 3.0),
                        Text("Stok:"+arrWaste[index].arrWasteDaily[idx].stok.toString(),
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey)),
                        SizedBox(height:3.0),
                        ]
                      ),
                ),
                Expanded(
                  flex:2,
                  child: Text(myFormat.format(arrWaste[index].arrWasteDaily[idx].hargaWaste).toString())
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
                      items: arrWaste[index].arrWasteDaily[idx].arrFoto
                          .map((item) => Container(
                                child: Center(
                                    child:
                                        Image.network(globals.imgAddMakanan+item, fit: BoxFit.cover, width: 75.0)),
                              ))
                          .toList(),
                    ))
                    
                    /*Image.network(
                              globals.imgAddMakanan+arrWaste[index].arrWasteDaily[idx].arrFoto[0],
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
                          Text(arrWaste[index].arrWasteDaily[idx].namaBarang,
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold)),
                          SizedBox(height: 3.0),
                          Text("Stok:"+arrWaste[index].arrWasteDaily[idx].stok.toString(),
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
                          )
                          ]
                        ),
                  ),
                  Expanded(
                    flex:2,
                    child: Text(myFormat.format(arrWaste[index].arrWasteDaily[idx].hargaWaste).toString())
                  ),
                ]
		          );
    }
  }

  void pindahFilter(String filter,int kodeList,BuildContext context){
    if(kodeList==1){
      ambilLongitudeLatitude(context);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListDailyWastePembeliMakananGuest(
          filter:filter,
          kodeList:kodeList
        )
      ) 
    );
  }

  void ambilLongitudeLatitude(BuildContext context) async {
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
}