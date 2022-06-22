import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/addPenerimaBantuan.dart';
import 'package:jangandibuang/editPenerimaBantuan.dart';
import 'package:jangandibuang/tambahAlamatPembeli.dart';
import 'package:jangandibuang/ubahAlamatPembeli.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'ClassAlamat.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class DaftarAlamatPembeli extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<DaftarAlamatPembeli> {
  final formKey = GlobalKey<FormState>();
  List<ClassAlamat> arrAlamatPribadi = new List.empty(growable: true);
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  Position position = null;

  @override
  void initState() {
    super.initState();
    getDataPengiriman(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Daftar Alamat"),
      ),
      body:Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height:10.0),
              Expanded(
                flex:9,
                child:Padding(
                  padding: EdgeInsets.only(left: 15.0,right: 15.0),
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex:5,
                                      child:Column(
                                              mainAxisAlignment: MainAxisAlignment.start, 
                                              crossAxisAlignment: CrossAxisAlignment.start, 
                                              children: [
                                                Text(arrAlamatPribadi[index].alamat,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                                                Text(arrAlamatPribadi[index].kota+", "+arrAlamatPribadi[index].kodePos),
                                                Text("Catatan : "+arrAlamatPribadi[index].keterangan),
                                              ]
                                            )
                                    ),
                                    arrAlamatPribadi[index].usernameInput==globals.loginuser?
                                    Expanded(
                                      flex: 1,
                                      child: GestureDetector(
                                        onTap: (){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => UbahAlamatPembeli(
                                                username:globals.loginuser,
                                                alamat:arrAlamatPribadi[index].alamat,
                                                kodePos: arrAlamatPribadi[index].kodePos,
                                                keterangan: arrAlamatPribadi[index].keterangan,
                                                idAlamat : arrAlamatPribadi[index].idAlamat,
                                                longi : arrAlamatPribadi[index].longitude,
                                                lati : arrAlamatPribadi[index].latitude
                                              )
                                            )
                                          ).then((value) => getDataPengiriman());
                                        },
                                        child: Icon(Icons.edit),
                                      ),
                                    ):Expanded(
                                      flex: 1,
                                      child: SizedBox()
                                    )
                                  ],
                                )
                              )
                            );
                          }
                        }
                      ),
                )
              )
            ]
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        if(globals.isVerified==0){
          globals.buatToast("Verifikasi E-mail terlebih dahulu");
        }
        else{
          ambilLongitudeLatitude(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TambahAlamatPembeli()
            ) 
          ).then((value) => getDataPengiriman());
        }
      },
      child: const Icon(Icons.add),
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
      print("latii"+globals.latitude.toString());
      print("longii"+globals.longitude.toString());
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

  Future<String> getDataPengiriman() async{
    setState(() {
      arrAlamatPribadi.clear();
    });
    var url = Uri.parse(globals.ipnumber+'getAllAlamatPembeli');
    await http
            .post(url,body:{'username':globals.loginuser})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var alamatPribadi = result['data'];
                for(int i=0;i<alamatPribadi.length;i++){
                  ClassAlamat alamatBaru = new ClassAlamat(0, alamatPribadi[i]['idAlamat'], alamatPribadi[i]['alamat'], 
                                                alamatPribadi[i]['kota'], alamatPribadi[i]['kodePos'], 
                                                alamatPribadi[i]['longitude'].toDouble(), alamatPribadi[i]['latitude'].toDouble(), 
                                                "", "", "", 0);
                  alamatBaru.keterangan=alamatPribadi[i]['keterangan'];
                  alamatBaru.usernameInput=alamatPribadi[i]['username'];
                  setState(() {
                    arrAlamatPribadi.add(alamatBaru);
                  });
                }
                print(arrAlamatPribadi.length.toString()+"size");
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
}