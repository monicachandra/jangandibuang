import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassListofChat.dart';
import 'package:jangandibuang/showChat.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badges/badges.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class ListOfChat extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ListOfChat> {
  final _formKey = GlobalKey<FormState>();
  List<String> arrUser = new List.empty(growable:true);

  @override
  void initState() {
    super.initState();
    setState(() {
      globals.arrOfUserLoginChat.clear();
      globals.arrOfOtherUserChat.clear();
      arrUser.clear();
      globals.arrOfFotoUser.clear();
    });
    getFotoProfil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Daftar Chat"),
      ),
      body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex:9,
                child:Padding(
                  padding: EdgeInsets.only(left: 15.0,right: 15.0,top:15.0),
                  child: ListView.builder(
                        itemCount: globals.arrOfUserLoginChat.length==0 ? 1 : globals.arrOfUserLoginChat.length,
                        itemBuilder: (context,index){
                          if(globals.arrOfUserLoginChat.length==0){
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
                                padding:EdgeInsets.only(left:15.0,right:15.0),
                                child: GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ShowChat(
                                          nama:globals.arrOfUserLoginChat[index].username
                                        )
                                      )
                                    ).then((value) => refreshView());
                                  },
                                  child:Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex:1,
                                        child:CircleAvatar(
                                                minRadius: 35,
                                                backgroundColor: globals.customDarkBlue,
                                                child: CircleAvatar(
                                                  backgroundImage: NetworkImage(globals.imgAdd+globals.arrOfFotoUser[index]),
                                                  minRadius: 30,
                                                ),
                                              ),
                                      ),
                                      SizedBox(width:10.0),
                                      Expanded(
                                        flex:6,
                                        child:Padding(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center, 
                                                  crossAxisAlignment: CrossAxisAlignment.start, 
                                                  children: [
                                                    Text(globals.arrOfUserLoginChat[index].username,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                                                    Text(globals.arrOfUserLoginChat[index].teks,style: TextStyle(fontSize: 12.0,color: globals.customGrey,fontWeight: FontWeight.bold),),
                                                  ]
                                                ),
                                                padding:EdgeInsets.only(top:10.0)
                                              )
                                      ),
                                      SizedBox(width:10.0),
                                      Expanded(
                                        flex:2,
                                        child:Padding(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start, 
                                                  crossAxisAlignment: CrossAxisAlignment.end, 
                                                  children: [
                                                    globals.arrOfUserLoginChat[index].jumlahMessage>0?
                                                    Badge(
                                                      badgeContent: Text(globals.arrOfUserLoginChat[index].jumlahMessage.toString(),style:TextStyle(color: globals.customWhite)),
                                                      shape: BadgeShape.circle,
                                                      badgeColor: globals.customDarkBlue,
                                                      borderRadius: BorderRadius.circular(8)
                                                    ):SizedBox(height: 0.0,),
                                                    Text(globals.arrOfUserLoginChat[index].tanggal.substring(0,16),style: TextStyle(fontSize: 8.0,color: globals.customGrey,fontWeight: FontWeight.bold),),
                                                  ]
                                                ),
                                                padding:EdgeInsets.only(top:10.0)
                                              )
                                      ),
                                    ],
                                  )
                                )
                              )
                            );
                          }
                        }
                      ),
                )
              )
            ]
          )
    );
  }

  Future<String> getFotoProfil() async{
    FirebaseFirestore.instance
        .collection("daftaruser" + globals.loginuser)
        .orderBy('tanggal',descending: true)
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((f) {
        print(f.get("user")); 
        print("masuksini");
        setState(() {
          String jumlahMessage = f.get("jumlahMessage");
          int jumlahM = int.parse(jumlahMessage);
          print(jumlahM.toString());
          ClassListofChat listBaru = new ClassListofChat(f.get("user"), f.get("lastMessage"), f.get("tanggal").toString(), jumlahM,f.id);
          globals.arrOfUserLoginChat.add(listBaru);
          arrUser.add(f.get("user"));
          globals.arrOfFotoUser.add("default.jpg");
        });
      });
      getFoto();
    });
    return "suksess";
  }
  Future<String> getFoto() async{
    var arrUsername = json.encode(arrUser);
    print("arruser"+arrUsername);
    var url = Uri.parse(globals.ipnumber+'getFotoProfil');
      await http
              .post(url, body: {'arrUsername': arrUsername})
              .then((res){
                var result = json.decode(res.body);
                var status = result['status'];
                if(status=="Sukses"){
                  var data = json.decode(result['data']);
                  print("data"+data.length.toString());
                  for(int i=0;i<data.length;i++){
                    setState(() {
                      globals.arrOfFotoUser[i]=data[i];
                      print("data"+data[i]);
                    });
                  }
                }
              })
              .catchError((err){
                print(err);
              });
    return "suksess";
  }
  refreshView(){
    setState(() {
      globals.arrOfUserLoginChat.clear();
      globals.arrOfOtherUserChat.clear();
      arrUser.clear();
      globals.arrOfFotoUser.clear();
    });
    getFotoProfil();
  }
}