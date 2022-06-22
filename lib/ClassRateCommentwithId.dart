import 'package:flutter/cupertino.dart';
class ClassRateCommentwithId{
  int idDOrder;
  String komentar;
  double rating;
  
  ClassRateCommentwithId(this.idDOrder,this.komentar,this.rating);

  Map toJson() => {
    'id': idDOrder,
    'komentar': komentar,
    'rating': rating
  };
}