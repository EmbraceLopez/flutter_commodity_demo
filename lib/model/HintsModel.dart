class HintsModel{
  List<HintsItemModel>? result;

  HintsModel({this.result});

  HintsModel.fromjson(Map<String,dynamic> json){
    if(json['result'] != null){
      result = <HintsItemModel>[];
      json['result'].forEach(
        (value){
          result!.add(new HintsItemModel.fromJson(value));  //遍历json数组，取出json对象，将json对象转为模型类对象，再放入list数组
        }
      );
    }
  }

  Map<String,dynamic> tojson(){
    final Map<String,dynamic> data = new Map<String,dynamic>();
    if(this.result != null){
      data['result'] = this.result!.map(
        (v){
          v.toJson();
        }
      ).toList();
    }
    return data;
  }
}

/**
 * json数组中json对象
 */
class HintsItemModel {

  String? hints;


  HintsItemModel({this.hints});

  HintsItemModel.fromJson(Map<String, dynamic> json) {
    hints = json['hints'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hints'] = this.hints;
    return data;
  }
}