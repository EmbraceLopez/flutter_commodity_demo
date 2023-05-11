class CommodityModel {
  List <CommodityItemModel>? result;

  CommodityModel({this.result});

  CommodityModel.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      result =  <CommodityItemModel>[];
      json['result'].forEach((v) {
        result!.add(new CommodityItemModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.result != null) {
      data['result'] = this.result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CommodityItemModel {

  String? name;
  String? img;
  double? price;
  int? salesVolume;
  int? categoryId;

 CommodityItemModel(
      {this.name,
      this.img,
      this.price,
      this.salesVolume,
      this.categoryId
      });

 CommodityItemModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    img = json['img'];
    price = json['price'];
    salesVolume = json['salesVolume'];
    categoryId = json['categoryId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['img'] = this.img;
    data['price'] = this.price;
    data['salesVolume'] = this.salesVolume;
    data['categoryId'] = this.categoryId;
    return data;
  }
}