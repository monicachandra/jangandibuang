import 'package:jangandibuang/ClassAlamat.dart';
import 'package:jangandibuang/ClassDailyWaste.dart';
import 'package:jangandibuang/ClassDetailShoppingCart.dart';
import 'dart:convert';
class ClassHOrder{
  int idHOrder;
  String tanggalOrder,waktuOrder,usernamePembeli,usernamePenjual;
  double totalHargaBarang,biayaOngkir;
  int isDonasi;
  int alamatDonasi,alamatPribadi;
  String alamatPengiriman;
  String keteranganPenjual;
  String CP;
  int jenisPengiriman;
  String informasiTambahanPengiriman;
  int statusPengiriman;
  double rating;
  String comment;
  double appFee;

  ClassHOrder(this.idHOrder,this.tanggalOrder,this.waktuOrder,this.usernamePembeli,this.usernamePenjual,
              this.totalHargaBarang,this.biayaOngkir,this.isDonasi,this.alamatDonasi,this.alamatPribadi,
              this.alamatPengiriman,this.CP,this.jenisPengiriman,this.informasiTambahanPengiriman,this.statusPengiriman,
              this.keteranganPenjual,this.rating,this.comment,this.appFee);
}