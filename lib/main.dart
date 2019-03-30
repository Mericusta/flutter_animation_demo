import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

void main() {
  debugPaintSizeEnabled = false;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: CustomPaintDemo(title: 'Flutter Demo Home Page'),
      home: new ClipRectDemo(),
      // home: new StackAnimationDemo(),
      // home: new TabBarDemo(),
    );
  }
}

class TabBarDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _TabBarState();
}

class _TabBarState extends State<TabBarDemo> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => new Scaffold(
    appBar: new AppBar(),
    body: new Center(
      child: new TabBar(
        controller: new TabController(
          length: 2,
          vsync: this,
        ),
        tabs: <Widget>[
          new Tab(
            text: 'tab 1',
          ),
          new Tab(
            text: 'tab 2',
          ),
        ],
      ),
    ),
  );
}

class StackAnimationDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _StackAnimationState();
}

class _StackAnimationState extends State<StackAnimationDemo> {
  bool animating;
  double animationX;
  double animationY;
  ScrollController scrollController;
  // List<Key> keyList;
  // List<Widget> widgetList;
  
  @override
  void initState() {
    super.initState();
    animating = false;
    animationX = 0;
    animationY = 0;
    scrollController = new ScrollController();
    // scrollController.addListener(() {
    //   scrollController.
    // });
    // keyList = new List<Key>();
    // widgetList = new List<Widget>();
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
    appBar: new AppBar(
      title: new Text('Stack Animation Demo'),
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.ac_unit),
          onPressed: () => setState(() => animating = !animating),
        )
      ],
    ),
    body: new SingleChildScrollView(
      controller: scrollController,
      child: new Stack(
        children: <Widget>[
          new Column(
            children: () {
              List<Key> keyList = new List<Key>();
              List<Widget> widgetList = new List<Widget>();
              for (int index = 0; index != 4; ++index) {
                keyList.add(new GlobalKey());
                widgetList.add(new Container(
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                    color: Colors.blueAccent,
                    border: new Border.all(color: Colors.red),
                  ),
                  child: new GestureDetector(
                    key: keyList[index],
                    onTap: () {
                      RenderBox renderBox = (keyList[index] as GlobalKey).currentContext.findRenderObject();
                      Offset offset = renderBox.localToGlobal(Offset.zero);
                      Size size = renderBox.size;
                      print('TEST: offset.x = ${offset.dx}, offset.y = ${offset.dy}');
                      print('TEST: size.width = ${size.width}, size.height = ${size.height}');
                      setState(() {
                        animating = true;
                        animationX = offset.dx;
                        animationY = offset.dy + scrollController.offset;
                      });
                    },
                    child: new Text(index.toString()),
                  ),
                ));
              }
              return widgetList;
            }(),
          ),
          new Positioned(
            left: animationX,
            top: animationY - 80 + 100,
            child: animating ? new Container(
              width: 40,
              height: 40,
              color: Colors.red,
            ) : new Container(),
          ),
        ],
      ),
    ),
  );
}

class _StarCliper extends CustomClipper<Path>{
  final double radius;

  _StarCliper({this.radius});

  /// 角度转弧度公式
  double degree2Radian(int degree) {
    return (Math.pi * degree / 180);
  }

  @override
  Path getClip(Size size) {
    double radius = this.radius;
    Path path = new Path();
    double radian = degree2Radian(36);// 36为五角星的角度
    double radius_in = (radius * Math.sin(radian / 2) / Math.cos(radian)); // 中间五边形的半径

    path.moveTo((radius * Math.cos(radian / 2)), 0.0);// 此点为多边形的起点
    path.lineTo((radius * Math.cos(radian / 2) + radius_in * Math.sin(radian)), (radius - radius * Math.sin(radian / 2)));
    path.lineTo((radius * Math.cos(radian / 2) * 2), (radius - radius * Math.sin(radian / 2)));
    path.lineTo((radius * Math.cos(radian / 2) + radius_in * Math.cos(radian / 2)), (radius + radius_in * Math.sin(radian / 2)));
    path.lineTo((radius * Math.cos(radian / 2) + radius * Math.sin(radian)), (radius + radius * Math.cos(radian)));
    path.lineTo((radius * Math.cos(radian / 2)), (radius + radius_in));
    path.lineTo((radius * Math.cos(radian / 2) - radius * Math.sin(radian)), (radius + radius * Math.cos(radian)));
    path.lineTo((radius * Math.cos(radian / 2) - radius_in * Math.cos(radian / 2)), (radius + radius_in * Math.sin(radian / 2)));
    path.lineTo(0.0, (radius - radius * Math.sin(radian / 2)));
    path.lineTo((radius * Math.cos(radian / 2) - radius_in * Math.sin(radian)), (radius - radius * Math.sin(radian / 2)));

    path.close();// 使这些点构成封闭的多边形

    return path;
  }

  @override
  bool shouldReclip(_StarCliper oldClipper) {
    return this.radius != oldClipper.radius;
  }
}

class _CurvedRectangle extends CustomClipper<Path> {
  _CurvedRectangle({
    // NOTE: move offset dh
    // NOTE: 0 <= bezierOffset <= maxOffset
    this.bezierOffset = 0,
    this.maxOffset = 50.0,
  });
  
  final double bezierOffset;
  final double maxOffset;

