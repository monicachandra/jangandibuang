class ClassUbahSaldo{
  int idTopUp;
  int jenisUbah;
  String invoiceUbahSaldo;
  double nominal;
  String tanggal;
  String waktu;
  String namaRekening;
  String namaBank;
  int status;
  String catatan;
  String username;
  String logo;
  ClassUbahSaldo(this.idTopUp,this.jenisUbah,this.invoiceUbahSaldo,this.nominal,this.tanggal,this.waktu,
                  this.namaRekening,this.namaBank,this.status,this.catatan){
                    this.username="";
                    this.logo="";
                  }
}