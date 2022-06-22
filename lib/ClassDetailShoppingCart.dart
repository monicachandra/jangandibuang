class ClassDetailShoppingCart{
  int idBarang,qty;
  double harga;
  ClassDetailShoppingCart(this.idBarang,this.qty,this.harga);

  Map toJson() => {
    'idBarang': idBarang,
    'qty': qty,
    'harga': harga,
  };
}