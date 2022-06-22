import 'package:flutter/cupertino.dart';
import 'package:jangandibuang/ClassKomentar.dart';
import 'ClassDetailWaste.dart';
class ClassRankLaku{
  int id;
  int isPaket;
  int idBarang;
  String namaBarang;
  int terjual;
  List<String> arrFoto = new List.empty(growable: true);
  List<ClassDetailWaste> arrDetail = new List.empty(growable: true);
  double totalRatingMakanan;
  List<ClassKomentar> arrKomentar = new List.empty(growable: true);
  String deskripsi;
  String kategori;
  
  ClassRankLaku(this.id,this.isPaket,this.idBarang,this.namaBarang,this.terjual,
                  this.arrFoto,this.arrDetail,this.totalRatingMakanan,this.arrKomentar,this.kategori,this.deskripsi);
}