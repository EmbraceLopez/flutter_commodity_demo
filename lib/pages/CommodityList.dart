import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/Config.dart';
import '../model/CommodityModel.dart';
import '../widget/LoadingWidget.dart';


/**
 * 注意column在不确定其高度时，可将其放入Container容器中
 * 对于条件筛选居于列表的顶部时，可使用Stack组件，将条件筛选放在列表的下一个组件，既不会被覆盖
 */
class CommodityList extends StatefulWidget{

  Map arguments;
  CommodityList({Key ? key,required this.arguments}) : super(key : key);

  @override
  State<CommodityList> createState() => _CommodityListState();
}

class _CommodityListState extends State<CommodityList>{

  //屏幕适配,设置商品图片的宽为屏幕宽度的1/3
  var commPicWidth = ((ScreenUtil().screenWidth-20)/3);
  //条件筛选组件宽度
  var selectWidth = ScreenUtil().screenWidth;
  //条件筛选组件高度，可选40dp，对于宽屏手机，其宽度的九分之一近50dp，也可选十分之一
  var selectHeight = ScreenUtil().screenWidth/10;
  

  //实现点击其他组件打开侧滑栏
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //上拉加载更多
  ScrollController _scrollController = ScrollController();  //listView控制器，可用于判断上滑距离
  var _page = 1;  //默认开始页码 第一页
  var _pageSize = 4; //每页5条数据
  
  //标记（防止加载下一页时加载两次，即访问两次相同接口，正在加载时关闭接口的访问）
  bool _flag = true;
  //标记（判断是继续加载还是已无数据）
  bool _moreFlag = true;
  //价格升序/降序
  var priceSortParams = '';
  int sort = 1;
  //销量升序/降序
  var salesSortParams = '';
  int salesSort = 1;
  
  List<CommodityItemModel> _commoList = [];

  //二级筛选栏
  List _subFiltrate = [
    {
      'id' : 1,
      'title' : '综合'
    },
    {'id' : 2,'title' : '销量'},{'id' : 3,'title' : '价格'},{'id' : 4,'title' : '筛选'},
  ];
  var _subFiltrateIndex;

  @override
  void initState() {
    super.initState();
    //点击分类后第一次加载商品列表
    _getCommoListByCategoryId();
    //监听滚动条滚动事件，浏览完第一次加载的数据后上滑加载更多
    _scrollController.addListener(() { 
      //_scrollController.position.pixels  获取滚动条滚动高度
      //_scrollController.position.maxScrollExtent 获取页面高度
      if(_scrollController.position.pixels > (_scrollController.position.maxScrollExtent - 20)){
        //重新加载，设置flag是为了防止多次滑动，重复加载的情况，滑动一次加载一次，无数据后滑动不加载
        if(this._flag && this._moreFlag){
          _getCommoListByCategoryId();
        }
      }
    });
  }

  //从api中获取数据
  _getCommoListByCategoryId() async{
    //加载时关闭重复滑动加载
    setState(() {
      _flag = false;
    });
    var api = '${Config.domain}searchCommodityByKeyOrCate?pageIndex=${this._page}&pageSize=${this._pageSize}&categoryId=${widget.arguments["categoryId"]}&keyword=${widget.arguments['detail']}&priceSortParams=${this.priceSortParams}&salesSortParams=${this.salesSortParams}';
    print(api);
    var result = await Dio().get(api);
    var commoList = CommodityModel.fromJson(result.data);

    //如果查出还有数据，则继续下一页
    if(commoList.result!.length > 0){
      //还有数据
      setState(() {
        //this._commoList = commoList.result!;
        //对于分页查询，不能使用赋值，而应将之后所查的数组追加至原数组
        this._commoList.addAll(commoList.result!);
        this._flag = true;
        //查询完一页后继续下一页
        this._page++;
      });
    }else{
      setState(() {
        this._flag = false;
        this._moreFlag = false;
      });
    }

  }

  //筛选商品（价格、销量）
  _getCommodityListByFiltrate(){

    reload(){
      //重新加载数据
      //重置分页
      this._page = 1;
      //重置数据
      this._commoList = [];
      //回到顶部
      this._scrollController.jumpTo(0);
      //因为会出现需要多次查询的情况，若不打开则会出现点击第二次时只能查询一次，72行if(this._flag && this._moreFlag){}
      this._moreFlag = true;
      //重新请求
      _getCommoListByCategoryId();
    }

    //清空销量、价格api，实现综合查询
    reClear(){
      priceSortParams = '';
      salesSortParams = '';
    }

    switch(this._subFiltrateIndex){
      case 1:
        //点击综合应清空原来筛选的值，改变api即可，然后重新加载
        reClear();
        //重新加载
        reload();
        break;
      case 2:
        //销量
        this.salesSort = this.salesSort * -1;  //判断升序降序
        salesSortParams = '${this.salesSort}'; //改变api，进行销量升序降序查询
        priceSortParams = '';
        reload();
        break;
      case 3:
        //价格升序降序
        this.sort = this.sort * -1;  
        priceSortParams = '${this.sort}';
        salesSortParams = '';
        reload();
        break;
      case 4:
        _scaffoldKey.currentState!.openEndDrawer();
        break;
      default:
        reClear();
    }
  }

