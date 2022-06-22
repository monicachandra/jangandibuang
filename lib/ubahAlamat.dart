import 'package:flutter/material.dart';
import 'package:jangandibuang/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:passwordfield/passwordfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class UbahAlamat extends StatefulWidget {
  final String username;
  final String alamat;
  final String kodePos;
  final String keterangan;
  final double longi;
  final double lati;
  UbahAlamat({Key key, @required this.username,@required this.alamat,@required this.kodePos,@required this.keterangan,@required this.longi,@required this.lati}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState(this.username,this.alamat,this.kodePos,this.keterangan,this.longi,this.lati);
}

class _MyHomePageState extends State<UbahAlamat> {
  String username,alamat,kodePos,keterangan;
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

  final _formKey = GlobalKey<FormState>();
  TextEditingController catatanTambahan = new TextEditingController();
  TextEditingController kodePosctrl = new TextEditingController();

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(2, 2)), 'assets/pin.png');
  }
  _MyHomePageState(this.username,this.alamat,this.kodePos,this.keterangan,this.longitude,this.latitude) {
    controller.text=this.alamat;
    kodePosctrl.text=this.kodePos;
    catatanTambahan.text=keterangan;
  }
  @override
  void initState() {
    super.initState();
    setState(() {
      this.SOURCE_LOCATION = LatLng(this.latitude, this.longitude);
    });

    setSourceAndDestinationIcons();
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
        title: const Text("Ubah Alamat"),
        actions: <Widget>[
          IconButton(
            icon:Icon(Icons.check),
            onPressed: (){
              if (_formKey.currentState.validate()) {
                simpanAlamat();
              }
            },
          ),
        ],
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
                    padding:EdgeInsets.only(left:25.0,right:25.0),
                    child:Container(
                      height: 450,
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
                  
                ],
              ),
          )
        ]
      )
      
    );
  }

  Future<String> simpanAlamat() async{
    var url = Uri.parse(globals.ipnumber+'simpanAlamatVendor');
    await http
            .post(url, body: {'username':this.username, 'kodePos': kodePosctrl.text, 'latitude':latitude.toString(),'longitude':longitude.toString(),
                              'alamat':controller.text,'keterangan':catatanTambahan.text.length==0?"-":catatanTambahan.text})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              Navigator.of(context).pop();
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
  
}
