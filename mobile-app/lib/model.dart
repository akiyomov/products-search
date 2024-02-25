class Response {
  ProductInfo? productInfo;

  Response({this.productInfo});

  Response.fromJson(Map<String, dynamic> json) {
    productInfo = json['product_info'] != null
        ? new ProductInfo.fromJson(json['product_info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.productInfo != null) {
      data['product_info'] = this.productInfo!.toJson();
    }
    return data;
  }
}

class ProductInfo {
  String? barcode;
  String? boycott;
  String? boycottReason;
  Null? certificate;
  String? company;
  String? country;
  String? imageUrl;
  String? package;
  String? product;
  String? type;
  String? volumeMl;

  ProductInfo(
      {this.barcode,
        this.boycott,
        this.boycottReason,
        this.certificate,
        this.company,
        this.country,
        this.imageUrl,
        this.package,
        this.product,
        this.type,
        this.volumeMl});

  ProductInfo.fromJson(Map<String, dynamic> json) {
    barcode = json['barcode'];
    boycott = json['boycott'];
    boycottReason = json['boycott_reason'];
    certificate = json['certificate'];
    company = json['company'];
    country = json['country'];
    imageUrl = json['image_url'];
    package = json['package'];
    product = json['product'];
    type = json['type'];
    volumeMl = json['volume_ml'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['barcode'] = this.barcode;
    data['boycott'] = this.boycott;
    data['boycott_reason'] = this.boycottReason;
    data['certificate'] = this.certificate;
    data['company'] = this.company;
    data['country'] = this.country;
    data['image_url'] = this.imageUrl;
    data['package'] = this.package;
    data['product'] = this.product;
    data['type'] = this.type;
    data['volume_ml'] = this.volumeMl;
    return data;
  }
}
