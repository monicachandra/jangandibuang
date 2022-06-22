// ignore_for_file: file_names, use_key_in_widget_constructors, unused_field, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:jangandibuang/ShowHtmlPage.dart';
import 'package:jangandibuang/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jangandibuang/register.dart';
import 'package:passwordfield/passwordfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class TopUp extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TopUp> {
  final _formKey = GlobalKey<FormState>();
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  double saldo=0.0;
  TextEditingController nominal      = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getSaldo(globals.loginuser);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Top Up"),
      ),
      body:Form(
        key:_formKey,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 25.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  Text("Saldo : Rp "+myFormat.format(this.saldo).toString(),style:TextStyle(fontWeight: FontWeight.bold,fontSize:15.0))
                ]
              ),
              SizedBox(height: 15.0,),
              Padding(
                padding : EdgeInsets.only(left:15.0,right:15.0),
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: nominal,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nominal Top Up belum terisi';
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
                          Icons.money,
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
                        hintText: "Nominal Top Up",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),
                        labelText: 'Nominal Top Up',
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontFamily: "verdana_regular",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                )
              ),
              Padding(
                padding : EdgeInsets.only(top:25.0,left:25.0,right:25.0),
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
                              //editProfil();
                              String nom = nominal.text.toString();
                              double dbl = double.parse(nom);
                              openXendit(dbl,context);
                            }
                          },
                          child: const Text('Top Up',style: TextStyle(fontWeight: FontWeight.w600),),
                        ),
                      ),
                  ]
                )
              ),
            ],
          ),
        ),
    );
  }
  Future<String> getSaldo(String username) async{
    var url = Uri.parse(globals.ipnumber+'getSaldo');
    await http
            .post(url, body: {'username': globals.loginuser})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['actor'];
                setState((){
                  this.saldo = data['saldo'].toDouble();
                });
                print(data);
                //print(almt);
              }
              print(status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
  Future openXendit(double amount,BuildContext context) async {
    var uname = '';
    var pword = '';
    var authn = 'Basic ' + base64Encode(utf8.encode('$uname:'));
    var data = {
      'external_id': "testing",
      'payer_email': "testing@gmail.com",
      'description': 'Top Up Rp. ' + amount.toString(), // _moneyFormat(amount),
      'amount': amount.toString(),
    };
    var res = await http.post(
        Uri.parse("https://api.xendit.co/v2/invoices"),
        headers: {'Authorization': authn},
        body: data);
    if (res.statusCode != 200)
      throw Exception('post error: statusCode= ${res.statusCode}');
    var resData = jsonDecode(res.body);
    String url = resData["invoice_url"].toString();
    var myUrl = Uri.parse(globals.ipnumber+'topUp');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowHtmlPage(
            url: url,
            nominal : amount),
      ),
    ).then((value) => refreshView());
  }

  refreshView(){
    getSaldo(globals.loginuser);
    nominal.text="";
  }
}