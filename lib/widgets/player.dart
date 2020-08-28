import 'dart:async';

import 'package:Musify/services/saavn.dart';
import 'package:Musify/style/appColors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import "package:flutter/material.dart";
import "package:assets_audio_player/assets_audio_player.dart";
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../services/saavn.dart';
import '../services/saavn.dart';
import '../services/saavn.dart';

String status = 'hidden';

PlayerState playerState;

class MusifyPlayer extends StatefulWidget {
  @override
  _MusifyPlayerState createState() => _MusifyPlayerState();
}

class _MusifyPlayerState extends State<MusifyPlayer> {
  final assetsMusifyPlayer = AssetsAudioPlayer();

  Duration duration;
  Duration position;

  get isPlaying => playerState == PlayerState.play;

  get isPaused => playerState == PlayerState.pause;

  get durationText => duration != null ? duration.toString().split('.').first : '';

  get positionText => position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  StreamSubscription _positionSubscription;
  StreamSubscription _MusifyPlayerStateSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    try {
      assetsMusifyPlayer.open(
        Audio.network(
          kUrl,
          metas: Metas(
            title: title,
            album: album,
            artist: artist,
            image: MetasImage.network(image),
          ),
        ),
        showNotification: true,
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff384850),
            Color(0xff263238),
            Color(0xff263238),
            //Color(0xff61e88a),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.transparent,
          elevation: 0,
          //backgroundColor: Color(0xff384850),
          centerTitle: true,
          title: GradientText(
            "Now Playing",
            shaderRect: Rect.fromLTWH(13.0, 0.0, 100.0, 50.0),
            gradient: LinearGradient(colors: [
              Color(0xff4db6ac),
              Color(0xff61e88a),
            ]),
            style: TextStyle(
              color: accent,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 14.0),
            child: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 32,
                color: accent,
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 35.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: CachedNetworkImageProvider(image),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 35.0, bottom: 35),
                  child: Column(
                    children: <Widget>[
                      GradientText(
                        title,
                        shaderRect: Rect.fromLTWH(13.0, 0.0, 100.0, 50.0),
                        gradient: LinearGradient(colors: [
                          Color(0xff4db6ac),
                          Color(0xff61e88a),
                        ]),
                        textScaleFactor: 2.5,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          album + "  |  " + artist,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: accentLight,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Material(child: _buildPlayer()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer() => Container(
        padding: EdgeInsets.only(top: 15.0, left: 16, right: 16, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (duration != null)
              Slider(
                  activeColor: accent,
                  inactiveColor: Colors.green[50],
                  value: position?.inMilliseconds?.toDouble() ?? 0.0,
                  onChanged: (double value) {
                    return assetsMusifyPlayer.seek(Duration(milliseconds: value.round()));
                  },
                  min: 0.0,
                  max: duration.inMilliseconds.toDouble()),
            if (position != null) _buildProgressView(),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isPlaying
                          ? Container()
                          : Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xff4db6ac),
                                      //Color(0xff00c754),
                                      Color(0xff61e88a),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(100)),
                              child: IconButton(
                                onPressed: isPlaying ? null : () => play(),
                                iconSize: 40.0,
                                icon: Padding(
                                  padding: const EdgeInsets.only(left: 2.2),
                                  child: Icon(MdiIcons.playOutline),
                                ),
                                color: Color(0xff263238),
                              ),
                            ),
                      isPlaying
                          ? Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xff4db6ac),
                                      //Color(0xff00c754),
                                      Color(0xff61e88a),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(100)),
                              child: IconButton(
                                onPressed: isPlaying ? () => pause() : null,
                                iconSize: 40.0,
                                icon: Icon(MdiIcons.pause),
                                color: Color(0xff263238),
                              ),
                            )
                          : Container()
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Builder(builder: (context) {
                      return FlatButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                          color: Colors.black12,
                          onPressed: () {
                            showBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                      decoration: BoxDecoration(color: Color(0xff212c31), borderRadius: BorderRadius.only(topLeft: const Radius.circular(18.0), topRight: const Radius.circular(18.0))),
                                      height: 400,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10.0),
                                            child: Row(
                                              children: <Widget>[
                                                IconButton(
                                                    icon: Icon(
                                                      Icons.arrow_back_ios,
                                                      color: accent,
                                                      size: 20,
                                                    ),
                                                    onPressed: () => {Navigator.pop(context)}),
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(right: 42.0),
                                                    child: Center(
                                                      child: Text(
                                                        "Lyrics",
                                                        style: TextStyle(
                                                          color: accent,
                                                          fontSize: 30,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          lyrics != "null"
                                              ? Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                      padding: const EdgeInsets.all(6.0),
                                                      child: Center(
                                                        child: SingleChildScrollView(
                                                          child: Text(
                                                            lyrics,
                                                            style: TextStyle(
                                                              fontSize: 16.0,
                                                              color: accentLight,
                                                            ),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      )),
                                                )
                                              : Padding(
                                                  padding: const EdgeInsets.only(top: 120.0),
                                                  child: Center(
                                                    child: Container(
                                                      child: Text(
                                                        "No Lyrics available ;(",
                                                        style: TextStyle(color: accentLight, fontSize: 25),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ));
                          },
                          child: Text(
                            "Lyrics",
                            style: TextStyle(color: accent),
                          ));
                    }),
                  )
                ],
              ),
            ),
          ],
        ),
      );

  Future play() async {
    await assetsMusifyPlayer.play();
    // MediaNotification.showNotification(title: title, author: artist, artUri: image, isPlaying: true);
    if (mounted)
      setState(() {
        playerState = PlayerState.play;
      });
  }

  Future pause() async {
    await assetsMusifyPlayer.pause();
    // MediaNotification.showNotification(title: title, author: artist, artUri: image, isPlaying: false);
    setState(() {
      playerState = PlayerState.pause;
    });
  }

  Future stop() async {
    await assetsMusifyPlayer.stop();
    if (mounted)
      setState(() {
        playerState = PlayerState.stop;
        position = Duration();
      });
  }

  Future mute(bool muted) async {
    await assetsMusifyPlayer.setVolume(0);
    if (mounted)
      setState(() {
        isMuted = muted;
      });
  }

  void onComplete() {
    if (mounted) setState(() => playerState = PlayerState.stop);
  }

  Row _buildProgressView() => Row(mainAxisSize: MainAxisSize.min, children: [
        Text(
          position != null ? "${positionText ?? ''} ".replaceFirst("0:0", "0") : duration != null ? durationText : '',
          style: TextStyle(fontSize: 18.0, color: Colors.green[50]),
        ),
        Spacer(),
        Text(
          position != null ? "${durationText ?? ''}".replaceAll("0:", "") : duration != null ? durationText : '',
          style: TextStyle(fontSize: 18.0, color: Colors.green[50]),
        )
      ]);
}
