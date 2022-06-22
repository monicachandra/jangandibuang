import 'package:flutter/cupertino.dart';

class ClassDailyWasteItem{
  int idBarang;
  String nama;
  String foto;
  int stok;
  int hargaAsli;
  int hargaWaste;
  //TextEditingController ctrlStok;
  TextEditingController ctrlHargaWaste;
  ClassDailyWasteItem(this.idBarang,this.nama,this.foto,this.stok,this.hargaAsli,this.hargaWaste){
    //this.ctrlStok = new TextEditingController();
    //ctrlStok.text = "1";
    this.ctrlHargaWaste = new TextEditingController();
    ctrlHargaWaste.text = this.hargaWaste.toString();
  }

  Map toJson() => {
        'idBarang': idBarang,
        'nama': nama,
        'foto': foto,
        'stok': stok,
        'hargaAsli': hargaAsli,
        'hargaWaste': hargaWaste,
      };
}