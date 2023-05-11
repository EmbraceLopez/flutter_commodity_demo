import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../model/CommodityModel.dart';
import '../../widget/LoadingWidget.dart';
//轮播图模型类
import '../../model/SwiperModel.dart';
import '../../config/Config.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin{

  //保持状态
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  //轮播图list
  List<SwiperItemModel> _swiperList = [];
  //猜你喜欢list
  List<CommodityItemModel> _hotCommodityList = [];
  //热门推荐
  List<CommodityItemModel> _bestCommodityList = [];

  //屏幕适配，像素密度dpi=(px/in)，标准像素密度mdpi(160)
  var _screenWidth = ScreenUtil().screenWidth; //获取屏幕宽度dp = 分辨率/像素密度等级
  var _screenHeight = ScreenUtil().screenHeight;
  var doubleWidth;
  var tripletWidth;
  var fourPiecesWidth;
  var fivePiecesHeight;

  //上拉加载更多
  ScrollController _scrollController = ScrollController();  //listView控制器，可用于判断上滑距离

  List<CommodityItemModel> _commoList = [];

  int _pageIndex = 1;
  var _flag = true;

  @override
  void initState(){  //首次打开时执行
    super.initState();
    
    //减去边距后，将屏幕水平平分为2份        //减去固定值后，需要此减数依据分配间距（内边距、外边距、spacing、runSpacing等）
    doubleWidth = (_screenWidth - 40)/2;  //边距尽量设置大些，更好适配屏幕较宽的手机，否则可能出现组件宽度过大，导致溢出屏幕或者换行
    //减去边距后，将屏幕水平平分为3份
    tripletWidth = (_screenWidth - 40)/3;
    //减去边距后，将屏幕水平平分为4份
    fourPiecesWidth = (_screenWidth - 50)/4;
    fivePiecesHeight = _screenHeight / 5;

    //取出轮播图数据
    _getSwiperData();
    //猜你喜欢
    _getHotCommodity();

    //获取推荐商品数据
    _getRecommendList();

    //下滑翻页
    _scrollController.addListener(() { 
      //_scrollController.position.pixels  获取滚动条滚动高度
      //_scrollController.position.maxScrollExtent 获取页面高度
      if(_scrollController.position.pixels > (_scrollController.position.maxScrollExtent - 20)){
        //重新加载，设置flag是为了防止多次滑动，重复加载的情况，滑动一次加载一次，无数据后滑动不加载
        if(_flag){
          _getRecommendList();
        }
      }
    });

  }

  //从api中获取轮播图数据
  _getSwiperData() async{
    var api = '${Config.domain}swiper/getAllSwiper';
    var result = await Dio().request(api); //从api中取出数据
    var swiperList = SwiperModel.fromjson(result.data);  //取出SwiperModel对象，result.data为map集合
    //print(swiperList.result);  //取出SwiperModel对象中的json数组，此数组中保存的是result对象
    setState(() {
      this._swiperList = swiperList.result!;
    });
  }

  //从api中获取商品数据(猜你喜欢)
  _getHotCommodity() async{
    var api = '${Config.domain}recommend?pageIndex=1&pageSize=6';
    var result = await Dio().get(api);  //从api中取出数据
    var hotCommodityList = CommodityModel.fromJson(result.data);
    setState(() {
      this._hotCommodityList = hotCommodityList.result!;
    });
  }

  //从api中获取推荐商品数据
  _getRecommendList() async{
     setState(() {
       this._flag = false;  //查询时防止反复滑动时多次调用该接口获取该页数据
     });
    var api = '${Config.domain}/recommend?pageIndex=${this._pageIndex}&pageSize=4';
    //print(api);
    var result = await Dio().get(api);
    var commoList = CommodityModel.fromJson(result.data);
    if(commoList.result!.length > 0){
      setState(() {
        this._commoList.addAll(commoList.result!);  //分页加载需要使用addAll()
        this._pageIndex++;
        //查询完后打开，可继续加载下一页数据
        this._flag = true;
      });
    }
  }

  //轮播图
  Widget _swiperWidget(){
    if(this._swiperList.length > 0){
      return Container(
        child: AspectRatio(
          aspectRatio: 2/1,
          child: Swiper(
            itemCount: this._swiperList.length,
            itemBuilder: (BuildContext context,int index){
              return Image.network('${Config.domain}${(this._swiperList[index].pic!).replaceAll('\\', '/')}',fit: BoxFit.cover,);
            },
            pagination: SwiperPagination(),
            autoplay: true,
            loop: true,
          ),
        ),
      );
    }else{
      return Text('');
    }
  }

  Widget _titleWidget(title){
    return Container(
      child: Text(title,style: TextStyle(
        color: Colors.black54
        ),
      ),
      height: 32.h,
      margin: EdgeInsets.only(left: 20.w),
      padding: EdgeInsets.only(left: 20.w),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(
          color: Colors.red,
          width: 4.w
        ))
      ),
    );
  }

  //猜你喜欢 横向ListView（ListView中不能嵌套ListView，但可通过container实现）
  Widget _likeProductListWidget(){
    if(this._hotCommodityList.length > 0){
      return Container(
        margin: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
        height: fourPiecesWidth + 25,  //25是dp
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: this._hotCommodityList.length,
          itemBuilder: (BuildContext context,index){
            return Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 15.w),
                  height: fourPiecesWidth,
                  width: fourPiecesWidth,
                  child: Image.network('https:${this._hotCommodityList[index].img}'),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5.h),
                  height: 30.h,
                  child: Text(
                    '￥${this._hotCommodityList[index].price}',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 23.sp
                    ),
                  ),
                )
              ],
            );
          }
        ),
      );
    }else{
      return Text('');
    }
  }

  //商品推荐

  List<Widget> _recommend(){
    List<Widget> widgetList = [];
    if(this._commoList.length > 0){
      int index = 0;  //设置第一个商品高度低于其余商品高度
      widgetList =  this._commoList.map((value){
        return StaggeredGridTile.count(
          crossAxisCellCount: 8,
          mainAxisCellCount: index++ == 0 ? 11 : 12,
          child: Container(
            //width: doubleWidth,               //依据适配屏幕设定的宽度(无效)
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromRGBO(233, 233, 233, 0.9),
                width: 2
              )
            ),
            child: Column(
              children: <Widget>[
                Container(
                  child: AspectRatio(
                    aspectRatio: 1/1,
                    child: Image.network('https:${value.img}',fit: BoxFit.cover,),
                  )
                ),
                Container(
                  child: Text(
                    '${value.name}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 26.sp,
                    ),
                  ),
                ),
                Container(
                  child: Stack(         //可指定组件在容器中的位置(上下左右组合)
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '￥${value.price}',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 30.sp,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '￥${value.price}',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 26.sp,
                            decoration: TextDecoration.lineThrough  //划线
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        );
      }).toList();
    } else{
      widgetList.add(LoadingWidget());
    }
    return widgetList;
  }

  Widget _recommendWidget(){
    return Container(
        margin: EdgeInsets.only(top: 5,left: 10,right: 10),
        child: StaggeredGrid.count(
          crossAxisCount: 16,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          children: this._recommend()
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      children: <Widget>[
        _swiperWidget(),
        SizedBox(height: 12.w,),
        _titleWidget('猜你喜欢'),
        _likeProductListWidget(),
        _titleWidget('热门推荐'),
        //商品推荐
        _recommendWidget()
      ],
    );
  }
}


/**
   * Wrap(
        alignment: WrapAlignment.spaceEvenly,  //减去spacing后平均分配间距(包括与屏幕之间的间距)
        spacing: 10.w,
        runSpacing: 10.w,
        children: this._bestCommodityList.map((value){
          return _hotProductListWidget(value);
        }).toList()
      ),
   */
  // Widget _hotProductWidget(){
  //   return Container(
  //     margin: EdgeInsets.all(10.w),   //设定外边距时要确定其是容器还是子级组件，一般是为父级容器设置
  //     child: GridView.builder(
  //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisCount: 2
  //       ),
  //       itemCount: this._bestCommodityList.length,
  //       itemBuilder: _hotProductListWidget
  //     )
  //   );
  // }