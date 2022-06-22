import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:jangandibuang/ClassForum.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DetailForum extends StatefulWidget {
  final ClassForum detailForum;
  DetailForum(
    {
      @required this.detailForum
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.detailForum);
}
class _MyHomePageState extends State<DetailForum> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController subAlasan       = new TextEditingController();
  ClassForum detailForum;
  String alasanReport = "Konten Ini Mengandung Unsur SARA";

  _MyHomePageState(this.detailForum){
  }
  @override
  Widget build(BuildContext context) {
    final gambar = Container(
      width : MediaQuery.of(context).size.width,
      height: 150.0,
      child: Center(
        child: Image.network(
                    globals.imgForum+detailForum.fotoForum,
                    fit: BoxFit.cover)
      ),
    );
    return Scaffold(
      appBar:AppBar(
        title: const Text("Forum"),
        actions: <Widget>[
          globals.loginuser!=detailForum.username?
          IconButton(
            icon:Icon(Icons.report),
            onPressed: (){
              openKomentar(context);
            },
          ):
          SizedBox(height: 0.0,)
        ],
      ),
      body:ListView(
        children: <Widget>[
          Form(
            key:_formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height:15.0),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex:1,
                              child:Row(
                                children:[
                                  CircleAvatar(
                                    minRadius: 25,
                                    backgroundColor: globals.customDarkBlue,
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(globals.imgAdd+detailForum.profileUser),
                                      minRadius: 20,
                                    ),
                                  ),
                                  SizedBox(width:10.0),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(detailForum.username,style:TextStyle(fontWeight: FontWeight.bold)),
                                      Text(globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(detailForum.tanggalForum)).toString()),style:TextStyle(fontWeight: FontWeight.bold))
                                    ],
                                  )
                                ]
                              )
                            ),
                          ],
                        ),
                ),
                SizedBox(height: 15.0,),
                Padding(
                  padding:EdgeInsets.only(left:15.0,right:15.0),
                  child:Center(
                          child: Text(detailForum.judulForum,style:TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0)),
                        )
                ),
                SizedBox(height: 10.0,),
                gambar,
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child:Text(detailForum.deskripsiForum,textAlign: TextAlign.justify,style:TextStyle(fontSize: 15.0,))
                )
              ],
            ),
          )
        ],
      )
    );
  }
  openKomentar(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)), //this right here
            child: Container(
              height: 250.0,
              child: Padding(
                      padding:EdgeInsets.all(10.0),
                      child:Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text("Report",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                          ),
                          Container(
                            padding:  EdgeInsets.only(left:25.0,right:25.0),
                            decoration: BoxDecoration(
                              border: Border.all(color:Colors.grey,width:1),
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: DropdownButton<String>(
                                    hint:Text("Pilih tipe user"),
                                    isExpanded: true,
                                    value:alasanReport,
                                    onChanged: (value){
                                      setState(() {
                                        alasanReport=value;
                                      });
                                    },
                                    items:<String>[
                                      'Konten Ini Mengandung Unsur SARA',
                                      'Konten Ini Mengandung Unsur Pornografi',
                                      'Konten Ini Mengandung Unsur Kebencian',
                                      'Konten Ini Mengandung Unsur Pembohongan',
                                      'Konten Ini Mengandung Unsur Kekerasan',
                                      'Konten Ini Mengandung Unsur Bullying',
                                      'Lainnya',
                                    ].map((String value) {
                                      return new DropdownMenuItem<String>(
                                        value: value,
                                        child: new Text(value,style:TextStyle(fontSize: 12.0))
                                      );
                                    }).toList()
                                  ),
                          ),
                          SizedBox(height: 10.0,),
                          TextFormField(
                            controller: subAlasan,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              focusColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.add_comment_outlined,
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
                              hintText: "Keterangan Tambahan",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                              labelText: 'Keterangan Tambahan',
                              labelStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: "verdana_regular",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex:1,
                                child:ElevatedButton(
                                        onPressed: () {
                                          submitReport(context);
                                        },
                                        child: const Text('Submit Report'),
                                      ),
                              )
                            ],
                          )
                        ],
                      )
                    ),
            )
            
          );
        });
      }
    );
  }
  Future<String> submitReport(BuildContext context) async{
    var url = Uri.parse(globals.ipnumber+'submitReport');
    await http
            .post(url, body: {'username':globals.loginuser,'alasan':alasanReport,'subAlasan':subAlasan.text.length==0?"-":subAlasan.text,'idForum':detailForum.idForum.toString()})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                subAlasan.text="";
                globals.buatToast("Anda telah Mereport Artikel ini");
                globals.buatPushNotifAdmin("Report Baru untuk Artikel "+detailForum.judulForum, "Baca dan Sunting!");
                Navigator.pop(context);
                Navigator.of(context).pop();
              }
              //print(status);
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
}