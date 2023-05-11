import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/**
 * 此文件夹下保存的是可公用的自定义组件widget
 */
/**
 * 加载中...
 */
class LoadingWidget extends StatelessWidget{

  const LoadingWidget({Key ? key}) :super(key : key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
              strokeWidth: 1.0,
            ),
            Text('加载中...',style: TextStyle(fontSize: 30.sp),)
          ],
        ),
      ),
    );
  }
}