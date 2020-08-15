import 'dart:io';
import 'dart:ui';

import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:music/API/saavn.dart';
import 'package:music/ui/about.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'API/saavn.dart';
import 'music.dart';

main() async {
  runApp(
    MaterialApp(
      theme: ThemeData(
        fontFamily: "DMSans",
        accentColor: accent,
        primaryColor: accent,
        canvasColor: Colors.transparent,
      ),
      home: AppName(),
    ),
  );
}

class AppName extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new AppState();
  }
}

class AppState extends State<AppName> {
  TextEditingController searchBar = new TextEditingController();
  bool fetchingSongs = false;

  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xff263238),
      // navigation bar color
      statusBarColor: Colors.transparent, // status bar color
    ));

    MediaNotification.setListener('play', () {
      setState(() {
        playerState = PlayerState.playing;
        status = 'play';
        audioPlayer.play(kUrl);
      });
    });

    MediaNotification.setListener('pause', () {
      setState(() {
        status = 'pause';
        audioPlayer.pause();
      });
    });

    MediaNotification.setListener("close", () {
      audioPlayer.stop();
      dispose();
      checker = "Nahi";
      MediaNotification.hideNotification();
    });
  }

  search() async {
    String searchQuery = searchBar.text;
    if (searchQuery.isEmpty) return;
    fetchingSongs = true;
    setState(() {});
    await fetchSongsList(searchQuery);
    fetchingSongs = false;
    setState(() {});
  }

  getSongDetails(String id, var context) async {
    await fetchSongDetails(id);
    checker = "Haa";
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AudioApp()));
  }

  downloadSong(id) async {
    var status = await Permission.storage.status;
    if (status.isUndetermined || status.isDenied) {
      // code of read or write file in external storage (SD card)
      // You can request multiple permissions at once.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      print(statuses[Permission.storage]);
    }
    status = await Permission.storage.status;
    await fetchSongDetails(id);
    if (status.isGranted) {
      ProgressDialog pr = ProgressDialog(context);
      pr = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: false,
        showLogs: false,
      );

      pr.style(
        backgroundColor: Color(0xff263238),
        elevation: 4,
        textAlign: TextAlign.left,
        progressTextStyle: TextStyle(color: Colors.white),
        message: "Downloading " + title,
        messageTextStyle: TextStyle(color: accent),
        progressWidget: Padding(
          padding: const EdgeInsets.all(20.0),
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      );
      await pr.show();

      final filename = title + ".m4a";
      final artname = title + "_artwork.jpg";

      String dlPath = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_MUSIC);
      String filepath = dlPath + "/" + filename;
      String filepath2 = dlPath + "/" + artname;
      if (has_320 == "true") {
        kUrl = raw_kUrl.replaceAll("_96.mp4", "_320.mp4");
        final client = http.Client();
        final request = new http.Request('HEAD', Uri.parse(kUrl))
          ..followRedirects = false;
        final response = await client.send(request);
        print(response.statusCode);
        kUrl = (response.headers['location']);
        print(raw_kUrl);
        print(kUrl);
        final request2 = new http.Request('HEAD', Uri.parse(kUrl))
          ..followRedirects = false;
        final response2 = await client.send(request2);
        if (response2.statusCode != 200) {
          kUrl = kUrl.replaceAll(".mp4", ".mp3");
        }
      }
      var request = await HttpClient().getUrl(Uri.parse(kUrl));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      File file = new File(filepath);

      var request2 = await HttpClient().getUrl(Uri.parse(image));
      var response2 = await request2.close();
      var bytes2 = await consolidateHttpClientResponseBytes(response2);
      File file2 = new File(filepath2);

      await file.writeAsBytes(bytes);
      await file2.writeAsBytes(bytes2);
      print("Started tag editing");

      final tag = Tag(
        title: title,
        artist: artist,
        artwork: filepath2,
        album: album,
        lyrics: lyrics,
        genre: null,
      );

      print("Setting up Tags");
      final tagger = new Audiotagger();
      await tagger.writeTags(
        path: filepath,
        tag: tag,
      );
      await new Future.delayed(const Duration(seconds: 1), () {});
      await pr.hide();

      if (await file2.exists()) {
        await file2.delete();
      }
      print("Done");
      Fluttertoast.showToast(
          msg: "Download Complete!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Color(0xff61e88a),
          fontSize: 14.0);
    } else if (status.isDenied || status.isPermanentlyDenied) {
      Fluttertoast.showToast(
          msg: "Storage Permission Denied!\nCan't Download Songs",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Color(0xff61e88a),
          fontSize: 14.0);
    } else {
      Fluttertoast.showToast(
          msg: "Permission Error!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.values[50],
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Color(0xff61e88a),
          fontSize: 14.0);
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
          ],
        ),
      ),
      child: new Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.transparent,
        //backgroundColor: Color(0xff384850),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Builder(builder: (contextt) {
            return Container(
              height: 50,
              width: 180,
              child: FloatingActionButton(
                isExtended: true,
                child: Container(
                  alignment: Alignment.center,
                  height: 100,
                  width: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(40),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xff4db6ac),
                        //Color(0xff00c754),
                        Color(0xff61e88a),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 130,
                      child: Center(
                        child: Row(
                          children: <Widget>[
                            Icon(
                              MdiIcons.musicNoteOutline,
                              color: Colors.black,
                            ),
                            Text(
                              " Now Playing",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                onPressed: () => {
                  checker = "Nahi",
                  if (kUrl != "")
                    {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AudioApp()),
                      )
                    }
                  else
                    Scaffold.of(contextt).showSnackBar(
                      new SnackBar(
                        content: new Text("Nothing is Playing."),
                        action: SnackBarAction(
                            label: 'Okay',
                            textColor: accent,
                            onPressed:
                                Scaffold.of(contextt).hideCurrentSnackBar),
                        backgroundColor: Colors.black38,
                        duration: Duration(seconds: 2),
                      ),
                    )
                },
                tooltip: 'Increment',
              ),
            );
          }),
        ),
        body: new SingleChildScrollView(
          padding: EdgeInsets.all(12.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Padding(padding: EdgeInsets.only(top: 30, bottom: 20.0)),
              Center(
                child: Row(children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 42.0),
                      child: Center(
                        child: new GradientText(
                          "Musify.",
                          shaderRect: Rect.fromLTWH(13.0, 0.0, 100.0, 50.0),
                          gradient: LinearGradient(colors: [
                            Color(0xff4db6ac),
                            Color(0xff61e88a),
                          ]),
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: IconButton(
                        iconSize: 26,
                        alignment: Alignment.center,
                        icon: Icon(MdiIcons.dotsVertical),
                        color: accent,
                        onPressed: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AboutPage(),
                                ),
                              ),
                            }),
                  )
                ]),
              ),
              new Padding(padding: EdgeInsets.only(top: 20)),
              new TextField(
                onSubmitted: (String value) {
                  search();
                },
                controller: searchBar,
                style: TextStyle(
                  fontSize: 16,
                  color: accent,
                ),
                cursorColor: Colors.green[50],
                decoration: InputDecoration(
                  fillColor: Color(0xff263238),
                  filled: true,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(100),
                    ),
                    borderSide: BorderSide(
                      color: Color(0xff263238),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(100),
                    ),
                    borderSide: BorderSide(color: accent),
                  ),
                  suffixIcon: IconButton(
                    icon: fetchingSongs
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    new AlwaysStoppedAnimation<Color>(accent),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.search,
                            color: accent,
                          ),
                    color: accent,
                    onPressed: () {
                      search();
                    },
                  ),
                  border: InputBorder.none,
                  hintText: "Search...",
                  hintStyle: TextStyle(
                    color: accent,
                  ),
                  contentPadding: const EdgeInsets.only(
                    left: 18,
                    right: 20,
                    top: 14,
                    bottom: 14,
                  ),
                ),
              ),
              if (searchedList.isNotEmpty)
                new ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchedList.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return new Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Card(
                        color: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          onTap: () {
                            getSongDetails(searchedList[index]["id"], context);
                          },
                          splashColor: accent,
                          hoverColor: accent,
                          focusColor: accent,
                          highlightColor: accent,
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                leading: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    MdiIcons.musicNoteOutline,
                                    size: 30,
                                    color: accent,
                                  ),
                                ),
                                title: Text(
                                  (searchedList[index]['title'])
                                      .toString()
                                      .split("(")[0]
                                      .replaceAll("&quot;", "\"")
                                      .replaceAll("&amp;", "&"),
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  searchedList[index]['more_info']["singers"],
                                  style: TextStyle(color: Colors.white),
                                ),
                                trailing: IconButton(
                                  color: accent,
                                  icon: Icon(MdiIcons.downloadOutline),
                                  onPressed: () =>
                                      downloadSong(searchedList[index]["id"]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
