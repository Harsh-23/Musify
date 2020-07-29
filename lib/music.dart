import 'dart:async';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';

String status = 'hidden';
String kUrl = "", checker, image, title, album, artist;
Color accent = Colors.lightGreenAccent[700];

typedef void OnError(Exception exception);

enum PlayerState { stopped, playing, paused }

class AudioApp extends StatefulWidget {
  @override
  AudioAppState createState() => AudioAppState();
}

@override
class AudioAppState extends State<AudioApp> {
  Duration duration;
  Duration position;

  AudioPlayer audioPlayer;

  PlayerState playerState;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  @override
  void initState() {
    super.initState();

    initAudioPlayer();
    MediaNotification.setListener('pause', () {
      setState(() {
        status = 'pause';
        pause();
      });
    });

    MediaNotification.setListener('play', () {
      setState(() {
        playerState = PlayerState.playing;
        status = 'play';
        play();
      });
    });

    MediaNotification.setListener('select', () {});

    MediaNotification.setListener("close", () {
      stop();
      dispose();
      MediaNotification.hideNotification();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initAudioPlayer() {
    if (audioPlayer == null) {
      audioPlayer = AudioPlayer();
    }
    setState(() {
      if (checker == "Haa") {
        stop();
        play();
      }
      if (checker == "Nahi") {
        play();
      }
    });

    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));

    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(kUrl);
    MediaNotification.showNotification(
        title: title, author: artist, artUri: image, isPlaying: true);

    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    MediaNotification.showNotification(
        title: title, author: artist, artUri: image, isPlaying: false);
    setState(() {
      playerState = PlayerState.paused;
    });
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = Duration();
    });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    setState(() {
      isMuted = muted;
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            "Musify",
            style: TextStyle(
                color: accent, fontSize: 25, fontWeight: FontWeight.w500),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 14.0),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 28,
                color: accent,
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
          ),
        ),
        body: new Center(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                new Container(
                    width: 350,
                    height: 350,
                    decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        shape: BoxShape.rectangle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(
                                image.replaceAll("150x150", "500x500"))))),
                Padding(
                  padding: const EdgeInsets.only(top: 35.0, bottom: 35),
                  child: new Text(
                    title.replaceAll("&amp;", "&"),
                    textScaleFactor: 2.5,
                    style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Material(color: Colors.black, child: _buildPlayer()),
              ],
            ),
          ),
        ));
  }

  Widget _buildPlayer() => Container(
        color: Colors.black,
        padding: EdgeInsets.only(top: 25.0, left: 16, right: 16, bottom: 16),
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
                    return audioPlayer.seek((value / 1000).roundToDouble());
                  },
                  min: 0.0,
                  max: duration.inMilliseconds.toDouble()),
            if (position != null) _buildProgressView(),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                isPlaying
                    ? Container()
                    : Container(
                        decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(100)),
                        child: IconButton(
                          onPressed: isPlaying ? null : () => play(),
                          iconSize: 40.0,
                          icon: Icon(Icons.play_arrow),
                          color: Colors.black,
                        ),
                      ),
                isPlaying
                    ? Container(
                        decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(100)),
                        child: IconButton(
                          onPressed: isPlaying ? () => pause() : null,
                          iconSize: 40.0,
                          icon: Icon(Icons.pause),
                          color: Colors.black,
                        ),
                      )
                    : Container()
              ]),
            ),
          ],
        ),
      );

  Row _buildProgressView() => Row(mainAxisSize: MainAxisSize.min, children: [
        Text(
          position != null
              ? "${positionText ?? ''} ".replaceFirst("0:0", "0")
              : duration != null ? durationText : '',
          style: TextStyle(fontSize: 18.0, color: Colors.green[50]),
        ),
        Spacer(),
        Text(
          position != null
              ? "${durationText ?? ''}".replaceAll("0:", "")
              : duration != null ? durationText : '',
          style: TextStyle(fontSize: 18.0, color: Colors.green[50]),
        )
      ]);
}
