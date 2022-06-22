import 'package:flutter/material.dart';
import 'package:jangandibuang/addForum.dart';
import 'package:jangandibuang/daftarAlamatPembeli.dart';
import 'package:jangandibuang/dashboardGuest.dart';
import 'package:jangandibuang/historyOrderPembeli.dart';
import 'package:jangandibuang/registerEmailGuest.dart';
import 'package:jangandibuang/showMap.dart';
import 'package:jangandibuang/topUp.dart';
import 'checkOutPembeli.dart';
import 'addDailyWaste.dart';
import 'addMasterBarangVendor.dart';
import 'register.dart';
import 'login.dart';
import 'admin.dart';
import 'vendor.dart';
import 'pembeli.dart';
import 'addBarangVendor.dart';

final Color customDarkBlue = Color.fromARGB(255, 41, 53, 89);
final Color customYellow = Color.fromARGB(255, 255, 199, 0);
final Color customLightBlue = Color.fromARGB(255, 214, 226, 249);
final Color customWhite = Color.fromARGB(255, 255, 255, 255);

ThemeData _buildTheme() {       
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    primaryColor: customDarkBlue,
    backgroundColor: customWhite,
    appBarTheme: _appBarTheme(base.appBarTheme),
    textTheme: _textTheme(base.textTheme),
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: customDarkBlue
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(  
      style: ElevatedButton.styleFrom(
        primary:customDarkBlue
      )
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: customDarkBlue
    )
  );
}

AppBarTheme _appBarTheme(AppBarTheme base) => base.copyWith(
      color: customDarkBlue,
      brightness: Brightness.light,
      textTheme: TextTheme(
          headline1: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18.0,
              fontFamily: 'Nunito',
              color: customWhite),),
      iconTheme: IconThemeData(color: customWhite));

TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      headline1: base.headline1.copyWith(
          fontWeight: FontWeight.w500,
          fontFamily: 'Nunito'),
          //color: ACCENT_COLOR),
      subtitle1: base.subtitle1.copyWith(
          fontSize: 20,
          //    fontWeight: FontWeight.w600,
          fontFamily: 'Nunito'),
          //color: ACCENT_COLOR),
      caption: base.caption.copyWith(
          fontWeight: FontWeight.w400,
          fontFamily: 'Nunito'),
          //  fontSize: TEXT_FONT_SIZE,
          //color: ACCENT_COLOR),
      bodyText1: base.bodyText1.copyWith(
          fontWeight: FontWeight.w400,
          fontFamily: 'Nunito'),
          //   fontSize: TEXT_FONT_SIZE,
          //color: ACCENT_COLOR),
      bodyText2: base.bodyText2.copyWith(
          fontWeight: FontWeight.w500,
          fontFamily: 'Nunito'),
          //  fontSize: TEXT_LARGE_FONT_SIZE,
          //color: ACCENT_COLOR),
      button: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontFamily: 'Nunito',
          fontSize: 16),
    );
  }
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jangan Dibuang',
      theme: _buildTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => Login(),
        '/register' : (context) => Register(),
        '/admin' : (context) => Admin(),
        '/vendor' : (context) => Vendor(),
        '/pembeli' : (context) => Pembeli(),
        '/addMasterBarangVendor':(context)=>AddMasterBarangVendor(),
        '/addBarangVendor' : (context) => AddBarangVendor(),
        '/addDailyWaste' : (context) => AddDailyWaste(),
        '/checkOutPembeli': (context) => CheckOutPembeli(),
        '/historyOrderPembeli' : (context) => HistoryOrderPembeli(),
        '/topUp': (context) => TopUp(),
        '/daftarAlamatPembeli': (context) => DaftarAlamatPembeli(),
        '/showMap': (context)=>ShowMap(),
        '/addForum':(context)=>AddForum(),
        '/dashboardGuest':(context)=>DashboardGuest(),
        '/registerEmailGuest':(context)=>RegisterEmailGuest()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
    );
  }
}
