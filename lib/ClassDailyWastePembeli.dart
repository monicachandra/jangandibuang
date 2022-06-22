import 'package:flutter/cupertino.dart';
import 'package:jangandibuang/ClassKomentar.dart';

import 'ClassDailyWaste.dart';
class ClassDailyWastePembeli{
  String username;
  String logo;
  List<ClassDailyWaste> arrWasteDaily = new List.empty(growable: true);
  double rating;
  List<ClassKomentar> arrKomentar = new List.empty(growable: true);
  
  ClassDailyWastePembeli(this.username,this.logo,this.arrWasteDaily,this.rating,this.arrKomentar);
}