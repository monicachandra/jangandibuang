import 'package:jangandibuang/ClassAlamat.dart';
import 'package:jangandibuang/ClassDailyWaste.dart';
import 'package:jangandibuang/ClassDetailShoppingCart.dart';
import 'dart:convert';
class ClassShoppingCart{
  String usernamePenjual,usernamePembeli;
  double totalHargaBarang;
  double biayaOngkir;
  int isDonasi; //0=pribadi,1=donasi;
  ClassAlamat idDonasi,idAlamat;
  int jenisPengiriman;//0=self pick up, 1=kurir, 2=gojek;
  double ongkirperM; 
  //String informasiPengiriman; //namaKurir-noHPKurir-noPolKurir
  //int statusOrder; //1=Aktif,2=DiProses,3=DiKirim,4=Terkirim,5=Diterima,6=Cancel
  List<ClassDetailShoppingCart> arrDetailShoppingCart = new List.empty(growable: true);
  List<ClassDailyWaste> arrDetailBarang = new List.empty(growable: true);
  ClassShoppingCart(this.usernamePenjual,this.usernamePembeli,this.totalHargaBarang,this.biayaOngkir,
                    this.isDonasi,this.idDonasi,this.idAlamat,this.jenisPengiriman,
                    this.arrDetailShoppingCart,this.arrDetailBarang,this.ongkirperM);
  Map toJson() => {
    'usernamePenjual': usernamePenjual,
    'usernamePembeli': usernamePembeli,
    'totalHargaBarang': totalHargaBarang,
    'biayaOngkir': biayaOngkir,
    'isDonasi': isDonasi,
    'idDonasi': idDonasi==null?null:idDonasi.idAlamat,
    'idAlamat': idAlamat==null?null:idAlamat.idAlamat,
    'jenisPengiriman': jenisPengiriman,
    'arrDetailShoppingCart': json.encode(arrDetailShoppingCart),
  };
}