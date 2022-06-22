import 'package:flutter/cupertino.dart';
import 'package:jangandibuang/ClassKomentar.dart';
import 'ClassDetailWaste.dart';
class ClassDailyWaste{
  int id;
  int isPaket;
  int idBarang;
  String namaBarang;
  int stok;
  int stokPesan;
  int hargaWaste;
  int hargaAsli;
  List<String> arrFoto = new List.empty(growable: true);
  List<ClassDetailWaste> arrDetail = new List.empty(growable: true);
  double totalRatingMakanan;
  List<ClassKomentar> arrKomentar = new List.empty(growable: true);
  String deskripsi;
  String kategori;
  
  ClassDailyWaste(this.id,this.isPaket,this.idBarang,this.namaBarang,this.stok,
                  this.hargaWaste,this.arrFoto,this.arrDetail,this.totalRatingMakanan,this.arrKomentar,this.kategori,this.deskripsi)
  {
    hargaAsli=0;
    stokPesan=0;
  }

  Map toJson() => {
    'id': id,
    'nama': namaBarang,
    'stok': stok,
    'hargaWaste': hargaWaste
  };
}