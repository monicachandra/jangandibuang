// ignore_for_file: non_constant_identifier_names, prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new

import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassDailyWastePembeli.dart';
import 'package:jangandibuang/halamanOTP.dart';
import 'package:jangandibuang/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:passwordfield/passwordfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterEmailGuest extends StatefulWidget {
  final ClassDailyWastePembeli detailToko;
  final int ongkirperkm;
  final double longitudeToko;
  final double latitudeToko;
  final String token;
  RegisterEmailGuest(
    {
      @required this.detailToko,
      @required this.ongkirperkm,
      @required this.longitudeToko,
      @required this.latitudeToko,
      @required this.token
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.detailToko,this.ongkirperkm,this.longitudeToko,this.latitudeToko,this.token);
}

class _MyHomePageState extends State<RegisterEmailGuest> {
  
  final _formKey = GlobalKey<FormState>();
  TextEditingController email     = new TextEditingController();
  TextEditingController noHP     = new TextEditingController();
  String tipeuser = "Pembeli";
  String token="";
  int ongkirperkm;
  double longitudeToko,latitudeToko;
  double saldoUser=0.0;
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  ClassDailyWastePembeli detailToko;
  SharedPreferences prefs;
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: globals.apiKeyGoogleMap);
  LatLng SOURCE_LOCATION = LatLng(-7.262406, 112.740323);
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  TextEditingController controller = new TextEditingController();
  GoogleMapController _controller;
  double longitude;
  double latitude;
  BitmapDescriptor sourceIcon;

  TextEditingController catatanTambahan = new TextEditingController();
  TextEditingController kodePosctrl = new TextEditingController();

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(2, 2)), 'assets/pin.png');
  }

  _MyHomePageState(this.detailToko,this.ongkirperkm,this.longitudeToko,this.latitudeToko,this.token){}
  @override
  void initState() {
    super.initState();
    this.longitude = globals.longitude;
    this.latitude = globals.latitude;
    setState(() {
      this.SOURCE_LOCATION = LatLng(this.latitude, this.longitude);
    });

    setSourceAndDestinationIcons();
    loadUser();
  }

  void loadUser() async {
    prefs = await SharedPreferences.getInstance();
  }

  void setMapPins() {
    setState(() {
      _markers.add(Marker(
          markerId: const MarkerId('sourcePin'),
          position: SOURCE_LOCATION,
          icon: sourceIcon));
    });
  }

  Future<void> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

      print("address = " + p.description);

      setState(() {
        this.longitude = lng;
        this.latitude = lat;
        print("aturlat"+latitude.toString()+"aturlong"+longitude.toString());
        this.SOURCE_LOCATION = LatLng(this.latitude, this.longitude);
        this._markers.clear();
        _markers.add(Marker(
            markerId: const MarkerId('sourcePin'),
            position: SOURCE_LOCATION,
            icon: sourceIcon));

        CameraPosition posisikamera = CameraPosition(
            // bearing: 192.8334901395799,
            target: LatLng(this.latitude, this.longitude),
            // tilt: 59.440717697143555,
            zoom: 19.151926040649414);
        this
            ._controller
            .animateCamera(CameraUpdate.newCameraPosition(posisikamera));

        controller.text=p.description;
        globals.alamat = p.description.toString();
      });
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    print("cek = " + response.errorMessage);
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Data Pembeli"),
      ),
      body:ListView(
        children:<Widget>[
          Form(
            key:_formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15.0,),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0,right:25.0),
                    child:TextFormField(
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email belum terisi';
                              }
                              else if(value.length>50){
                                return 'Email maks. 50 karakter';
                              }
                              else if(!(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value))){
                                return 'Inputan tidak memenuhi format email';
                              }
                              return null;
                            },
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              focusColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.email_outlined,
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
                              hintText: "Email",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 15.0,),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0,right:25.0),
                    child:TextFormField(
                            controller: noHP,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'No. HP belum terisi';
                              }
                              return null;
                            },
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              focusColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.phone_android_outlined,
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
                              hintText: "No. HP",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'No. HP',
                              labelStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 15.0,),
                  Padding(
                    padding:EdgeInsets.only(left:25.0,right:25.0),
                    child:Container(
                      height: 200,
                      child:GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: CameraPosition(
                                target: SOURCE_LOCATION,
                                zoom: 18.0,
                              ),
                              polylines: _polylines,
                              markers: _markers,
                              onMapCreated: (GoogleMapController controller) {
                                _controller = controller;
                                setMapPins();
                              },
                              onTap: (LatLng position) {
                                setState(() {
                                  this.longitude = position.longitude;
                                  this.latitude = position.latitude;
                                  this.SOURCE_LOCATION =
                                      LatLng(this.latitude, this.longitude);
                                  this._markers.clear();
                                  _markers.add(Marker(
                                      markerId: MarkerId('sourcePin'),
                                      position: SOURCE_LOCATION,
                                      icon: sourceIcon));
                                });
                              },
                            ),
                    )
                  ),
                  SizedBox(height: 15.0,),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0,right:25.0),
                    child:TextFormField(
                            controller: controller,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Alamat belum terisi';
                              }
                              return null;
                            },
                            onTap: () async {
                              Prediction p = await PlacesAutocomplete.show(
                                  strictbounds: false,
                                  language: "en",
                                  context:context,
                                  mode: Mode.overlay,
                                  apiKey: globals.apiKeyGoogleMap,
                                  components: [new Component(Component.country, "id")],
                                  types: ["address"],
                                  startText: "Isi Alamat");
                              displayPrediction(p);
                            },
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            // with some styling
                            decoration: InputDecoration(
                              focusColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.pin_drop,
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
                              hintText: "Alamat",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'Alamat',
                              labelStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 7.0,),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0,right:25.0),
                    child:TextFormField(
                            controller: kodePosctrl,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kode Pos belum terisi';
                              }
                              return null;
                            },
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              focusColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.mail,
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
                              hintText: "Kode Pos",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'Kode Pos',
                              labelStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 7.0,),
                  Padding(
                    padding:  EdgeInsets.only(left:25.0,right:25.0),
                    child:TextFormField(
                            controller: catatanTambahan,
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
                              hintText: "Catatan Tambahan",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'Catatan Tambahan',
                              labelStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding : EdgeInsets.only(top:7.0,left:25.0,right:25.0),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children:[
                          Expanded(
                            flex:1,
                            child: ElevatedButton(
                              onPressed: () {
                                // Validate returns true if the form is valid, or false otherwise.
                                if (_formKey.currentState.validate()) {
                                  // If the form is valid, display a snackbar. In the real world,
                                  // you'd often call a server or save the information in a database.
                                  /*ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Processing Data')),
                                  );*/
                                  RegisterActor();
                                }
                              },
                              child: const Text('Lanjutkan'),
                            ),
                          ),
                      ]
                    )
                  ),
                ],
              ),
          )
        ]
      )
      
    );
  }

  Future<String> RegisterActor() async{
    var url = Uri.parse(globals.ipnumber+'registerActorGuest');
    await http
            .post(url, body: {'email': email.text,'noHP':noHP.text,'token':token,'kodePos': kodePosctrl.text, 'latitude':latitude.toString(),'longitude':longitude.toString(),
                              'alamat':controller.text,'keterangan':catatanTambahan.text.length==0?"-":catatanTambahan.text})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              var username = result['username'];
              String uname = username.toString();
              print("username :"+uname);
              kirimEmailOTP(uname);
              globals.isVerified = "0";
              globals.loginuser=uname;
              globals.loginjenis="P";
              prefs.setString('loginuser', uname);
              prefs.setString('loginjenis', "P");
              prefs.setString('isVerified',"0");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HalamanOTP(
                    detailToko:detailToko,
                    ongkirperkm:ongkirperkm,
                    longitudeToko:longitudeToko,
                    latitudeToko:latitudeToko,
                    token:token,
                    email:email.text
                  )
                ) 
              );
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> kirimEmailOTP(username) async{
    var url = Uri.parse(globals.ipnumber+'kirimEmailOTP');
    await http
            .post(url, body: {'username': username})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              print("Status"+status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  void buatToast(message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
  }
}
