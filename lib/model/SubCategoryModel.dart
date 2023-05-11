class SubCategoryModel {
  List<SubCategoryItemModel>? result;

  SubCategoryModel({this.result});

  SubCategoryModel.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      result = <SubCategoryItemModel>[];
      json['result'].forEach((v) {
        result!.add(new SubCategoryItemModel.fromJson(v));
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

class SubCategoryItemModel {
  int? id;
  int? parentId;
  String? subTitle;
  String? shrinkPic;

  SubCategoryItemModel({this.id, this.parentId, this.subTitle, this.shrinkPic});

  SubCategoryItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parentId'];
    subTitle = json['subTitle'];
    shrinkPic = json['shrinkPic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['parentId'] = this.parentId;
    data['subTitle'] = this.subTitle;
    data['shrinkPic'] = this.shrinkPic;
    return data;
  }
}