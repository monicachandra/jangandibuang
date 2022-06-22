import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassDetailWaste.dart';
import 'package:jangandibuang/ClassKomentar.dart';
import 'package:jangandibuang/laporanDonasiPembeli.dart';
import 'package:jangandibuang/laporanPembelianPembeli.dart';
import 'package:jangandibuang/laporanTopUpPembeli.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'ClassDailyWaste.dart';
import 'ClassDetailWaste.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ListLaporanPembeli extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ListLaporanPembeli> {
  final _formKey = GlobalKey<FormState>();
  String tanggalAwal='';
  String tanggalAkhir='';
  @override
  void initState() {
    super.initState();
    tanggalAwal = '${DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 4)))}';
    tanggalAkhir = '${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 3)))}';
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
    setState(() {
      if (args.value is PickerDateRange) {
        tanggalAwal='${DateFormat('yyyy-MM-dd').format(args.value.startDate)}';
        tanggalAkhir=args.value.endDate!=null?'${DateFormat('yyyy-MM-dd').format(args.value.endDate)}':'';
      } 
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text("Laporan untuk Pembeli"),
      ),
      body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex:5,
                child:Padding(
                  padding: EdgeInsets.only(left: 15.0,right: 15.0),
                  child: Column(
                    mainAxisAlignment:MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container (
                        child:ListTile(
                          title: Text(
                            "Periode",
                            style: TextStyle(color: globals.customDarkBlue, fontSize: 12.0,fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            this.tanggalAwal+" s/d "+this.tanggalAkhir,
                            style: TextStyle(fontSize: 18.0,color:Colors.black),
                          ),
                        ),
                      ),
                      SfDateRangePicker(
                        onSelectionChanged: _onSelectionChanged,
                        selectionMode: DateRangePickerSelectionMode.range,
                        initialSelectedRange: PickerDateRange(
                            DateTime.now().subtract(const Duration(days: 4)),
                            DateTime.now().add(const Duration(days: 3))),
                      ),
                      GestureDetector(
                        onTap:(){
                          if(tanggalAwal!=null && tanggalAkhir!=null){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LaporanTopUpPembeli(
                                  tglAwal:tanggalAwal,
                                  tglAkhir:tanggalAkhir
                                )
                              ) 
                            );
                          }
                          else{
                            if(tanggalAwal==null){
                              globals.buatToast("Anda belum memilih tanggal awal");
                            }
                            else{
                              globals.buatToast("Anda belum memilih tanggal akhir");
                            }
                          }
                        },
                        child:Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          shadowColor: Colors.black,
                          color: globals.customLightBlue,
                          child: Padding(
                            padding:EdgeInsets.only(left:15.0,right:15.0,top:15.0,bottom:15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex:1,
                                  child:Icon(Icons.money)
                                ),
                                Expanded(
                                  flex:5,
                                  child:Text("Laporan Top Up",style:TextStyle(fontWeight: FontWeight.bold))
                                ),
                                Expanded(
                                  flex:1,
                                  child:Icon(Icons.chevron_right)
                                )
                              ],
                            )
                          )
                        ),
                      ),
                      GestureDetector(
                        onTap:(){
                          if(tanggalAwal!=null && tanggalAkhir!=null){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LaporanPembelianPembeli(
                                  tglAwal:tanggalAwal,
                                  tglAkhir:tanggalAkhir
                                )
                              ) 
                            );
                          }
                          else{
                            if(tanggalAwal==null){
                              globals.buatToast("Anda belum memilih tanggal awal");
                            }
                            else{
                              globals.buatToast("Anda belum memilih tanggal akhir");
                            }
                          }
                        },
                        child:Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                shadowColor: Colors.black,
                                color: globals.customLightBlue,
                                child: Padding(
                                  padding:EdgeInsets.only(left:15.0,right:15.0,top:15.0,bottom:15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex:1,
                                        child:Icon(Icons.history)
                                      ),
                                      Expanded(
                                        flex:5,
                                        child:Text("Laporan Pembelian",style:TextStyle(fontWeight: FontWeight.bold))
                                      ),
                                      Expanded(
                                        flex:1,
                                        child:Icon(Icons.chevron_right)
                                      )
                                    ],
                                  )
                                )
                              )
                      ),
                      GestureDetector(
                        onTap:(){
                          if(tanggalAwal!=null && tanggalAkhir!=null){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LaporanDonasiPembeli(
                                  tglAwal:tanggalAwal,
                                  tglAkhir:tanggalAkhir
                                )
                              ) 
                            );
                          }
                          else{
                            if(tanggalAwal==null){
                              globals.buatToast("Anda belum memilih tanggal awal");
                            }
                            else{
                              globals.buatToast("Anda belum memilih tanggal akhir");
                            }
                          }
                        },
                        child:Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                shadowColor: Colors.black,
                                color: globals.customLightBlue,
                                child: Padding(
                                  padding:EdgeInsets.only(left:15.0,right:15.0,top:15.0,bottom:15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex:1,
                                        child:Icon(Icons.card_giftcard)
                                      ),
                                      Expanded(
                                        flex:5,
                                        child:Text("Laporan Donasi",style:TextStyle(fontWeight: FontWeight.bold))
                                      ),
                                      Expanded(
                                        flex:1,
                                        child:Icon(Icons.chevron_right)
                                      )
                                    ],
                                  )
                                )
                              )
                      )
                    ],
                  )
                )
              ),
            ]
          )
    );
  }
}