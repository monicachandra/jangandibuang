import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/addPenerimaBantuan.dart';
import 'package:jangandibuang/editPenerimaBantuan.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'ClassAlamat.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class PenerimaBantuanUser extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<PenerimaBantuanUser> {
  final formKey = GlobalKey<FormState>();
  List<ClassAlamat> arrAlamatBantuan = new List.empty(growable: true);
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
        title: const Text("Penerima Bantuan"),
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
                                                Text(arrAlamatBantuan[index].namaPenerima,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                                                Text(arrAlamatBantuan[index].alamat),
                                                Text(arrAlamatBantuan[index].kota+", "+arrAlamatBantuan[index].kodePos),
                                                Text("Catatan : "+arrAlamatBantuan[index].keterangan),
                                                Text("Jumlah : "+arrAlamatBantuan[index].jmlPenerima.toString()+" orang"),
                                                Text("CP : "+arrAlamatBantuan[index].cp+" - "+arrAlamatBantuan[index].telp),
                                              ]
                                            )
                                    ),
                                    arrAlamatBantuan[index].usernameInput==globals.loginuser?
                                    Expanded(
                                      flex: 1,
                                      child: GestureDetector(
                                        onTap: (){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditPenerimaBantuan(
                                                detailAlamat: arrAlamatBantuan[index],
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
        if(globals.isVerified=="0"){
          globals.buatToast("Verifikasi E-mail terlebih dahulu");
        }
        else{
          ambilLongitudeLatitude(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPenerimaBantuan()
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
      arrAlamatBantuan.clear();
    });
    var url = Uri.parse(globals.ipnumber+'getPenerimaBantuanUser');
    await http
            .post(url,body:{'username':globals.loginuser})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var alamatBantuan = result['dataBantuan'];
                for(int i=0;i<alamatBantuan.length;i++){
                  ClassAlamat alamatBaru = new ClassAlamat(1, alamatBantuan[i]['idPenerimaBantuan'], alamatBantuan[i]['alamat'], 
                                                alamatBantuan[i]['kota'], alamatBantuan[i]['kodePos'], 
                                                alamatBantuan[i]['longitude'].toDouble(), alamatBantuan[i]['latitude'].toDouble(), 
                                                alamatBantuan[i]['namaPenerimaBantuan'], alamatBantuan[i]['contactPerson'], 
                                                alamatBantuan[i]['noTelp'], alamatBantuan[i]['jumlahPenerimaBantuan']);
                  alamatBaru.keterangan=alamatBantuan[i]['keterangan'];
                  alamatBaru.usernameInput=alamatBantuan[i]['username'];
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
}