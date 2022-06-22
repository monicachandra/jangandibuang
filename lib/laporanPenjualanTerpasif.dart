import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassPenjualanTerpasif.dart';
import 'package:jangandibuang/detailPostinganVendor.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LaporanPenjualanTerpasif extends StatefulWidget {
  final String tglAwal;
  final String tglAkhir;
  LaporanPenjualanTerpasif(
    {
      @required this.tglAwal,
      @required this.tglAkhir
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.tglAwal,this.tglAkhir);
}

class _MyHomePageState extends State<LaporanPenjualanTerpasif> {
  String tglAwal,tglAkhir;
  _MyHomePageState(this.tglAwal,this.tglAkhir){}
  final _formKey = GlobalKey<FormState>();
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  List<ClassPenjualanTerpasif> arrPenjualan = new List.empty(growable: true);
  List<ClassPenjualanTerpasif> arrPenjualanFilter = new List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    arrPenjualanFilter=arrPenjualan;
    getPenjualan();
  }

  void _runFilter(String enteredKeyword) {
    print("masuksini");
    List<ClassPenjualanTerpasif> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = arrPenjualan;
    } else {
      results = arrPenjualan
          .where((item) =>
              item.username.toLowerCase().contains(enteredKeyword.toLowerCase()) || item.jumlahPosting.toString()==enteredKeyword.toString()
          )
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }
    // Refresh the UI
    setState(() {
      arrPenjualanFilter = results;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Penjual Terpasif"),
      ),
      body: ListView(
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
                        SizedBox(height: 10.0,),
                        ListView.builder(
                          itemCount: arrPenjualanFilter.length==0 ? 1 : arrPenjualanFilter.length,
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemBuilder: (context,index){
                            if(arrPenjualanFilter.length==0){
                              return Text("no data");
                            }
                            else{
                              return 
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPostinganVendor(
                                        username:arrPenjualanFilter[index].username,
                                        tglAwal: tglAwal,
                                        tglAkhir: tglAkhir,
                                      )
                                    ) 
                                  );
                                },
                                child:
                                  Card(
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    shadowColor: Colors.black,
                                    color: globals.customLightBlue,
                                    child: Padding(
                                            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0,bottom: 10.0),
                                            child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Expanded(
                                                          flex:1,
                                                          child:CircleAvatar(
                                                            minRadius: 25,
                                                            backgroundColor: globals.customDarkBlue,
                                                            child: CircleAvatar(
                                                              backgroundImage: NetworkImage(globals.imgAdd+arrPenjualanFilter[index].logo),
                                                              minRadius: 20,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 15.0,),
                                                        Expanded(
                                                          flex:4,
                                                          child:Text(arrPenjualanFilter[index].username,style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)
                                                        ),
                                                        Expanded(
                                                          flex:3,
                                                          child:Container(
                                                                  child:Align(
                                                                        alignment: Alignment.topRight,
                                                                        child:Text(arrPenjualanFilter[index].jumlahPosting.toString()+" postingan",
                                                                                style:TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)
                                                                      )
                                                                ),
                                                        ),
                                                        Expanded(
                                                          flex:1,
                                                          child:Icon(Icons.chevron_right)
                                                        )
                                                      ],
                                                    )
                                    )
                                  )
                              );
                            }
                          }
                        )
                      ]
                    ),
                    
          )
        ],
      )
    );
  }
  Future<String> getPenjualan() async{
    var url = Uri.parse(globals.ipnumber+'getPenjualanTerpasif');
    setState(() {
      arrPenjualan.clear();
    });
    await http
            .post(url, body: {'tglAwal':tglAwal,'tglAkhir':tglAkhir})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                var data   = result['data'];
                print(data);
                for(int i=0;i<data.length;i++){
                  String username = data[i]['username'];
                  String logo = data[i]['logo'];
                  int jumlah = data[i]['jumlah'].toInt();
                  ClassPenjualanTerpasif dataBaru = new ClassPenjualanTerpasif(username, logo,jumlah);
                  setState(() {
                    arrPenjualan.add(dataBaru);
                  });
                }
                print("size:"+arrPenjualan.length.toString());
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
}