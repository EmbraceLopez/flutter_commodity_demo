import 'dart:convert';

import 'Storage.dart';

class SearchServices {

  static setHistoryData(keywords) async {
    try {
      List searchListData = json.decode(await Storage.getString('searchList'));
      print(searchListData);
      var hasData = searchListData.any((v) {
        return v == keywords;
      });
      if (!hasData) {
        searchListData.add(keywords);
        await Storage.setString('searchList', json.encode(searchListData));
      }
    } catch (e) {
      List tempList = List.empty(growable: true);
      tempList.add(keywords);
      await Storage.setString('searchList', json.encode(tempList));
    }
  }
  static getHistoryList() async{
     try {
      List searchListData = json.decode(await Storage.getString('searchList'));
      return searchListData;
    } catch (e) {
      return [];
    }
  }

  static clearHistoryList() async{    
      await Storage.remove('searchList');
  }
  static removeHistoryData(keywords) async{    
      List searchListData = json.decode(await Storage.getString('searchList'));
      searchListData.remove(keywords);
      await Storage.setString('searchList', json.encode(searchListData));
  }

}
