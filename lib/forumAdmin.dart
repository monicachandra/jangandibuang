import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassForum.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:jangandibuang/ClassReportForum.dart';
import 'package:jangandibuang/detailForum.dart';
import 'package:jangandibuang/editForum.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ForumAdmin extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ForumAdmin> 
with SingleTickerProviderStateMixin{
  final _formKey = GlobalKey<FormState>();
  final List<Tab> myTabs = <Tab>[
    new Tab(text: 'Aktif'),
    new Tab(text: 'Non Aktif'),
    new Tab(text: 'Direport'),
    new Tab(text: 'Menunggu Konfirmasi'),
  ];
  TabController _tabController;
  List<ClassForum> forumAktif = new List.empty(growable: true);
  List<ClassForum> forumNonAktif = new List.empty(growable: true);
  List<ClassForum> forumDiReport = new List.empty(growable: true);
  List<ClassForum> forumMenunggu = new List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    getForumAktif();
    getForumNonAktif();
    getForumMenunggu();
    getForumDiReport();
    _tabController = new TabController(vsync: this, length: myTabs.length);
    _tabController.animateTo(0);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        int indexTab = _tabController.index;
        getForumAktif();
        getForumNonAktif();
        getForumDiReport();
        getForumMenunggu();
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
                padding : EdgeInsets.only(left:5.0,right:5.0),
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
                                                      SizedBox(width:8.0),
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
                                                Expanded(
                                                  flex:1,
                                                  child:Container(
                                                    alignment: Alignment.topRight,
                                                    child:PopupMenuButton(
                                                          onSelected: (value) {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => EditForum(
                                                                  detailForum: forumAktif[index],
                                                                )
                                                              )
                                                            ).then((value) => refreshView());
                                                          },
                                                          itemBuilder: (context) => [
                                                            PopupMenuItem(
                                                              child: Text("Sunting Forum"),
                                                              value: 2,
                                                            ),
                                                          ],
                                                          child: Icon(Icons.more_vert,color: Colors.black,),
                                                      )
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
                padding : EdgeInsets.only(left:5.0,right:5.0),
                child:
                      ListView.builder(
                        itemCount: forumNonAktif.length==0 ? 1 : forumNonAktif.length,
                        itemBuilder: (context,index){
                          if(forumNonAktif.length==0){
                            return Text("no data");
                          }
                          else{
                            return GestureDetector(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailForum(
                                      detailForum: forumNonAktif[index],
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
                                                      globals.imgForum+forumNonAktif[index].fotoForum,
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
                                                          backgroundImage: NetworkImage(globals.imgAdd+forumNonAktif[index].profileUser),
                                                          minRadius: 20,
                                                        ),
                                                      ),
                                                      SizedBox(width:8.0),
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(forumNonAktif[index].username,style:TextStyle(fontWeight: FontWeight.bold)),
                                                          Text(globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(forumNonAktif[index].tanggalForum)).toString()),style:TextStyle(fontWeight: FontWeight.bold))
                                                        ],
                                                      )
                                                    ]
                                                  )
                                                  
                                                ),
                                                Expanded(
                                                  flex:1,
                                                  child:Container(
                                                    alignment: Alignment.topRight,
                                                    child:PopupMenuButton(
                                                          onSelected: (value) {
                                                            if(value==1){
                                                              aktifKan(forumNonAktif[index].idForum,forumNonAktif[index].username,forumNonAktif[index].jenisUser,forumNonAktif[index].judulForum).then((value) {
                                                                getForumAktif();
                                                                getForumNonAktif();
                                                                getForumMenunggu();
                                                                getForumDiReport();
                                                              });
                                                            }
                                                            else{
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => EditForum(
                                                                    detailForum: forumNonAktif[index],
                                                                  )
                                                                )
                                                              ).then((value) => refreshView());
                                                            }
                                                          },
                                                          itemBuilder: (context) => [
                                                            PopupMenuItem(
                                                              child: Text("Aktifkan"),
                                                              value: 1,
                                                            ),
                                                            PopupMenuItem(
                                                              child: Text("Sunting Forum"),
                                                              value: 2,
                                                            ),
                                                          ],
                                                          child: Icon(Icons.more_vert,color: Colors.black,),
                                                      )
                                                  )
                                                ),
                                              ],
                                            ),
                                            Text(forumNonAktif[index].judulForum,style:TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold)),
                                            Text(forumNonAktif[index].deskripsiForum,overflow: TextOverflow.ellipsis,maxLines: 2,),
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

  Widget viewtab2(){
    return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height:15.0),
              Expanded(
                flex:8,
                child:Padding(
                padding : EdgeInsets.only(left:5.0,right:5.0),
                child:
                      ListView.builder(
                        itemCount: forumDiReport.length==0 ? 1 : forumDiReport.length,
                        itemBuilder: (context,index){
                          if(forumDiReport.length==0){
                            return Text("no data");
                          }
                          else{
                            return GestureDetector(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailForum(
                                      detailForum: forumDiReport[index],
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
                                                      globals.imgForum+forumDiReport[index].fotoForum,
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
                                                          backgroundImage: NetworkImage(globals.imgAdd+forumDiReport[index].profileUser),
                                                          minRadius: 20,
                                                        ),
                                                      ),
                                                      SizedBox(width:8.0),
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(forumDiReport[index].username,style:TextStyle(fontWeight: FontWeight.bold)),
                                                          Text(globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(forumDiReport[index].tanggalForum)).toString()),style:TextStyle(fontWeight: FontWeight.bold))
                                                        ],
                                                      )
                                                    ]
                                                  )
                                                  
                                                ),
                                                Expanded(
                                                  flex:1,
                                                  child:Container(
                                                    alignment: Alignment.topRight,
                                                    child:PopupMenuButton(
                                                          onSelected: (value) {
                                                            if(value==1){
                                                              bacaReport(index);
                                                            }
                                                            else{
                                                              nonAktif(forumDiReport[index].idForum,forumDiReport[index].username,forumDiReport[index].jenisUser,forumDiReport[index].judulForum).then((value) {
                                                                getForumAktif();
                                                                getForumNonAktif();
                                                                getForumMenunggu();
                                                                getForumDiReport();
                                                              });
                                                            }
                                                          },
                                                          itemBuilder: (context) => [
                                                            PopupMenuItem(
                                                              child: Text("Baca Alasan Report"),
                                                              value: 1,
                                                            ),
                                                            PopupMenuItem(
                                                              child: Text("NonAktifkan"),
                                                              value: 2,
                                                            ),
                                                          ],
                                                          child: Icon(Icons.more_vert,color: Colors.black,),
                                                      )
                                                  )
                                                ),
                                              ],
                                            ),
                                            Text(forumDiReport[index].judulForum,style:TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold)),
                                            Text(forumDiReport[index].deskripsiForum,overflow: TextOverflow.ellipsis,maxLines: 2,),
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

  Widget viewtab3(){
    return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height:15.0),
              Expanded(
                flex:8,
                child:Padding(
                padding : EdgeInsets.only(left:5.0,right:5.0),
                child:
                      ListView.builder(
                        itemCount: forumMenunggu.length==0 ? 1 : forumMenunggu.length,
                        itemBuilder: (context,index){
                          if(forumMenunggu.length==0){
                            return Text("no data");
                          }
                          else{
                            return GestureDetector(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailForum(
                                      detailForum: forumMenunggu[index],
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
                                                      globals.imgForum+forumMenunggu[index].fotoForum,
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
                                                          backgroundImage: NetworkImage(globals.imgAdd+forumMenunggu[index].profileUser),
                                                          minRadius: 20,
                                                        ),
                                                      ),
                                                      SizedBox(width:8.0),
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(forumMenunggu[index].username,style:TextStyle(fontWeight: FontWeight.bold)),
                                                          Text(globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(forumMenunggu[index].tanggalForum)).toString()),style:TextStyle(fontWeight: FontWeight.bold))
                                                        ],
                                                      )
                                                    ]
                                                  )
                                                  
                                                ),
                                                Expanded(
                                                  flex:1,
                                                  child:Container(
                                                    alignment: Alignment.topRight,
                                                    child:PopupMenuButton(
                                                          onSelected: (value) {
                                                            if(value==1){
                                                              aktifKan(forumMenunggu[index].idForum,forumMenunggu[index].username,forumMenunggu[index].jenisUser,forumMenunggu[index].judulForum).then((value){
                                                                getForumAktif();
                                                                getForumNonAktif();
                                                                getForumMenunggu();
                                                                getForumDiReport();
                                                              });
                                                            }
                                                            else{
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => EditForum(
                                                                    detailForum: forumMenunggu[index],
                                                                  )
                                                                )
                                                              ).then((value) => refreshView());
                                                            }
                                                          },
                                                          itemBuilder: (context) => [
                                                            PopupMenuItem(
                                                              child: Text("Aktifkan"),
                                                              value: 1,
                                                            ),
                                                            PopupMenuItem(
                                                              child: Text("Sunting Forum"),
                                                              value: 3,
                                                            ),
                                                          ],
                                                          child: Icon(Icons.more_vert,color: Colors.black,),
                                                      )
                                                  )
                                                ),
                                              ],
                                            ),
                                            Text(forumMenunggu[index].judulForum,style:TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold)),
                                            Text(forumMenunggu[index].deskripsiForum,overflow: TextOverflow.ellipsis,maxLines: 2,),
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
                      itemCount: forumDiReport[index].arrReport.length==0 ? 1 : forumDiReport[index].arrReport.length,
                      itemBuilder: (context,ind){
                        if(forumDiReport[index].arrReport.length==0){
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
                                      child: Text(forumDiReport[index].arrReport[ind].username,
                                                  style:TextStyle(fontSize: 10.0)),
                                    ),
                                    Container(
                                      alignment: Alignment.topRight,
                                      child: Text(globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(forumDiReport[index].arrReport[ind].tanggal)).toString())+" "+forumDiReport[index].arrReport[ind].waktu,
                                                  style:TextStyle(fontSize: 10.0)),
                                    ),
                                    Text(forumDiReport[index].arrReport[ind].alasan,style: TextStyle(fontWeight: FontWeight.bold),),
                                    Text(forumDiReport[index].arrReport[ind].subAlasan),
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
        children: [viewtab0(), viewtab1(),viewtab2(),viewtab3()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          /*if(globals.vendorTerverifikasi=="0"){
            globals.buatToast("Akun Anda belum diverifikasi oleh Admin");
          }
          else{
            tambahBarang();
          }*/
          Navigator.pushNamed(context, "/addForum").then((value) => refreshView());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  refreshView(){
    getForumAktif();
    getForumNonAktif();
    getForumMenunggu();
    getForumDiReport();
  }
  Future<String> getForumAktif() async{
    setState(() {
      forumAktif.clear();
    });
    var url = Uri.parse(globals.ipnumber+'getForumAdmin');
    await http
            .post(url, body: {'status':'1'})
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
  Future<String> getForumNonAktif() async{
    setState(() {
      forumNonAktif.clear();
    });
    var url = Uri.parse(globals.ipnumber+'getForumAdmin');
    await http
            .post(url, body: {'status':'0'})
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
                    forumNonAktif.add(dataBaru);
                  }); 
                }
                print("pNonAktif"+forumNonAktif.length.toString());
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> getForumDiReport() async{
    setState(() {
      forumDiReport.clear();
    });
    var url = Uri.parse(globals.ipnumber+'getForumAdmin');
    await http
            .post(url, body: {'status':'2'})
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
                    forumDiReport.add(dataBaru);
                  }); 
                }
                print("pReport"+forumDiReport.length.toString());
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> getForumMenunggu() async{
    setState(() {
      forumMenunggu.clear();
    });
    var url = Uri.parse(globals.ipnumber+'getForumAdmin');
    await http
            .post(url, body: {'status':'3'})
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
                    forumMenunggu.add(dataBaru);
                  }); 
                }
                print("pMenunggu"+forumMenunggu.length.toString());
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
  Future<String> nonAktif(int idForum,String username,String jenisUser,String judul) async{
    var url = Uri.parse(globals.ipnumber+'nonAktifkanForum');
    await http
            .post(url, body: {'idForum':idForum.toString()})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                if(jenisUser!="A"){
                  globals.buatPushNotif(username, "Artikel Anda Telah Dinonaktifkan", judul+" Dinonaktifkan. Baca Alasan Artikel Anda Direport dan sunting kembali");
                }
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> aktifKan(int idForum, String username, String jenisUser, String judul) async{
    var url = Uri.parse(globals.ipnumber+'aktifkanForum');
    await http
            .post(url, body: {'idForum':idForum.toString()})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                if(jenisUser!="A"){
                  globals.buatPushNotif(username, "Artikel Anda telah Disetujui", judul+" telah aktif!");
                }
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
}