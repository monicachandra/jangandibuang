import 'package:flutter/material.dart';
import 'package:jangandibuang/ClassListofChat.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'globals.dart' as globals;

class ShowChat extends StatefulWidget {
  final String nama;
  ShowChat({Key key, @required this.nama}) : super(key: key);
  @override
  _MyHomePageState createState() => new _MyHomePageState(this.nama);
}

class _MyHomePageState extends State<ShowChat> {
  String nama;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController teksChat = new TextEditingController();
  String channel;
  String username1 = globals.loginuser;

  _MyHomePageState(this.nama) {
    print("nama = " + this.nama);
    print("ini username1 = " + username1);
    if (this.nama.compareTo(username1) < 0) {
      channel = this.nama + username1;
    } else {
      channel = username1 + this.nama;
    }
  }

  @override
  void initState() {
    super.initState();
    print("nama = " + this.nama);
    print("ini username1 = " + username1);
    getDataUser();
  }

  void getDataUser(){
    setState(() {
      globals.arrOfUserLoginChat.clear();
      globals.arrOfOtherUserChat.clear();
      globals.arrOfFotoUser.clear();
    });
    getDataUserFirebase();
  }
  Future<String> getDataUserFirebase() async{
    //ambil daftar user yang diajak chatting sama org login
    FirebaseFirestore.instance
        .collection("daftaruser" + globals.loginuser)
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((f) {
        print(f.get("user")); 
        if(f.get("user")==this.nama){
          setState(() {
            ClassListofChat listBaru = new ClassListofChat(f.get("user"), f.get("lastMessage"), f.get("tanggal").toString(), 0,f.id);
            globals.arrOfUserLoginChat.add(listBaru);
             FirebaseFirestore.instance.collection("daftaruser"+globals.loginuser).doc(f.id).update({
              'jumlahMessage':'0'});
          });
        }
        else{
          String jumlahMessage = f.get("jumlahMessage");
          int jumlahM = int.parse(jumlahMessage);
          print(jumlahM.toString());
          setState(() {
            ClassListofChat listBaru = new ClassListofChat(f.get("user"), f.get("lastMessage"), f.get("tanggal").toString(), jumlahM,f.id);
            globals.arrOfUserLoginChat.add(listBaru);
          });
        }
      });
    });
    // ambil daftaruser masukkan ke array utk username yg diajak chatting
    FirebaseFirestore.instance
        .collection("daftaruser" + this.nama)
        .get()
        .then((QuerySnapshot snapshot) {
          print("inisnapshot"+snapshot.docs.length.toString());
      snapshot.docs.forEach((f) {
        print(f.get("user")); 
        String jumlahMessage = f.get("jumlahMessage");
        int jumlahM = int.parse(jumlahMessage);
        print(jumlahM.toString());
        setState(() {
          ClassListofChat listBaru = new ClassListofChat(f.get("user"), f.get("lastMessage"), f.get("tanggal").toString(), jumlahM,f.id);
          globals.arrOfOtherUserChat.add(listBaru);
        });
      });
    });
    return "sukses";
  }

  void sendmessage() async {
    var teks = teksChat.text;
    teksChat.text = "";

    DocumentReference ref = await _firestore.collection(channel).add({
      'user1': username1,
      'user2': nama,
      'teks': teks,
      'tanggal': DateTime.now().toString()
    });

    globals.buatPushNotif(nama, "Chat Baru dari "+username1, teks);

    bool ada = false;
    print("size"+globals.arrOfOtherUserChat.length.toString());
    for(int i=0;i<globals.arrOfOtherUserChat.length;i++){
      if(globals.loginuser==globals.arrOfOtherUserChat[i].username){
        ada=true;
        print("ada");
      }
    }
    print("ada"+ada.toString());
    String tgl = DateTime.now().toString();
    if(!ada){
      DocumentReference ref2 = await _firestore.collection("daftaruser"+this.nama).add({
        'user':username1,
        'tanggal':tgl,
        'lastMessage':teks,
        'jumlahMessage':'1'
      });
      globals.arrOfOtherUserChat.add(new ClassListofChat(username1, teks, tgl, 1,ref2.id));
    }
    else{
      print("sudahada");
      int posisi=-1;
      for(int i=0;i<globals.arrOfOtherUserChat.length;i++){
        if(globals.arrOfOtherUserChat[i].username==globals.loginuser){
          posisi=i;
        }
      }
      int jumSkg = globals.arrOfOtherUserChat[posisi].jumlahMessage;
      jumSkg++;
      setState(() {
        globals.arrOfOtherUserChat[posisi].jumlahMessage=jumSkg;
        globals.arrOfOtherUserChat[posisi].tanggal=tgl;
        globals.arrOfOtherUserChat[posisi].teks=teks;
      });
      FirebaseFirestore.instance.collection("daftaruser"+this.nama).doc(globals.arrOfOtherUserChat[posisi].id).update({
        'tanggal':tgl,
        'lastMessage':teks,
        'jumlahMessage':jumSkg.toString()});
    }

    bool ada2 = false;
    for(int i=0;i<globals.arrOfUserLoginChat.length;i++){
      if(this.nama==globals.arrOfUserLoginChat[i].username){
        ada2=true;
        print("ada2");
      }
    }
    print("ada2"+ada2.toString());
    if(!ada2){
      DocumentReference ref3 = await _firestore.collection("daftaruser"+this.username1).add({
        'user':this.nama,
        'tanggal':DateTime.now().toString(),
        'lastMessage':teks,
        'jumlahMessage':'0'
      });
      globals.arrOfUserLoginChat.add(new ClassListofChat(this.nama, teks, DateTime.now().toString(), 0,ref3.id));
    }
    else{
      print("sudahada");
      int posisi=-1;
      for(int i=0;i<globals.arrOfUserLoginChat.length;i++){
        if(globals.arrOfUserLoginChat[i].username==this.nama){
          posisi=i;
        }
      }
      setState(() {
        globals.arrOfUserLoginChat[posisi].tanggal=tgl;
        globals.arrOfUserLoginChat[posisi].teks=teks;
      });
      FirebaseFirestore.instance.collection("daftaruser"+this.username1).doc(globals.arrOfUserLoginChat[posisi].id).update({
        'tanggal':tgl,
        'lastMessage':teks});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(nama)),
        body: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: _buildBody(context),
              ),
              Container(
                color: Colors.white,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 7,
                          child: TextFormField(
                            controller: teksChat,
                            keyboardType: TextInputType.text,
                            style: TextStyle(color: Colors.blue),
                            decoration: InputDecoration(
                                hintText: "Chat",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                /*icon: Icon(
                                  Icons.email,
                                  color: Colors.grey,
                                )*/),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: sendmessage,
                            child: Icon(
                              Icons.send,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget _buildBody(BuildContext context) {
    FirebaseFirestore.instance
        .collection(channel)
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((f) => print('${f.data}}'));
    });

    var data = FirebaseFirestore.instance
        .collection(channel)
        .orderBy('tanggal')
        .snapshots();
    //print('ini chanel yang ditarik : ' + channel.toString());

    return StreamBuilder<QuerySnapshot>(
      stream: data,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
    //print("cek = " + record.user1 + "-" + username1);
    if (record.user1 == username1) {
      // rata kanan
      return Padding(
        key: ValueKey(record.tanggal),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0)),
              child: Text(record.teks,
                  style: TextStyle(
                    fontSize: 20.0,
                  )),
            ),
            Padding(padding: const EdgeInsets.only(top: 5.0)),
            Text(record.tanggal.substring(0, 16) + "",
                style: TextStyle(fontSize: 10.0, color: Colors.black)),
            Padding(padding: const EdgeInsets.only(top: 10.0)),
          ],
        ),
      );
    } else {
      return Padding(
        key: ValueKey(record.tanggal),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0)),
              child: Text(record.teks,
                  style: TextStyle(
                    fontSize: 20.0,
                  )),
            ),
            Padding(padding: const EdgeInsets.only(top: 5.0)),
            Text(record.tanggal.substring(0, 16) + "",
                style: TextStyle(fontSize: 10.0, color: Colors.black)),
            Padding(padding: const EdgeInsets.only(top: 10.0)),
          ],
        ),
      );
    }
  }
}

class Record {
  final String user1;
  final String user2;
  final String teks;
  final String tanggal;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['user1'] != null),
        assert(map['user2'] != null),
        assert(map['teks'] != null),
        assert(map['tanggal'] != null),
        user1 = map['user1'],
        user2 = map['user2'],
        teks = map['teks'],
        tanggal = map['tanggal'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => "Record<$user1:$user2:$teks:$tanggal>";
}