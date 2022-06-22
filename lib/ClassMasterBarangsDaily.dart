class ClassMasterBarangsDaily{
  int idBarang;
  int idKategori;
  String namaBarang;
  String deskripsiBarang;
  int hargaBarangAsli;
  int hargaBarangFoodWaste;
  String foto;
  bool chosen;
  String keteranganAda;
  ClassMasterBarangsDaily(this.idBarang,this.idKategori,this.namaBarang,this.deskripsiBarang,this.hargaBarangAsli,this.hargaBarangFoodWaste,this.foto,this.chosen){
    this.keteranganAda="";
  }
}