  @override
  Path getClip(Size size) {
    Path path = new Path();
    
    // NOTE: 左下角
    path.moveTo(0, size.height);

    // NOTE: 右下角
    path.lineTo(size.width, size.height);

    // NOTE: 右上角
    double topRightX = size.width;
    double topRightY = size.height - maxOffset / 2;
    path.lineTo(topRightX, topRightY < 0 ? 0 : topRightY);

    // NOTE: 左上角
    double topLeftX = 0;
    double topLeftY = size.height - maxOffset / 2;

    // NOTE: 二阶贝兹曲线
    path.quadraticBezierTo(
      size.width / 2, size.height - bezierOffset + maxOffset / 2,
      topLeftX, topLeftY < 0 ? 0 : topLeftY,
    );

    // NOTE: 闭合
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(_CurvedRectangle oldClipper) {
    return this.bezierOffset != oldClipper.bezierOffset;
  }
}

class ClipRectDemo extends StatefulWidget {
  ClipRectDemo({
    this.maxClipRectOffset = 50.0,
    this.offsetChangingRate = 2.0,
  });

  final double maxClipRectOffset;
  final double offsetChangingRate;
  
  @override
  State<StatefulWidget> createState() => new _ClipRectDemoState();
}

class _ClipRectDemoState extends State<ClipRectDemo> with SingleTickerProviderStateMixin {
  double offset;
  ScrollController scrollController;
  
  @override
  void initState() {
    super.initState();
    offset = 0.0;
    scrollController = new ScrollController();
    scrollController.addListener(() {
      if (scrollController.offset <= widget.maxClipRectOffset * widget.offsetChangingRate) {
        setState(() => offset = scrollController.offset / widget.offsetChangingRate);
      }
    });
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
    appBar: new AppBar(
      actions: <Widget>[
        new IconButton(
          onPressed: () => setState(() => scrollController.jumpTo(0)),
          icon: new Icon(
            Icons.refresh
          ),
        ),
      ],
    ),
    body: new Stack(
      children: <Widget>[
        // new Image.asset('assets/background.png'),
        new Container(
          width: MediaQuery.of(context).size.width,
          height: 200,
          color: Colors.yellow,
        ),
        new SingleChildScrollView(
          controller: scrollController,
          child: new Column(
            children: () {
              List<Widget> list = new List<Widget>();
              list.add(new Stack(
                children: <Widget>[
                  new Container(
                    color: Colors.transparent,
                    child: new ClipPath(
                    clipper: new _CurvedRectangle(
                      bezierOffset: offset,
                      maxOffset: widget.maxClipRectOffset,
                    ),
                    child: new Container(
                      color: Colors.blue,
                      width: MediaQuery.of(context).size.width,
                      height: 200.0,
                    ),
                  )),
                  new Container(
                    alignment: Alignment.bottomCenter,
                    width: MediaQuery.of(context).size.width,
                    height: 200.0 - offset,
                    child: new Text('Topic Title'),
                  ),
                ],
              ));
              for (int index = 0; index != 20; ++index) {
                list.add(new Container(
                  color: Colors.blue,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 4,
                ));
              }
              return list;
            }(),
          ),
        )
      ],
    ),
  );
}

class CustomPainterDemo extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
    ..color = Colors.blue
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true
    ..strokeWidth = 5.0
    ..style = PaintingStyle.stroke;

    int ratio = 4;
    // double heightOffset = 0;
    double heightOffset = size.height * (1 - 1 / ratio / 2);

    Rect rect = Rect.fromLTWH(0, heightOffset, size.width, size.height/ratio);
    // canvas.drawArc(rect, 0, Math.pi, true, paint);

    // NOTE: 绘制凸弧边矩形放置图片

    // NOTE: 绘制一个弧边遮挡图片

    // NOTE: 路径裁剪
    Path path = new Path();

    // NOTE: 弧形路径
    path.arcTo(rect, 0, Math.pi, false);
    canvas.drawPath(path, paint);
    
    // NOTE: 三阶贝兹曲线
    var width = size.width;
    var height = size.height;
    int bezierWidthRatio = 10;
    int bezierHeightRatio = 1;
    double x1 = width / bezierWidthRatio;
    double y1 = height / bezierHeightRatio;
    double x2 = width * (1 - 1/bezierWidthRatio);
    double y2 = height / bezierHeightRatio;
    double x3 = width;
    double y3 = 0;
    path.moveTo(0, 0);
    path.cubicTo(
      x1, y1, 
      x2, y2,
      x3, y3,
    );
    canvas.drawPath(path, paint);

    // Path path2 = new Path();
    // path2.moveTo(width / 2, height / 4);
    // path2.cubicTo(width / 7, height / 9, width / 21, (height * 2) / 5,
    //     width / 2, (height * 7) / 12);
    // canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CustomPaintDemo extends StatefulWidget {
  CustomPaintDemo({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CustomPaintDemoState createState() => _CustomPaintDemoState();
}

class _CustomPaintDemoState extends State<CustomPaintDemo> {
  final double imageAspectRatio = 1317 / 674;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: new Stack(
        children: <Widget>[
          new Image.asset('assets/background.png'),
          new CustomPaint(
            painter: new CustomPainterDemo(),
            size: new Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.width / 1317 * 674,
            ),
          ),
        ],
      ),
    );
  }
}
