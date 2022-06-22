// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'ClassShoppingCart.dart';
import 'ClassListofChat.dart';
import 'package:jangandibuang/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jangandibuang/register.dart';
import 'package:passwordfield/passwordfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

String loginuser = "guest";
String loginjenis= "G"; 

String ipnumber = "http://192.168.1.7/webServiceTa/public/";
String imgAdd = "http://192.168.1.7/webServiceTa/public/gambar/";
String imgAddMakanan = "http://192.168.1.7/webServiceTa/public/makanan/";
String imgForum = "http://192.168.1.7/webServiceTa/public/forum/";
String imgLogo = "http://192.168.1.7/webServiceTa/public/logo/logo.PNG";

String alamat="";

int idAddMakanan = -1;
String namaAddMakanan = "";
int modeAdd = 1; //1 add, 0 edit;
String vendorTerverifikasi = "0"; //0 belum, 1 sudah
String isVerified = "0"; //0 belum, 1 sudah

int selectedIndexBottomNavBarPembeli=0;

void buatToast(message){
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
    );
}

Future<String> buatPushNotif(String username,String judul,String isi) async{
    var url = Uri.parse(ipnumber+'sendNotification');
    await http
            .post(url, body: {'username': username,'judul':judul,'isi':isi})
            .then((res){
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
}

Future<String> buatPushNotifAdmin(String judul,String isi) async{
    var url = Uri.parse(ipnumber+'sendNotificationAdmin');
    await http
            .post(url, body: {'judul':judul,'isi':isi})
            .then((res){
            })
            .catchError((err){
              print(err);
            });
    return "suksess";
}

getDeskripsiTanggal(tanggal) {
  var namaBulan = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mei",
    "Jun",
    "Jul",
    "Agu",
    "Sep",
    "Okt",
    "Nov",
    "Des"
  ];
  var node = tanggal.split("-");
  if(node[0].toString().length == 4) {
    return node[2] + " " + namaBulan[int.parse(node[1]) - 1] + " " + node[0];
  }
  else {
    return node[0] + " " + namaBulan[int.parse(node[1]) - 1] + " " + node[2];
  }
}

ClassShoppingCart myShoppingCart=null;

double longitude=0.0;
double latitude=0.0;

final Color customDarkBlue = Color.fromARGB(255, 41, 53, 89);
final Color customYellow = Color.fromARGB(255, 255, 199, 0);
final Color customRed = Color.fromARGB(255,252, 82, 133);
final Color customLightRed = Color.fromARGB(255,238, 138, 138);
final Color customLightBlue = Color.fromARGB(255, 214, 226, 249);
final Color customWhite = Color.fromARGB(255, 255, 255, 255);
final Color customGrey = Color.fromARGB(255, 83, 85, 89);
final Color customGreen = Color.fromARGB(255, 24, 158, 102);
final Color customLightGreen = Color.fromARGB(255, 138, 237, 164);
final Color customBlue = Color.fromARGB(255,69, 124, 213);
final Color customBlue2 = Color.fromARGB(255, 44, 103, 196);

List<ClassListofChat> arrOfUserLoginChat = new List.empty(growable: true);
List<String> arrOfFotoUser      = new List.empty(growable: true);
List<ClassListofChat> arrOfOtherUserChat = new List.empty(growable: true);

final String apiKeyGoogleMap = "";