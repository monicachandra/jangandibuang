// ignore_for_file: avoid_print, unnecessary_this, no_logic_in_create_state, non_constant_identifier_names, file_names, unused_import, prefer_const_constructors, prefer_final_fields, unnecessary_new

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
// import 'package:geocoder/geocoder.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class ShowMap extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ShowMap({Key key, @required this.longitude, @required this.latitude})
      : super(key: key);
  final double longitude;
  final double latitude;
  @override
  _MyHomePageState createState() =>
      _MyHomePageState(this.longitude, this.latitude);
}

class _MyHomePageState extends State<ShowMap> {
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: "");
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

  _MyHomePageState(this.longitude, this.latitude) {
    print("nilai longitude ");
    print(this.longitude);
    print(this.latitude);
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(2, 2)), 'assets/pin.png');
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

  /*Future<String> ubahPosisi(newAddr) async {
    Map paramData = {
      'username': globals.loginuser,
      'alamat': newAddr,
      'longitude': this.longitude,
      'latitude': this.latitude
    };
    var parameter = json.encode(paramData);
    http
        .post(Uri.parse(globals.ipnumber + "ubahPosisiMember.php"),
            headers: {"Content-type": "application/json"}, body: parameter)
        .then((res) {});
  }*/

  Future<void> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

      controller.text=p.description;
      print("address = " + p.description);
      // var address = await Geocoder.local.findAddressesFromQuery(p.description);

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

        globals.alamat = p.description.toString();
        globals.buatToast("Posisi Peta Telah diubah ke Profile Anda");
        print("alamatt:" + globals.alamat);
        //ubahPosisi(p.description);
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
        appBar: AppBar(
          title: const Text('Alamat'),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: controller,
                onTap: () async {
                  Prediction p = await PlacesAutocomplete.show(
                      strictbounds: false,
                      language: "en",
                      context: context,
                      mode: Mode.overlay,
                      apiKey: "",
                      components: [new Component(Component.country, "id")],
                      types: ["address"],
                      startText: "Isi Alamat");
                  displayPrediction(p);
                },
                // with some styling
                decoration: InputDecoration(
                  icon: Container(
                    margin: EdgeInsets.only(left: 20),
                    width: 10,
                    height: 10,
                    child: Icon(
                      Icons.home,
                      color: Colors.black,
                    ),
                  ),
                  hintText: "Masukkan Alamat Pengiriman",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 8.0, top: 16.0),
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: GoogleMap(
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
          ],
        ));
  }
}
