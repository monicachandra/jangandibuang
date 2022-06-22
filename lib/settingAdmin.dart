import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class SettingAdmin extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SettingAdmin> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController appFee   = new TextEditingController();
  TextEditingController limitShow= new TextEditingController();

  @override
  void initState() {
    super.initState();
    getDataSetting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Pengaturan"),
      ),
      body: ListView(
        children:<Widget>[ 
          Form(
          key:_formKey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),
                Padding(
                  padding:EdgeInsets.only(left:10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex:1,
                        child:Text("Persentase App Fee",style:TextStyle(fontSize: 20.0,fontWeight:FontWeight.bold))
                      ),
                      Expanded(
                        flex:1,
                        child:Align(
                          alignment: Alignment.topRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex:3,
                                child:TextFormField(
                                  controller: appFee,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'App Fee belum terisi';
                                    }
                                    return null;
                                  },
                                )
                              ),
                              Expanded(
                                flex:1,
                                child:Text("%")
                              )
                            ],
                          ),
                        )
                      )
                    ],
                  ),
                ),
                SizedBox(height: 25.0),
                Padding(
                  padding:EdgeInsets.only(left:10.0,right:10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex:1,
                        child:Text("Limit Show Makanan",style:TextStyle(fontSize: 20.0,fontWeight:FontWeight.bold))
                      ),
                      Expanded(
                        flex:1,
                        child:Align(
                          alignment: Alignment.topRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex:3,
                                child:TextFormField(
                                  controller: limitShow,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Limit Show belum terisi';
                                    }
                                    return null;
                                  },
                                )
                              ),
                              Expanded(
                                flex:1,
                                child:Text("item")
                              )
                            ],
                          ),
                        )
                      )
                    ],
                  ),
                ),
                Padding(
                    padding : EdgeInsets.only(top:7.0,left:10.0,right:10.0),
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
                                  editSetting();
                                }
                              },
                              child: const Text('Edit Pengaturan'),
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
  Future<String> getDataSetting() async{
    var url = Uri.parse(globals.ipnumber+'getDataSetting');
    await http
            .get(url)
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data = result['data'];
                double appF = data['appFee'].toDouble();
                this.appFee.text=appF.toString();
                int limShow = data['limitShowMakanan'].toInt();
                this.limitShow.text = limShow.toString();
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
  Future<String> editSetting() async{
    var url = Uri.parse(globals.ipnumber+'editSetting');
    await http
            .post(url, body: {'appFee': appFee.text, 'limitShow': limitShow.text})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              globals.buatToast("Sukses Edit Pengaturan");
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
}