import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:jangandibuang/ClassForum.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:jangandibuang/ClassReportForum.dart';
import 'package:jangandibuang/detailForum.dart';
import 'package:jangandibuang/editForum.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ForumVendorPembeli extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ForumVendorPembeli> 
with SingleTickerProviderStateMixin{
  final _formKey = GlobalKey<FormState>();
  final List<Tab> myTabs = <Tab>[
    new Tab(text: 'Semua Forum'),
    new Tab(text: 'Postingan Saya'),
  ];
  TabController _tabController;
  List<ClassForum> forumAktif = new List.empty(growable: true);
  List<ClassForum> forumSaya = new List.empty(growable: true);
  List<String> ketStatus = new List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    ketStatus.add("NonAktif");
    ketStatus.add("Aktif");
    ketStatus.add("Aktif");
    ketStatus.add("Menunggu Konfirmasi");
    getForumAktif();
    getForumSaya();
    _tabController = new TabController(vsync: this, length: myTabs.length);
    _tabController.animateTo(0);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        int indexTab = _tabController.index;
        getForumAktif();
        getForumSaya();
      }
    });
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  Widget viewtab0(){
    return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height:15.0),
              Expanded(
                flex:8,
                child:Padding(
                padding : EdgeInsets.only(left:15.0,right:15.0),
                child:
                      ListView.builder(
                        itemCount: forumAktif.length==0 ? 1 : forumAktif.length,
                        itemBuilder: (context,index){
                          if(forumAktif.length==0){
                            return Text("no data");
                          }
                          else{
                            return GestureDetector(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailForum(
                                      detailForum: forumAktif[index],
                                    )
                                  )
                                ).then((value) => refreshView());
                              },
                              child:Card(
                                      elevation: 10,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      ),
                                      shadowColor: Colors.black,
                                      color: globals.customLightBlue,
                                      child: Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child:Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            /*FittedBox(
                                              child: Image.network(
                                                      globals.imgForum+forumAktif[index].fotoForum,
                                                      fit: BoxFit.fill,
                                                      width:MediaQuery.of(context).size.width,
                                                      height:150.0,
                                                      ),
                                              fit: BoxFit.fill,
                                            ),
                                            SizedBox(height:10.0),*/
                                            Row(
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
                                                          backgroundImage: NetworkImage(globals.imgAdd+forumAktif[index].profileUser),
                                                          minRadius: 20,
                                                        ),
                                                      ),
                                                      SizedBox(width:10.0),
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(forumAktif[index].username,style:TextStyle(fontWeight: FontWeight.bold)),
                                                          Text(globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(forumAktif[index].tanggalForum)).toString()),style:TextStyle(fontWeight: FontWeight.bold))
                                                        ],
                                                      )
                                                    ]
                                                  )
                                                  
                                                ),
                                              ],
                                            ),
                                            Text(forumAktif[index].judulForum,style:TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold)),
                                            Text(forumAktif[index].deskripsiForum,overflow: TextOverflow.ellipsis,maxLines: 2,),
                                          ],
                                        )
                                      )
                                    )
                            );
                          }
                        }
                      )
              ),
              )
            ],
          );
  }
  Widget viewtab1(){
    return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height:15.0),
              Expanded(
                flex:8,
                child:Padding(
                padding : EdgeInsets.only(left:15.0,right:15.0),
                child:
                      ListView.builder(
                        itemCount: forumSaya.length==0 ? 1 : forumSaya.length,
                        itemBuilder: (context,index){
                          if(forumSaya.length==0){
                            return Text("no data");
                          }
                          else{
                            return GestureDetector(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailForum(
                                      detailForum: forumSaya[index],
                                    )
                                  )
                                );
                              },
                              child:Card(
                                      elevation: 10,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      ),
                                      shadowColor: Colors.black,
                                      color: globals.customLightBlue,
                                      child: Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child:Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex:1,
                                                  child:Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment : CrossAxisAlignment.start,
                                                    children:[
                                                      Expanded(
                                                        flex:1,
                                                        child:CircleAvatar(
                                                                minRadius: 25,
                                                                backgroundColor: globals.customDarkBlue,
                                                                child: CircleAvatar(
                                                                  backgroundImage: NetworkImage(globals.imgAdd+forumSaya[index].profileUser),
                                                                  minRadius: 20,
                                                                ),
                                                              ),
                                                      ),
                                                      SizedBox(width:15.0),
                                                      Expanded(
                                                        flex:4,
                                                        child:Column(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(forumSaya[index].username,style:TextStyle(fontWeight: FontWeight.bold)),
                                                                  Text(globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(forumSaya[index].tanggalForum)).toString()),style:TextStyle(fontWeight: FontWeight.bold))
                                                                ],
                                                              )
                                                      ),
                                                      Expanded(
                                                        flex:2,
                                                        child:Container(
                                                          alignment: Alignment.topRight,
                                                          child:Padding(
                                                            padding:EdgeInsets.only(right:5.0),
                                                            child:Text(ketStatus[forumSaya[index].statusAktif],style:TextStyle(fontWeight: FontWeight.bold,color:Colors.white,backgroundColor: forumSaya[index].statusAktif==0?Colors.red:(forumSaya[index].statusAktif==3?globals.customYellow:globals.customGreen))),
                                                          )
                                                        )
                                                      )
                                                    ]
                                                  )
                                                ),
                                                forumSaya[index].statusAktif==0||forumSaya[index].statusAktif==3?
                                                Container(
                                                    alignment: Alignment.topRight,
                                                    child:PopupMenuButton(
                                                          onSelected: (value) {
                                                            if(value==1){
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => EditForum(
                                                                    detailForum: forumSaya[index],
                                                                  )
                                                                )
                                                              ).then((value) => refreshView());
                                                            }
                                                            else{
                                                              bacaReport(index);
                                                            }
                                                          },
                                                          itemBuilder: (context) => [
                                                            PopupMenuItem(
                                                              child: Text("Baca Alasan Report"),
                                                              value: 2,
                                                            ),
                                                            PopupMenuItem(
                                                              child: Text("Sunting Forum"),
                                                              value: 1,
                                                            ),
                                                          ],
                                                          child: Icon(Icons.more_vert,color: Colors.black,),
                                                      )
                                                  )
                                                :SizedBox(width: 0.0,),
                                              ],
                                            ),
                                            Text(forumSaya[index].judulForum,style:TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold)),
                                            Text(forumSaya[index].deskripsiForum,overflow: TextOverflow.ellipsis,maxLines: 2,),
                                          ],
                                        )
                                      )
                                    )
                            );
                          }
                        }
                      )
              ),
              )
            ],
          );
  }
  
  bacaReport(int index){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)), //this right here
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment:CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0,),
                Center(child: Text("Alasan Report",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),),
                Expanded(
                  flex:6,
                  child: Padding(
                    padding:EdgeInsets.all(10.0),
                    child:ListView.builder(
                      itemCount: forumSaya[index].arrReport.length==0 ? 1 : forumSaya[index].arrReport.length,
                      itemBuilder: (context,ind){
                        if(forumSaya[index].arrReport.length==0){
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
                                child: 
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:[
                                    Container(
                                      alignment: Alignment.topRight,
                                      child: Text(globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(forumSaya[index].arrReport[ind].tanggal)).toString())+" "+forumSaya[index].arrReport[ind].waktu,
                                                  style:TextStyle(fontSize: 10.0)),
                                    ),
                                    Text(forumSaya[index].arrReport[ind].alasan,style: TextStyle(fontWeight: FontWeight.bold),),
                                    Text(forumSaya[index].arrReport[ind].subAlasan),
                                  ]
                                )
                              )
                            );
                          //}
                        }
                      }
                    ),
                  )
                ),
              ],
            )
          );
        });
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Forum"),
        bottom: new TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body: new TabBarView(
        controller: _tabController,
        children: [viewtab0(), viewtab1()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(globals.isVerified=="0"){
            globals.buatToast("Verifikasi E-mail terlebih dahulu");
          }
          else if(globals.loginjenis=="V" && globals.vendorTerverifikasi=="0"){
            globals.buatToast("Akun Anda belum diverifikasi oleh Admin");
          }
          else{
            Navigator.pushNamed(context, "/addForum").then((value) => refreshView());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  refreshView(){
    getForumAktif();
    getForumSaya();
  }
  Future<String> getForumAktif() async{
    if(globals.isVerified=="0"){
      globals.buatToast("Verifikasi E-mail terlebih dahulu");
    }
    else if(globals.loginjenis=="V" && globals.vendorTerverifikasi=="0"){
       globals.buatToast("Akun Anda belum diverifikasi oleh Admin");
    }
    else{
      setState(() {
        forumAktif.clear();
      });
      var url = Uri.parse(globals.ipnumber+'getForumVendorPembeli');
      await http
              .post(url, body: {'username':globals.loginuser})
              .then((res){
                var result = json.decode(res.body);
                var status = result['status'];
                if(status=="Sukses"){
                  var data   = result['data'];
                  for (int i = 0; i < data.length; i++) {
                    List<ClassReportForum> arrReport = new List.empty(growable: true);
                    var dataReport = data[i]['report'];
                    for(int j=0;j<dataReport.length;j++){
                      ClassReportForum baru = new ClassReportForum(dataReport[j]['idReport'], dataReport[j]['username'], 
                                                                    dataReport[j]['alasanReport'],dataReport[j]['subAlasanReport'], 
                                                                    dataReport[j]['tanggal'],dataReport[j]['waktu']);
                      arrReport.add(baru);
                    }
                    ClassForum dataBaru = ClassForum(data[i]['idForum'].toInt(), 
                                                      data[i]['judulForum'], 
                                                      data[i]['deskripsiForum'],
                                                      data[i]['tanggalForum'],
                                                      data[i]['fotoForum'],
                                                      data[i]['username'],
                                                      data[i]['jenisUser'],
                                                      data[i]['statusAktif'].toInt(),
                                                      data[i]['fotoProfil'],arrReport);
                    setState(() {
                      forumAktif.add(dataBaru);
                    }); 
                  }
                  print("pAktif"+forumAktif.length.toString());
                }
              })
              .catchError((err){
                print(err);
              });
      return "suksess";
    }
  }
  Future<String> getForumSaya() async{
    setState(() {
      forumSaya.clear();
    });
    var url = Uri.parse(globals.ipnumber+'getForumSaya');
    await http
            .post(url, body: {'username':globals.loginuser})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                for (int i = 0; i < data.length; i++) {
                  List<ClassReportForum> arrReport = new List.empty(growable: true);
                  var dataReport = data[i]['report'];
                  for(int j=0;j<dataReport.length;j++){
                    ClassReportForum baru = new ClassReportForum(dataReport[j]['idReport'], dataReport[j]['username'], 
                                                                    dataReport[j]['alasanReport'],dataReport[j]['subAlasanReport'], 
                                                                    dataReport[j]['tanggal'],dataReport[j]['waktu']);
                    arrReport.add(baru);
                  }
                  ClassForum dataBaru = ClassForum(data[i]['idForum'].toInt(), 
                                                    data[i]['judulForum'], 
                                                    data[i]['deskripsiForum'],
                                                    data[i]['tanggalForum'],
                                                    data[i]['fotoForum'],
                                                    data[i]['username'],
                                                    data[i]['jenisUser'],
                                                    data[i]['statusAktif'].toInt(),
                                                    data[i]['fotoProfil'],arrReport);
                  setState(() {
                    forumSaya.add(dataBaru);
                  }); 
                }
                print("pSaya"+forumSaya.length.toString());
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
}