import 'package:flutter/material.dart';
import 'package:flutter_jd/pages/tabs/CategoryPage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../pages/tabs/HomePage.dart';

class Tabs extends StatefulWidget{
  Tabs({Key ? key}) : super(key : key);

  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs>{

  //保持页面状态 tab切换页PageController、PageView、需要保持状态页with AutomaticKeepAliveClientMixin
  //wantKeepAlive=>true
  var _pageController;  //页面控制器

  //屏幕适配，设置搜索框的高度
  var _searchHeight = AppBar().preferredSize.height/3;

  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    //初始化页面控制器
    _pageController = new PageController(initialPage: _currentIndex);
  }

  List<Widget> _pageList = [
    HomePage(),
    CategoryPage(),
    Text('carshop'),
    Text('person'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(       //可通过PreferredSize组件修改appBar的高度
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.center_focus_weak,size:24,color:Colors.black),
          onPressed: (){},
        ),
        title: InkWell(
          child: Container(
            padding: EdgeInsets.only(left: 10),
            height: _searchHeight * 2,
            decoration: BoxDecoration(
              color: Color.fromRGBO(233, 233, 233, 0.8),
              borderRadius: BorderRadius.circular(_searchHeight)
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.search,size: 20,color: Colors.black,),
                Text('笔记本',style: TextStyle(color: Colors.black,fontSize: 30.sp),)
              ],
            ),
          ),
          onTap: (){
            Navigator.pushNamed(context, '/searchPage');
          },
        ),
        actions: <Widget>[
          IconButton(
            onPressed: (){}, 
            icon: Icon(Icons.message,size:20,color: Colors.black,)
          )
        ],
      ),
      //保持页面状态，使用pageView加载页面
      body: PageView(
        controller: _pageController,
        children: _pageList,
        physics: NeverScrollableScrollPhysics(),  //禁止滑动tabs
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,   //允许多个
        fixedColor: Colors.red,
        currentIndex: _currentIndex,
        onTap: (index){
          setState(() {
            this._currentIndex = index; //需要改变当前页面的下标，否则无法fixedColor
            //使用页面控制器进行跳转
            _pageController.jumpToPage(index);
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: '分类'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '购物车'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的'
          ),
        ],
      ),
    );
  }
}