  //上滑加载（还有数据）还是结束（已无更多数据）
  Widget _hasMore(index){
    if(_moreFlag){
      //防止出现商品总数小于一页的总数的情况
      if((index + 1) >= this._pageSize){
        return (this._commoList.length - 1 == index) ? LoadingWidget() : SizedBox(height: 0.0,);
      }else{
        return (this._commoList.length - 1 == index) ? Text('到底了！') :  SizedBox(height: 0.0,);
      }
    }else{
      return (this._commoList.length - 1 == index) ? Text('到底了！') :  SizedBox(height: 0.0,);
    }
  }

  //销量价格升序降序icon，在绘制二级筛选栏时应判断是否加icon（价格加、销量加），所以应该是判断筛选栏中各项中id的值，而不是选中后改变的值this._subFiltrateIndex，其他情况应返回无大小的组件
  //在点击选中时需要改变icon的颜色，应在点击选中后改变，并判断是降序还是升序，所以加上选中后改变颜色
  Widget _showIcon(id){
    if(id == 2 ){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.arrow_drop_up,size: selectHeight/3, color: (this.salesSort == 1 && this._subFiltrateIndex == 2) ? Colors.red : Colors.black,),
            Icon(Icons.arrow_drop_down,size: selectHeight/3, color: (this.salesSort == -1 && this._subFiltrateIndex == 2) ? Colors.red : Colors.black)
          ],
      );
    }
    else if(id == 3){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.arrow_drop_up,size: selectHeight/3, color: (this.sort == 1 && this._subFiltrateIndex == 3) ? Colors.red : Colors.black,),
            Icon(Icons.arrow_drop_down,size: selectHeight/3, color: (this.sort == -1 && this._subFiltrateIndex == 3) ? Colors.red : Colors.black)
          ],
      );
    }
    return SizedBox(height: 0.0,);
  }

  Widget _commodityListWidget(){
    if(this._commoList.length > 0){
      return Padding(
        padding: EdgeInsets.only(left: 10,right: 10,top: selectHeight),  //确定最外层组件，再分析列表项布局
        child: ListView.builder(
          controller: _scrollController,
          itemCount: this._commoList.length,  //记得修改列表长度
          itemBuilder: (context,index){
            return Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: commPicWidth,
                      padding: EdgeInsets.only(top:10,bottom: 10),
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.all(Radius.circular(100))  //设置圆角
                      // ),
                      child: AspectRatio(
                        aspectRatio: 1/1,
                        child: Image.network('https:${this._commoList[index].img}',fit: BoxFit.cover,),  //!.substring(2,this._commoList[index].img!.length)}
                      )
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: commPicWidth,
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,  //主轴元素两边分别对齐，中间间距一致
                          children: <Widget>[
                            Text(
                              '${this._commoList[index].name}',
                              style: TextStyle(
                                fontSize: 30.sp
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text('￥${this._commoList[index].price}',style: TextStyle(color: Colors.red,fontSize: 34.sp,fontWeight: FontWeight.bold),),
                            Text('销量：${this._commoList[index].salesVolume}',style: TextStyle(color: Colors.black54,fontSize: 26.sp))
                          ],
                        ),
                      )
                    )
                  ],
                ),
                Divider(height: 1,),
                _hasMore(index)
              ],
            );
          }
        ),
      );
    }else{
      return LoadingWidget();
    }
  }

  //筛选组件
  Widget _selectHeaderWidget(){
    return Positioned(  //一般与stack组件配合使用，可确定其在stack中的位置（上下左右）
      top: 0,
      width: selectWidth,
      height: selectHeight,
      child: Container(
        child: Row(
          children: this._subFiltrate.map((value){
            return  Expanded(   //在row中的Expanded组件同时设置多个，并不固定其宽度则类似于andorid布局中的权重属性weight
              flex: 1,
              child: InkWell(
                child: Container(
                  height: selectHeight,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${value['title']}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: (this._subFiltrateIndex == value['id']) ? Colors.red : Colors.black
                        )
                      ),
                      _showIcon(value['id'])
                    ],
                  )
                ),
                onTap: (){
                  setState(() {
                    this._subFiltrateIndex = value['id'];
                    (this._commoList.length > 0) ? _getCommodityListByFiltrate() : null;  //若搜索查不到商品，获取分类中无商品则禁用二级筛选栏的点击事件
                  });
                },
              )
            );
          }).toList()   //转为list
        )
      )
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('商品列表',style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back)),  
        actions: <Widget>[
          Text('')  //取消右边菜单栏按钮
        ],
      ),
      endDrawer: Drawer(
        child: Container(
          child: Text('右边侧滑栏'),
        )
      ),
      body: Stack(  //堆叠组件（类似FrameLayout），后添加的组件会覆盖前添加的组件，可与Positioned组件配合使用，来摆放其中组件的位置
        children: <Widget>[
          _commodityListWidget(),
          _selectHeaderWidget()
        ],
      )
    );
  }
}