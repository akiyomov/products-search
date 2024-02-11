class Product {
  String? company;
  String? productname;
  String? type;
  String? package;
  String? volumeml;
  String? country;
  String? boycott;
  String? certificate;
  int? barcode;

  Product(
      {this.company,
      this.productname,
      this.type,
      this.package,
      this.volumeml,
      this.country,
      this.boycott,
      this.certificate,
      this.barcode});

  Product.fromJson(Map<String, dynamic> json) {
    company = json['company'];
    productname = json['productname'];
    type = json['type'];
    package = json['package'];
    volumeml = json['volumeml'];
    country = json['country'];
    boycott = json['boycott'];
    certificate = json['certificate'];
    barcode = json['barcode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['company'] = this.company;
    data['productname'] = this.productname;
    data['type'] = this.type;
    data['package'] = this.package;
    data['volumeml'] = this.volumeml;
    data['country'] = this.country;
    data['boycott'] = this.boycott;
    data['certificate'] = this.certificate;
    data['barcode'] = this.barcode;
    return data;
  }
}
