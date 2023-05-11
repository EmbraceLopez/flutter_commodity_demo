import 'package:flutter/material.dart';
import 'package:flutter_jd/pages/SearchPage.dart';

import '../pages/CommodityList.dart';
import '../pages/Tabs.dart';

final routes = {
  '/' : (context) => Tabs(),
  '/commodityList' : (context,{arguments}) => CommodityList(arguments: arguments,),  //可选参数加上{}，传值时加上参数名：参数值
  '/searchPage' : (context) => SearchPage(),
};

final onGenerateRoute = (RouteSettings settings){
  final String? name = settings.name;
  final Function pageContentBuilder = routes[name] as Function;

  if(pageContentBuilder != null){
    //是否传参
    if(settings.arguments != null){
      final Route route = MaterialPageRoute(
        builder: (context) => pageContentBuilder(context, arguments : settings.arguments)
      );
      return route;
    }
    else{
      final Route route = MaterialPageRoute(
        builder: (context) => pageContentBuilder(context)
      );
      return route;
    }
  }
};