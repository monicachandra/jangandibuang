import 'package:jangandibuang/ClassReportForum.dart';

class ClassForum{
  int idForum;
  String judulForum;
  String deskripsiForum;
  String tanggalForum;
  String fotoForum;
  String username;
  String jenisUser;
  int statusAktif;
  String profileUser;
  List<ClassReportForum> arrReport = new List.empty(growable: true);
  ClassForum(this.idForum,this.judulForum,this.deskripsiForum,this.tanggalForum,this.fotoForum,this.username,this.jenisUser,this.statusAktif,this.profileUser,this.arrReport);
}