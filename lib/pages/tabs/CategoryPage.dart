import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/Config.dart';
import '../../model/CategoryModel.dart';
import '../../model/SubCategoryModel.dart';


/**
 * Text('屏幕高度：${this.sHeight}，屏幕宽度${this.sWidth}，像素密度${pixel},scaleWidth${this.scaleWidth},scaleHeight${this.scaleHeight}'),
   每英寸长度上像素点个数。例如，每英寸内有160个像素点，则其像素密度为160dpi。
   公式： 像素密度=像素/尺寸 （dpi=px/in）
   像素 = dp * 像素密度等级，即 px = dp * (dpi / 160) 
   像素密度等级
   手机真实像素密度与标准屏幕像素密度（160dpi）的比值。
   官方给出的0.75、1、1.5、2、3、4，即对应120dpi、160dpi、240dpi、320dpi、480dpi、640dpi。

   组件宽度依据屏幕宽度减去对应的边距后进行平分，而对于组件的高度则依据宽高比，获取宽度加上container中包含的其他组件的高度
   若按照屏幕高度进行比例分配需要减去appBar一级底部导航栏的高度
 */

class CategoryPage extends StatefulWidget{
  CategoryPage({Key ? key}) : super(key : key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> with AutomaticKeepAliveClientMixin{

  //保持页面状态
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  // 当前设备宽度 dp
  var sWidth = ScreenUtil().screenWidth;  //360.0dp ->1080px
  var sHeight = ScreenUtil().screenHeight; //640.0dp ->1920px
  var pixel = ScreenUtil().pixelRatio; // = （开方（宽分辨率平方 + 高分辨率平方））➗ 屏幕英寸大小
  var scaleWidth = ScreenUtil().scaleWidth;
  var scaleHeight = ScreenUtil().scaleHeight;
  
  
  //比例分配组件宽度
  var _fourPiecesWth = ScreenUtil().screenWidth/4;
  var _tenPiecesHeight = ScreenUtil().screenHeight/12;
  var _secondaryCate = (ScreenUtil().screenWidth - ScreenUtil().screenWidth/4 - 40)/3; //40dp代表边距,gridview项的宽度
  var _secondaryCateHe = (ScreenUtil().screenWidth - ScreenUtil().screenWidth/4 - 40)/3 + 20; //gridview项的高度

  //选中标记
  var _selectedIndex = 0; 

  //分类数据数组
  List<CategoryItemModel> _categoryList = [];
  List<SubCategoryItemModel> _subCateList = [];

  //获取api数据
  _getCategory() async{
    var api = '${Config.domain}category/getAllCategory';
    var result = await Dio().request(api);
    var categoryList = CategoryModel.fromJson(result.data);  //取出的是CategoryModel
    setState(() {
      this._categoryList = categoryList.result!; //取出的是CategoryModel中result键对应的list数据
    });
    
    //默认选中第一条，则显示第一条对应的二级分类
    _getSubCate(this._categoryList[0].id);

  }

  _getSubCate(parentId) async{
    var api = '${Config.domain}subCate/getSubByParentId?parentId=${parentId}';
    var result = await Dio().get(api);
    var subCateList = SubCategoryModel.fromJson(result.data);
    setState(() {
      this._subCateList = subCateList.result!;
    });
  }

  //初始化
  @override
  void initState() {
    super.initState();
    //获取数据
    _getCategory();
  }

  //左边一级分类
  Widget _leftCateWidget(){
    if(this._categoryList.length > 0){
      return Container(
        height: double.infinity,
        width: this._fourPiecesWth,
        child: ListView.builder(
          itemCount: this._categoryList.length,
          itemBuilder: (BuildContext context,int index){
            return InkWell(
              onTap: (){
                setState(() {
                  this._selectedIndex = index;
                  _getSubCate(this._categoryList[index].id);
                });
              },
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,  //让container中的组件居中
                    height: this._tenPiecesHeight,
                    decoration: BoxDecoration(
                      color: this._selectedIndex == index ? Color.fromRGBO(240, 246, 246, 0.9) : Colors.white
                    ),
                    child: Text(
                      '${this._categoryList[index].title}',
                      style: TextStyle(
                        color: this._selectedIndex == index ? Colors.red : Colors.black
                      ),
                    ),
                  ),
                  Divider(height: 1,)
                ],
              ),
            );
          }
        ),
      );
    }else{
      return Container(
        height: double.infinity,
        width: this._fourPiecesWth,
        child: Text('')
      );
    }
  }

  //右边二级分类
  Widget _rightSubCateWidget(){
    if(this._subCateList.length > 0){
      return Expanded(     //自适应组件，一般用于占据剩余空间的情况
        flex: 1,
        child: Container(
          padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color.fromRGBO(240, 246, 246, 0.9)
          ),
          child: GridView.builder(
            itemCount: this._subCateList.length,  //适配数据后记得修改数组长度
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              childAspectRatio: _secondaryCate/_secondaryCateHe  //宽高比计算
            ), 
            itemBuilder: (BuildContext context,int index){
              return InkWell(
                onTap: (){
                  Navigator.pushNamed(context, '/commodityList',arguments: {"categoryId":this._subCateList[index].id,'detail':''});
                },
                child: Container(
                  child: Column(
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: 1/1,
                        child: Image.network('${Config.domain}${(this._subCateList[index].shrinkPic!).replaceAll('\\', '/')}'),
                      ),
                      Container(
                        height: 20,
                        child: Text('${this._subCateList[index].subTitle}',style: TextStyle(fontSize: 26.sp),),
                      )
                    ],
                  ),
                ),
              );
            }
          )
        )
      );
    }else{
      return Expanded(     //自适应组件，一般用于占据剩余空间的情况
        flex: 1,
        child: Container(
          padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color.fromRGBO(240, 246, 246, 0.9)
          ),
          child: Text(''),
        )
      );
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        //左边一级分类
        _leftCateWidget(),

        //右边二级分类
        _rightSubCateWidget()
      ],
    );
  }

}