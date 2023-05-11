/**
 * json转map-》反序列化
 * map转json-》序列化
 * 
 * //手动
 * import 'dart:convert';
 * 
 * String str = '{"SwiperItemModel":[{"id":"fewuciwe23423","title":"电器","pic":"/images/","url":"10"}]}';
 * var strData = '{"name" : "张三","age" : 18}';  //json字符串
 * var SwiperItemModel = json.decode(strData);  //json转map 反序列化-》通过键名取值（解析json数据）
 * 
 * //模型类
 * 
 */
/**
 * 最外层json对象，其值为json数组
 */
class SwiperModel{
  List<SwiperItemModel>? result;

  SwiperModel({this.result});

  SwiperModel.fromjson(Map<String,dynamic> json){
    if(json['result'] != null){
      result = <SwiperItemModel>[];
      json['result'].forEach(
        (value){
          result!.add(new SwiperItemModel.fromJson(value));  //遍历json数组，取出json对象，将json对象转为模型类对象，再放入list数组
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
class SwiperItemModel {
  int? id;
  String? title;
  String? pic;
  String? url;

  SwiperItemModel({this.id, this.title, this.pic, this.url});

  SwiperItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    pic = json['pic'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['pic'] = this.pic;
    data['url'] = this.url;
    return data;
  }
}


