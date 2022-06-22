import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:jangandibuang/ClassDetailWaste.dart';
class ClassDetailOrder{
  int idDailyWaste;
  int isPaket;
  int idBarang;
  String namaBarang;
  int qty;
  double harga;
  double rating;
  String comment;
  List<String> arrFoto = new List.empty(growable: true);
  List<ClassDetailWaste> arrDetail = new List.empty(growable: true);
  TextEditingController ctrlComment;
  int idDOrder;

  ClassDetailOrder(this.idDailyWaste,this.isPaket,this.idBarang,this.namaBarang,this.qty,this.harga,
                    this.arrFoto,this.arrDetail,this.rating,this.comment,this.idDOrder){
    this.ctrlComment = new TextEditingController();
    this.ctrlComment.text = "";
  }
}