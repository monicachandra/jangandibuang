import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassDetailWaste.dart';
import 'package:jangandibuang/ClassKomentar.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'ClassRankLaku.dart';
import 'ClassDetailWaste.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

class LaporanRankLaku extends StatefulWidget {
  final String tglAwal;
  final String tglAkhir;
  LaporanRankLaku(
    {
      @required this.tglAwal,
      @required this.tglAkhir
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.tglAwal,this.tglAkhir);
}

class _MyHomePageState extends State<LaporanRankLaku> with SingleTickerProviderStateMixin{
  final List<Tab> myTabs = <Tab>[
    new Tab(text:'Semua Makanan'),
    new Tab(text:'Paket Saja'),
  ];
  TabController _tabController;
  String tglAwal,tglAkhir;
  _MyHomePageState(this.tglAwal,this.tglAkhir){}
  final _formKey = GlobalKey<FormState>();
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  int itemLaku=0;
  int paketLaku=0;
  List<ClassRankLaku> arrWaste = new List.empty(growable: true);
  List<ClassRankLaku> arrWasteFilter = new List.empty(growable: true);

  List<ClassRankLaku> arrWastePaket = new List.empty(growable: true);
  List<ClassRankLaku> arrWasteFilterPaket = new List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    arrWasteFilter=arrWaste;
    arrWasteFilterPaket=arrWastePaket;
    _tabController = new TabController(vsync:this,length:myTabs.length);
    _tabController.animateTo(0);
    getLaku();
    getLakuPaket();
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Your code goes here.
        // To get index of current tab use tabController.index
        print("masuksini"+",in:"+_tabController.index.toString());
        int indexTab = _tabController.index;
        getLaku();
        getLakuPaket();
      }
    });
  }

  @override
  void dispose(){
    _tabController.dispose();
    super.dispose();
  }

  Widget viewtab0(){
    return ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child:Column(
                            children:[
                              Text("Periode "+globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(tglAwal)).toString())+" s/d "+
                              globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(tglAkhir)).toString())
                              , style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                              SizedBox(height:10.0),
                              Text("Total Item Terjual: "+itemLaku.toString(), style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                            ]
                          )
                        ),
                        SizedBox(height: 10.0,),
                        TextFormField(
                          onChanged: (value) => _runFilter(value),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            focusColor: Colors.white,
                            
                            suffixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.blue, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            fillColor: Colors.grey,
                            hintText: "Filter",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontFamily: "verdana_regular",
                              fontWeight: FontWeight.w400,
                            ),
                            labelText: 'Filter',
                            labelStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontFamily: "verdana_regular",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(height:10.0),
                        ListView.builder(
                          itemCount: arrWasteFilter.length==0 ? 1 : arrWasteFilter.length,
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemBuilder: (context,index){
                            if(arrWasteFilter.length==0){
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
                                        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0,bottom: 10.0),
                                        child: _buildDailyItem(index)
                                )
                              );
                            }
                          }
                        )
                      ]
                    ),
                    
          )
        ],
      );
  }
  Widget viewtab1(){
    return ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child:Column(
                            children:[
                              Text("Periode "+globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(tglAwal)).toString())+" s/d "+
                              globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(tglAkhir)).toString())
                              , style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                              SizedBox(height:10.0),
                              Text("Total Paket Terjual: "+paketLaku.toString(), style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                            ]
                          )
                        ),
                        SizedBox(height: 10.0,),
                        TextFormField(
                          onChanged: (value) => _runFilter2(value),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            focusColor: Colors.white,
                            
                            suffixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.blue, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            fillColor: Colors.grey,
                            hintText: "Filter",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontFamily: "verdana_regular",
                              fontWeight: FontWeight.w400,
                            ),
                            labelText: 'Filter',
                            labelStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontFamily: "verdana_regular",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(height:10.0),
                        ListView.builder(
                          itemCount: arrWasteFilterPaket.length==0 ? 1 : arrWasteFilterPaket.length,
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemBuilder: (context,index){
                            if(arrWasteFilterPaket.length==0){
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
                                        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0,bottom: 10.0),
                                        child: _buildDailyItemPaket(index)
                                )
                              );
                            }
                          }
                        )
                      ]
                    ),
                    
          )
        ],
      );
  }

  void _runFilter(String enteredKeyword) {
    List<ClassRankLaku> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = arrWaste;
    } else {
      results = arrWaste
          .where((item) =>
              item.namaBarang.toLowerCase().contains(enteredKeyword.toLowerCase()) || item.kategori.toLowerCase().contains(enteredKeyword.toLowerCase())
          )
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }
    // Refresh the UI
    setState(() {
      arrWasteFilter = results;
      itemLaku = 0;
      for(int i=0;i<arrWasteFilter.length;i++){
        itemLaku+=arrWasteFilter[i].terjual;
      }
    });
  }

  void _runFilter2(String enteredKeyword) {
    List<ClassRankLaku> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = arrWastePaket;
    } else {
      results = arrWastePaket
          .where((item) =>
              item.namaBarang.toLowerCase().contains(enteredKeyword.toLowerCase())
          )
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }
    // Refresh the UI
    setState(() {
      arrWasteFilterPaket = results;
      paketLaku = 0;
      for(int i=0;i<arrWasteFilterPaket.length;i++){
        paketLaku+=arrWasteFilterPaket[i].terjual;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Barang Laku Terbanyak"),
        bottom: new TabBar(
          controller: _tabController,
          tabs: myTabs
        )
      ),
      body: new TabBarView(
        controller: _tabController,
        children: [viewtab0(),viewtab1()],
      )
    );
  }
  Widget _buildDailyItem(int index) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center, 
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          Expanded(
            flex:3,
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:CrossAxisAlignment.center,
              children:[
                FittedBox(
                  child: Image.network(
                          globals.imgAddMakanan+arrWasteFilter[index].arrFoto[0],
                          fit: BoxFit.fill,
                          width:100.0,
                          height:100.0
                          ),
                  fit: BoxFit.fill,
                ),
                SizedBox(height:5.0),
                arrWasteFilter[index].totalRatingMakanan==0.0?SizedBox(height: 0.0,):
                Row(
                  mainAxisAlignment:MainAxisAlignment.start,
                  crossAxisAlignment:CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 24.0,
                    ),
                    GestureDetector(
                      onTap:(){
                        bacaKomentarMakanan(index);
                      },
                      child: Text(double.parse(arrWasteFilter[index].totalRatingMakanan.toStringAsFixed(2)).toString(),
                                  style:TextStyle(
                                    decoration: TextDecoration.underline,
                                    color:Colors.blue
                                  )),
                    )
                  ],
                )
              ]
            )
          ),
          SizedBox(width:20.0),
          Expanded(
            flex:6,
            child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(arrWasteFilter[index].kategori.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color:globals.customGrey)),
                  SizedBox(height: 3.0),
                  Text(arrWasteFilter[index].namaBarang,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold)),
                  SizedBox(height: 3.0),
                  Text(arrWasteFilter[index].deskripsi,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: globals.customGrey,
                      fontWeight: FontWeight.bold)),
                  SizedBox(height: 3.0),
                  Align(
                    alignment:Alignment.bottomRight,
                    child:Text(arrWasteFilter[index].terjual.toString()+" x",
                                style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold))
                  )
                  ]
                ),
          ),
        ]
);
  }
  Widget _buildDailyItemPaket(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, 
      crossAxisAlignment: CrossAxisAlignment.center, 
      children: [
        Expanded(
          flex:3,
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:CrossAxisAlignment.center,
            children:[
              Container(
                child: CarouselSlider(
                options: CarouselOptions(),
                items: arrWasteFilterPaket[index].arrFoto
                    .map((item) => Container(
                          child: Center(
                              child:
                                  Image.network(globals.imgAddMakanan+item, fit: BoxFit.fill, width: 75.0, height:100.0)),
                        ))
                    .toList(),
              )),
              SizedBox(height:5.0),
              arrWasteFilterPaket[index].totalRatingMakanan==0.0?SizedBox(height: 0.0,):
              Row(
                mainAxisAlignment:MainAxisAlignment.start,
                crossAxisAlignment:CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 24.0,
                  ),
                  GestureDetector(
                    onTap:(){
                      bacaKomentarMakananPaket(index);
                    },
                    child: Text(double.parse(arrWasteFilterPaket[index].totalRatingMakanan.toStringAsFixed(2)).toString(),
                                style:TextStyle(
                                  decoration: TextDecoration.underline,
                                  color:Colors.blue
                                )),
                  )
                ],
              )
            ]
          )
        ),
        SizedBox(width:20.0),
        Expanded(
          flex:6,
          child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text("PAKET",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color:globals.customGrey)),
                SizedBox(height: 3.0),
                Text(arrWasteFilterPaket[index].namaBarang,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold)),
                SizedBox(height:3.0),
                ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    physics: ScrollPhysics(),
                    itemCount: arrWasteFilterPaket[index].arrDetail.length==0 ? 1 : arrWasteFilterPaket[index].arrDetail.length,
                    itemBuilder: (context,idx){
                    if(arrWasteFilterPaket[index].arrDetail.length==0){
                      return Text("no data");
                    }
                    else{
                      //return Text("+");
                      return Text(arrWasteFilterPaket[index].arrDetail[idx].qty.toString()+" - "+arrWasteFilterPaket[index].arrDetail[idx].namaBarang);
                    }
                    }
                ),
                Align(
                  alignment:Alignment.bottomRight,
                  child:Text(arrWasteFilterPaket[index].terjual.toString()+" x",
                              style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold))
                )
              ]
              ),
        ),
      ]
    );
  }
  bacaKomentarMakanan(int index){
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
                Center(
                  child:Text("Apa kata mereka?",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                ),
                Expanded(
                  flex:6,
                  child: Padding(
                    padding:EdgeInsets.all(10.0),
                    child:ListView.builder(
                      itemCount: arrWasteFilter[index].arrKomentar.length==0 ? 1 : arrWasteFilter[index].arrKomentar.length,
                      itemBuilder: (context,ind){
                        if(arrWasteFilter[index].arrKomentar.length==0){
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:[
                                  Row(
                                    mainAxisAlignment:MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex:1,
                                        child:Text(arrWasteFilter[index].arrKomentar[ind].username,style: TextStyle(fontWeight: FontWeight.bold),)
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.topRight,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 24.0,
                                              ),
                                              Text(double.parse(arrWasteFilter[index].arrKomentar[ind].rating.toStringAsFixed(2)).toString())
                                            ],
                                          )
                                        ),
                                      )
                                    ],
                                  ),
                                  arrWasteFilter[index].arrKomentar[ind].komentar.length==0?Text("-"):Text(arrWasteFilter[index].arrKomentar[ind].komentar)
                                ]
                              )
                            )
                          );
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
  bacaKomentarMakananPaket(int index){
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
                Center(
                  child:Text("Apa kata mereka?",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                ),
                Expanded(
                  flex:6,
                  child: Padding(
                    padding:EdgeInsets.all(10.0),
                    child:ListView.builder(
                      itemCount: arrWasteFilterPaket[index].arrKomentar.length==0 ? 1 : arrWasteFilterPaket[index].arrKomentar.length,
                      itemBuilder: (context,ind){
                        if(arrWasteFilterPaket[index].arrKomentar.length==0){
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:[
                                  Row(
                                    mainAxisAlignment:MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex:1,
                                        child:Text(arrWasteFilterPaket[index].arrKomentar[ind].username,style: TextStyle(fontWeight: FontWeight.bold),)
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.topRight,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 24.0,
                                              ),
                                              Text(double.parse(arrWasteFilterPaket[index].arrKomentar[ind].rating.toStringAsFixed(2)).toString())
                                            ],
                                          )
                                        ),
                                      )
                                    ],
                                  ),
                                  arrWasteFilterPaket[index].arrKomentar[ind].komentar.length==0?Text("-"):Text(arrWasteFilterPaket[index].arrKomentar[ind].komentar)
                                ]
                              )
                            )
                          );
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
  Future<String> getLaku() async{
    var url = Uri.parse(globals.ipnumber+'getRankLaku');
    setState(() {
      itemLaku=0;
      arrWaste.clear();
    });
    await http
            .post(url, body: {'username':globals.loginuser,'tglAwal':tglAwal,'tglAkhir':tglAkhir,'jenis':'0'})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                print(data);
                for (int i = 0; i < data.length; i++) {
                  int id = data[i]['idDaily'].toInt();
                  int isPaket = data[i]['isPaket'].toInt();
                  int idBarang = null;
                  if(data[i]['idBarang']!=null){
                    idBarang = data[i]['idBarang'].toInt();
                  }
                  String namaBarang = data[i]['namaBarang'].toString();
                  int terjual = data[i]['terjual'].toInt();
                  
                  var foto = data[i]['foto'];
                  List<String> arrFoto = List.empty(growable: true);
                  for(int j=0;j<foto.length;j++){
                    arrFoto.add(foto[j]);
                  }
                  
                  var detailPaket = data[i]['detailPaket'];
                  List<ClassDetailWaste> arrDetail = List.empty(growable: true);
                  for(int j=0;j<detailPaket.length;j++){
                    ClassDetailWaste baru = ClassDetailWaste(detailPaket[j]['idBarang'].toInt(),
                                                              detailPaket[j]['namaBarang'].toString(),
                                                              detailPaket[j]['qty'].toInt());
                    arrDetail.add(baru);
                  }
                  double totalRating = data[i]['totalRatingMakanan'].toDouble();
                  List<ClassKomentar> arrKomentar = new List.empty(growable: true);
                  var komentar = data[i]['komentarMakanan'];
                  for(int j=0;j<komentar.length;j++){
                    String pembelii = komentar[j]['pembeli'];
                    String komm     = komentar[j]['komentar'];
                    double ratestar= komentar[j]['star'].toDouble();
                    setState(() {
                      arrKomentar.add(new ClassKomentar(pembelii, komm, ratestar));
                    });
                  }
                  String kategori  = data[i]['kategori'];
                  String deskripsi = data[i]['deskripsi'];
                  ClassRankLaku databaru = ClassRankLaku(id,isPaket,idBarang,namaBarang,terjual,arrFoto,arrDetail,totalRating,arrKomentar,kategori,deskripsi);
                  setState(() {
                    arrWaste.add(databaru);
                    itemLaku+=databaru.terjual;
                  }); 
                }
                print("halo");
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }

  Future<String> getLakuPaket() async{
    var url = Uri.parse(globals.ipnumber+'getRankLaku');
    setState(() {
      paketLaku=0;
      arrWastePaket.clear();
    });
    await http
            .post(url, body: {'username':globals.loginuser,'tglAwal':tglAwal,'tglAkhir':tglAkhir,'jenis':'1'})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                print(data);
                for (int i = 0; i < data.length; i++) {
                  int id = data[i]['idDaily'].toInt();
                  int isPaket = data[i]['isPaket'].toInt();
                  int idBarang = null;
                  if(data[i]['idBarang']!=null){
                    idBarang = data[i]['idBarang'].toInt();
                  }
                  String namaBarang = data[i]['namaBarang'].toString();
                  int terjual = data[i]['terjual'].toInt();
                  
                  var foto = data[i]['foto'];
                  List<String> arrFoto = List.empty(growable: true);
                  for(int j=0;j<foto.length;j++){
                    arrFoto.add(foto[j]);
                  }
                  
                  var detailPaket = data[i]['detailPaket'];
                  List<ClassDetailWaste> arrDetail = List.empty(growable: true);
                  for(int j=0;j<detailPaket.length;j++){
                    ClassDetailWaste baru = ClassDetailWaste(detailPaket[j]['idBarang'].toInt(),
                                                              detailPaket[j]['namaBarang'].toString(),
                                                              detailPaket[j]['qty'].toInt());
                    arrDetail.add(baru);
                  }
                  double totalRating = data[i]['totalRatingMakanan'].toDouble();
                  List<ClassKomentar> arrKomentar = new List.empty(growable: true);
                  var komentar = data[i]['komentarMakanan'];
                  for(int j=0;j<komentar.length;j++){
                    String pembelii = komentar[j]['pembeli'];
                    String komm     = komentar[j]['komentar'];
                    double ratestar= komentar[j]['star'].toDouble();
                    setState(() {
                      arrKomentar.add(new ClassKomentar(pembelii, komm, ratestar));
                    });
                  }
                  String kategori  = data[i]['kategori'];
                  String deskripsi = data[i]['deskripsi'];
                  ClassRankLaku databaru = ClassRankLaku(id,isPaket,idBarang,namaBarang,terjual,arrFoto,arrDetail,totalRating,arrKomentar,kategori,deskripsi);
                  setState(() {
                    arrWastePaket.add(databaru);
                    paketLaku+=databaru.terjual;
                  }); 
                }
                print("halo");
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
}