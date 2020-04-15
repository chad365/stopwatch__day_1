import 'dart:math' as math;
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:analog_clock/analog_clock.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

int c = 0;
int anime_timer = 60;
AudioPlayer advancedPlayer = new AudioPlayer();
String note = "";
AudioCache audioCache = new AudioCache(fixedPlayer: advancedPlayer);

void main() {
  runApp(new MaterialApp(
    theme: new ThemeData(
      canvasColor: Colors.white,
      iconTheme: new IconThemeData(color: Colors.deepPurple),
      accentColor: Colors.pinkAccent,
      brightness: Brightness.dark,
    ),
    home: new MyHomePage(),
  ));
}

class ProgressPainter extends CustomPainter {
  ProgressPainter({
    @required this.animation,
    @required this.backgroundColor,
    @required this.color,
  }) : super(repaint: animation);

  /// Animation representing what we are painting
  final Animation<double> animation;

  /// The color in the background of the circle
  final Color backgroundColor;

  /// The foreground color used to indicate progress
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progressRadians = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(
        Offset.zero & size, math.pi * 1.5, -progressRadians, false, paint);
  }

  @override
  bool shouldRepaint(ProgressPainter other) {
    return animation.value != other.animation.value ||
        color != other.color ||
        backgroundColor != other.backgroundColor;
  }
}

class MyHomePage extends StatefulWidget {
  _MyHomePageState createState() => new _MyHomePageState();
}

class AnalogClock {}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimationController _controller;

  String get timeRemaining {
    Duration duration = Duration(seconds: c);
    c++;
    return '${(duration.inHours).toString().padLeft(2, '0')} : ${(duration.inMinutes).toString().padLeft(2, '0')} : ${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: Duration(seconds: anime_timer),
    );
  }

  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return new Scaffold(
      appBar: AppBar(),
      body: new Padding(
        padding: const EdgeInsets.all(40.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.start,
            ),
            new Expanded(
              child: new Align(
                alignment: FractionalOffset.center,
                child: new AspectRatio(
                  aspectRatio: 1.0,
                  child: new Stack(
                    children: <Widget>[
                      new Positioned.fill(
                        child: new AnimatedBuilder(
                            animation: _controller,
                            builder: (BuildContext context, Widget child) {
                              return new CustomPaint(
                                painter: new ProgressPainter(
                                  animation: _controller,
                                  color: Colors.blue,
                                  backgroundColor: Colors.white,
                                ),
                              );
                            }),
                      ),
                      new Align(
                        alignment: FractionalOffset.center,
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new Text('Label',
                                style: themeData.textTheme.subhead),
                            new AnimatedBuilder(
                                animation: _controller,
                                builder: (BuildContext context, Widget child) {
                                  return new Text(
                                    timeRemaining,
                                    style: TextStyle(
                                      fontSize: 50,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  );
                                }),
                            new Text('+1', style: themeData.textTheme.title),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            new Container(
              margin: new EdgeInsets.all(10.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Container(),
                  ),
                ],
              ),
            ),
            new Container(
              margin: new EdgeInsets.all(10.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new IconButton(
                      icon: new Icon(Icons.delete),
                      onPressed: () {
                        c = 0;
                        _controller.stop();
                        _controller.reset();

                        setState(() {
                          new Icon(Icons.play_arrow);
                        });
                      }),
                  new FloatingActionButton(
                    child: new AnimatedBuilder(
                      animation: _controller,
                      builder: (BuildContext context, Widget child) {
                        return new Icon(_controller.isAnimating
                            ? Icons.pause
                            : Icons.play_arrow);
                      },
                    ),
                    onPressed: () {
                      if (_controller.isAnimating) {
                        setState(() {
                          new Icon(Icons.play_arrow);
                        });
                        advancedPlayer.pause();

                        _controller.stop();
                      } else {
                        audioCache.loop('clock.mp3');

                        c = 0;
                        _controller.repeat();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
