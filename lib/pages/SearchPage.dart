// ignore_for_file: deprecated_member_use

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jd/config/Config.dart';
import 'package:flutter_jd/model/HintsModel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../service/SearchService.dart';

class SearchPage extends StatefulWidget{
  SearchPage({Key ? key}) :super(key : key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>{

  var textFieldHeight = AppBar().preferredSize.height / 3;
  var listViewHeight = ScreenUtil().screenWidth;

  //历史搜索
  List _searchList = [];
  //搜索提示
  List _hintsList = [];
  //搜索提示值
  var _textController = new TextEditingController();

  //输入框值
  var _editText = '';

  @override
  void initState() {
    super.initState();
    _getHistoryList();
    //this._searchList = SearchService.getHistoryList();
  }

  _getHistoryList() async{
    List _historyListData = await SearchServices.getHistoryList();
    setState(() {
      if(_historyListData != null){   //通过null判断数组是否为空
        this._searchList = _historyListData;
      }
    });
  }

  //获取搜索提示数据
  _getHintsList(value) async{
    var api = '${Config.domain}searchHintsByKeyword?keyword=${value}';
    //print(api);
    var result = await Dio().get(api);
    var hintsList = HintsModel.fromjson(result.data);
    setState(() {
      this._hintsList = hintsList.result!;
    });
  }

  //标题
  Widget _titleContainer(titleStr){
    return Container(
      child: Text(
        titleStr,
        style: TextStyle(
          fontSize: 30.sp,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  //历史记录
  Widget _historyWidget(){
    if(this._searchList.length > 0){
      return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _titleContainer('历史搜索'),
            Container(
              width: double.infinity,
              height: listViewHeight - (textFieldHeight * 2),  //搜索历史需要减去清空历史按钮的高度
              child: ListView.builder(
                itemCount: this._searchList.length,
                itemBuilder: (context,index){
                  return Column(
                    children: <Widget>[
                      ListTile(
                        title: Text('${this._searchList[index]}')
                      ),
                      this._searchList[index] != null ? Divider(height: 1,) : SizedBox(height: 0,)
                    ],
                  );
                }
              ),
            )
          ],
        ),
      );
    }else{
      return Text('');
    }
  }

  //body
  Widget searchBody(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,  //设置次轴（水平）对齐方式
      children: <Widget>[
        //热搜
        Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _titleContainer('热搜'),
              Wrap(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(right: 10,top: 10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(233, 233, 233, 0.9),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text('手机')
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(right: 10,top: 10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(233, 233, 233, 0.9),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text('笔记本')
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(right: 10,top: 10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(233, 233, 233, 0.9),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text('水果')
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(right: 10,top: 10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(233, 233, 233, 0.9),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text('家电')
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(right: 10,top: 10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(233, 233, 233, 0.9),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text('华为')
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(right: 10,top: 10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(233, 233, 233, 0.9),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text('生活电器')
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(right: 10,top: 10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(233, 233, 233, 0.9),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text('男装')
                  )
                ],
              )
            ],
          ),
        ),
        //搜索历史
        _historyWidget(),
        //按钮
        Container(
          height: textFieldHeight*2,
          margin: EdgeInsets.only(left: 10,right: 10),
          child: OutlineButton(
            highlightedBorderColor: Colors.red,  //设置点击后边框颜色
            onPressed: (){
              SearchServices.clearHistoryList();   //清空历史记录
              this._getHistoryList();
              setState(() {
                this._searchList = [];   //更新数据
              });
            }, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.delete),
                Text('清空历史')
              ],
            ),
          )
        )
      ],
    );
  }

  //搜索提示列表
  Widget _hintWidget(){
    return ListView.builder(
      itemCount: this._hintsList.length,
      itemBuilder: (context,index){
        return InkWell(
          child: ListTile(
            title: Text('${this._hintsList[index].hints}'),
          ),
          onTap: (){   //监听，点击所选item赋值给输入框controller.text，并赋值给keyword才能搜索其对应的词条
            setState(() {
              _textController.text = this._hintsList[index].hints;
              this._editText = this._hintsList[index].hints;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),  //修改appBar中leading中icon的颜色
        title: Container(
          height: textFieldHeight * 2,
          decoration: BoxDecoration(
            color: Color.fromRGBO(233, 233, 233, 0.8),
            borderRadius: BorderRadius.circular(textFieldHeight)
          ),
          child: TextField(
            controller: _textController,
            autofocus: false,
            decoration: InputDecoration(
              hintText: '笔记本',
              contentPadding: EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(textFieldHeight),
                borderSide: BorderSide.none
              )
            ),
            onChanged: (value){
              this._editText = value;
              this._getHintsList(value);   //搜索提示
            },
          ),
        ),
        actions: <Widget>[
          InkWell(
            child: Container(
              padding: EdgeInsets.all(10),
              height: textFieldHeight * 3, //设置与appBar一样高
              alignment: Alignment.center,
              child: Text('搜索',style: TextStyle(color: Colors.black),),
            ),
            onTap: (){
              //保存历史记录
              SearchServices.setHistoryData(this._editText);
               //因为查询与分类使用的是同一接口，在页面传值时其中一个应为空，所以需传两个键值对，其中一个为''，不然会出现传'null'字符串，不符接口传值要求
              Navigator.pushReplacementNamed(context, '/commodityList',arguments: {'detail':this._editText,'categoryId':''}); 
            },
          )
        ],
      ),
      body: this._hintsList.length > 0 ? _hintWidget() : searchBody(),
    );
    
  }
}

