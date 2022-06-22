import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassDetailWaste.dart';
import 'package:jangandibuang/ClassKomentar.dart';
import 'package:jangandibuang/ClassUbahSaldo.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'ClassDailyWaste.dart';
import 'ClassDetailWaste.dart';
import 'package:intl/intl.dart';

class LaporanWDAdmin extends StatefulWidget {
  final String tglAwal;
  final String tglAkhir;
  LaporanWDAdmin(
    {
      @required this.tglAwal,
      @required this.tglAkhir
    }
  ):super();
  @override
  _MyHomePageState createState() => _MyHomePageState(this.tglAwal,this.tglAkhir);
}

class _MyHomePageState extends State<LaporanWDAdmin> {
  String tglAwal,tglAkhir;
  _MyHomePageState(this.tglAwal,this.tglAkhir){}
  final _formKey = GlobalKey<FormState>();
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  List<ClassUbahSaldo> arrWD = new List.empty(growable: true);
  double totalWithdrawal=0.0;
  String statusWD = "Semua";
  int statusWDint = -1;

  final List<Color> warna = <Color>[globals.customBlue, globals.customGreen,globals.customYellow,
                                    globals.customLightRed];
  final List<String> keterangan =["Menunggu Konfirmasi","Telah Disetujui","Dibatalkan","Ditolak"];

  @override
  void initState() {
    super.initState();
    getWD();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Withdrawal"),
      ),
      body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height:10.0),
              Expanded(
                flex:1,
                child: Center(
                  child:Column(
                    children:[
                      Text("Periode "+globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(tglAwal)).toString())+" s/d "+
                      globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(tglAkhir)).toString())
                      , style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                      SizedBox(height:5.0),
                      statusWDint==-1||statusWDint==1?
                      Text("Total WD Disetujui : Rp "+myFormat.format(this.totalWithdrawal).toString(), style: TextStyle(fontSize: 22.0,fontWeight: FontWeight.bold))
                      :SizedBox(height:0)
                    ]
                  )
                ),
              ),
              SizedBox(height: 10.0,),
              Expanded(
                flex:1,
                child:Padding(
                      padding:EdgeInsets.only(left:15.0,right: 15.0),
                      child:DropdownButton<String>(
                        hint:Text("Status Withdrawal"),
                        isExpanded: true,
                        value:statusWD,
                        onChanged: (value){
                          setState(() {
                            statusWD=value;
                            if(statusWD=="Semua"){
                              statusWDint=-1;
                            }
                            else if(statusWD=="Disetujui"){
                              statusWDint=1;
                            }
                            else if(statusWD=="Ditolak"){
                              statusWDint=3;
                            }
                            getWD();
                          });
                        },
                        items:<String>['Semua','Disetujui','Ditolak'].map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value)
                          );
                        }).toList()
                      ),
                )
              ),
              Expanded(
                flex:6,
                child:Padding(
                  padding: EdgeInsets.only(left: 15.0,right: 15.0),
                  child:ListView.builder(
                        itemCount: arrWD.length==0 ? 1 : arrWD.length,
                        itemBuilder: (context,index){
                          if(arrWD.length==0){
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
                                  padding:EdgeInsets.all(10.0),
                                  child:Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              alignment: Alignment.topRight,
                                              child: Text(keterangan[arrWD[index].status],style: TextStyle(color:Colors.white,fontWeight:FontWeight.bold,backgroundColor: warna[arrWD[index].status]),),
                                            ),
                                            Row(
                                              mainAxisAlignment:MainAxisAlignment.start,
                                              crossAxisAlignment:CrossAxisAlignment.center,
                                              children: [
                                                CircleAvatar(
                                                  minRadius: 27,
                                                  backgroundColor: globals.customDarkBlue,
                                                  child: CircleAvatar(
                                                    backgroundImage: NetworkImage(globals.imgAdd+arrWD[index].logo),
                                                    minRadius: 25,
                                                  ),
                                                ),
                                                SizedBox(width:10.0),
                                                Text(arrWD[index].username,style:TextStyle(fontWeight: FontWeight.bold,fontSize: 18))
                                              ],
                                            ),
                                            Text("Pengajuan : "+globals.getDeskripsiTanggal(DateFormat("dd-MM-yyyy").format(DateTime.parse(arrWD[index].tanggal)).toString())+" "+arrWD[index].waktu,
                                                  style: TextStyle(fontWeight: FontWeight.bold),),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child:Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(arrWD[index].namaBank+" "+arrWD[index].invoiceUbahSaldo),
                                                      Text("a.n. "+arrWD[index].namaRekening),
                                                      arrWD[index].status==3?Text("Alasan Penolakan : "+arrWD[index].catatan):SizedBox()
                                                    ],
                                                  )
                                                ),
                                                Expanded(
                                                  flex:1,
                                                  child:Container(
                                                    alignment: Alignment.topRight,
                                                    child:Text("Rp "+myFormat.format(arrWD[index].nominal).toString(),style:TextStyle(fontWeight: FontWeight.bold,fontSize: 13)),
                                                  )
                                                )
                                              ],
                                            )
                                          ],
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
  Future<String> getWD() async{
    var url = Uri.parse(globals.ipnumber+'getLaporanWDAdmin');
    setState(() {
      arrWD.clear();
    });
    await http
            .post(url, body: {'tglAwal':tglAwal,'tglAkhir':tglAkhir,'status':statusWDint.toString()})
            .then((res){
              var result = json.decode(res.body);
              var status = result['status'];
              if(status=="Sukses"){
                this.totalWithdrawal = result['total'].toDouble();
                var data   = result['data'];
                var foto   = result['foto'];
                print(data);
                for(int i=0;i<data.length;i++){
                  int idTopUp = data[i]['idUbahSaldo'].toInt();
                  String invoiceUbahSaldo = data[i]['invoiceUbahSaldo'];
                  double nominal = data[i]['nominal'].toDouble();
                  String tanggal = data[i]['tanggal'];
                  String waktu = data[i]['waktu'];
                  String namaRekening = data[i]['namaRekening'];
                  String namaBank = data[i]['namaBank'];
                  int statusWd = data[i]['status'].toInt();
                  String catatan = data[i]['catatan'];
                  ClassUbahSaldo dataBaru = new ClassUbahSaldo(idTopUp, 1, invoiceUbahSaldo, nominal, tanggal, waktu, namaRekening, namaBank, statusWd, catatan);
                  dataBaru.username=data[i]['username'];
                  dataBaru.logo=foto[i];
                  setState(() {
                    arrWD.add(dataBaru);
                  }); 
                }
                print("size:"+arrWD.length.toString());
              }
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
  }
}