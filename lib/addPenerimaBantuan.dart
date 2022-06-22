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

class AddPenerimaBantuan extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AddPenerimaBantuan> {
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
  TextEditingController namaPenerima  = new TextEditingController();
  TextEditingController cpPenerima    = new TextEditingController();
  TextEditingController noTelp        = new TextEditingController();
  TextEditingController jumlahPenerima= new TextEditingController();
  TextEditingController catatanTambahan = new TextEditingController();
  TextEditingController kodePos = new TextEditingController();

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(2, 2)), 'assets/pin.png');
  }

  @override
  void initState() {
    super.initState();
    this.longitude = globals.longitude;
    this.latitude = globals.latitude;
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
        title: const Text("Tambah Penerima Bantuan"),
        actions: <Widget>[
          IconButton(
            icon:Icon(Icons.check),
            onPressed: (){
              if (_formKey.currentState.validate()) {
                simpanPenerimaBantuan();
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
                    padding:  EdgeInsets.only(left:25.0,right:25.0),
                    child:TextFormField(
                            controller: namaPenerima,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama Penerima Bantuan belum terisi';
                              }
                              else if(value.length>50){
                                return 'Nama Penerima Bantuan maks. 50 karakter';
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
                                Icons.house,
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
                              hintText: "Nama Penerima Bantuan",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'Nama Penerima Bantuan',
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
                            controller: cpPenerima,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Contact Person belum terisi';
                              }
                              else if(value.length>50){
                                return 'Contact Person maks. 50 karakter';
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
                                Icons.person_outline_rounded,
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
                              hintText: "Contact Person",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'Contact Person',
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
                            controller: noTelp,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nomor Telepon belum terisi';
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
                              hintText: "No. Telp",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'No. Telp',
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
                            controller: jumlahPenerima,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Jumlah Penerima Bantuan belum terisi';
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
                                Icons.people,
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
                              hintText: "Jumlah Penerima Bantuan",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'Jumlah Penerima Bantuan',
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
                            controller: kodePos,
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
                  SizedBox(height: 7.0,),
                  Padding(
                    padding:EdgeInsets.only(left:25.0,right:25.0),
                    child:Container(
                      height: 120,
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
                ],
              ),
          )
        ]
      )
      
    );
  }

  Future<String> simpanPenerimaBantuan() async{
    var url = Uri.parse(globals.ipnumber+'simpanPenerimaBantuan');
    await http
            .post(url, body: {'nama': namaPenerima.text, 'alamat': controller.text,'kodePos': kodePos.text, 'latitude':latitude.toString(),'longitude':longitude.toString(),'contact':cpPenerima.text,
                              'noTelp':noTelp.text.toString(),'jumlah':jumlahPenerima.text.toString(),'keterangan':catatanTambahan.text.length==0?"-":catatanTambahan.text,'username':globals.loginuser})
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
