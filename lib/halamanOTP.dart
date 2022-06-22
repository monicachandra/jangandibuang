// ignore_for_file: unnecessary_new

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassDailyWastePembeli.dart';
import 'package:jangandibuang/checkOutPembeli.dart';
import 'package:jangandibuang/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jangandibuang/register.dart';
import 'package:passwordfield/passwordfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:intl/intl.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

class HalamanOTP extends StatefulWidget {
  final ClassDailyWastePembeli detailToko;
  final int ongkirperkm;
  final double longitudeToko;
  final double latitudeToko;
  final String token;
  final String email;
  HalamanOTP(
    {
      @required this.detailToko,
      @required this.ongkirperkm,
      @required this.longitudeToko,
      @required this.latitudeToko,
      @required this.token,
      @required this.email
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.detailToko,this.ongkirperkm,this.longitudeToko,this.latitudeToko,this.token,this.email);
}

class _MyHomePageState extends State<HalamanOTP> {
  OtpFieldController otpController = OtpFieldController();
  final _formKey = GlobalKey<FormState>();
  int ongkirperkm;
  double longitudeToko,latitudeToko;
  double saldoUser=0.0;
  String token;
  String email;
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  ClassDailyWastePembeli detailToko;
 _MyHomePageState(this.detailToko,this.ongkirperkm,this.longitudeToko,this.latitudeToko,this.token,this.email){}
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Jangan Dibuang"),
      ),
      body: Padding(
        padding:EdgeInsets.all(5.0),
        child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text("Email telah dikirimkan ke "+email),
                  ),
                  SizedBox(height: 15.0,),
                  OTPTextField(
                    length: 4,
                    controller: otpController,
                    width: MediaQuery.of(context).size.width,
                    fieldWidth: 60,
                    style: TextStyle(
                      fontSize: 17
                    ),
                    textFieldAlignment: MainAxisAlignment.spaceAround,
                    fieldStyle: FieldStyle.underline,
                    onChanged: (pin) {
                      print("Changed: " + pin);
                    },
                    onCompleted: (pin) {
                      cekOTP(pin);
                    }
                  ),
                  Padding(
                    padding : EdgeInsets.only(top:20.0,left:25.0,right:25.0),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children:[
                          Expanded(
                            flex:1,
                            child: ElevatedButton(
                              onPressed: () {
                                kirimEmailOTPLagi(globals.loginuser);
                              },
                              child: const Text('Kirim OTP Lagi'),
                            ),
                          ),
                      ]
                    )
                  ),
                ],
              )
      )
    );
  }
  
  Future<String> kirimEmailOTPLagi(username) async{
    otpController.clear();
    var url = Uri.parse(globals.ipnumber+'kirimEmailOTPLagi');
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
  Future<String> cekOTP(pin) async{
    var url = Uri.parse(globals.ipnumber+'cekOtp');
    await http
            .post(url, body: {'username': globals.loginuser,'pin':pin.toString()})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status!="Sukses"){
                globals.buatToast(status);
              }
              else{
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckOutPembeli(
                      detailToko:detailToko,
                      ongkirperkm:ongkirperkm,
                      longitudeToko:longitudeToko,
                      latitudeToko:latitudeToko
                    )
                  ) 
                );
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
}
