class ClassAlamat{
  int statusPribadi; //0=alamat pribadi, 1 bantuan
  int idAlamat;
  String alamat,kota,kodePos;
  double longitude,latitude;

  String namaPenerima,cp,telp;
  int jmlPenerima;
  String keterangan;
  String usernameInput;

  ClassAlamat(this.statusPribadi,this.idAlamat,this.alamat,this.kota,this.kodePos,this.longitude,this.latitude,
              this.namaPenerima,this.cp,this.telp,this.jmlPenerima){
                this.keterangan="";
                this.usernameInput="";
  }

  ClassAlamat.fromClassAlamat(ClassAlamat another) {
    this.statusPribadi = another.statusPribadi;
    this.idAlamat = another.idAlamat;
    this.alamat = another.alamat;
    this.kota = another.kota;
    this.kodePos = another.kodePos;
    this.longitude = another.longitude;
    this.latitude = another.latitude;
    this.namaPenerima = another.namaPenerima;
    this.cp = another.cp;
    this.telp = another.telp;
    this.jmlPenerima = another.jmlPenerima;
  }  
  
}