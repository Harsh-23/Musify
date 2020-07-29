import 'dart:ui';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:flutter/material.dart';
import 'package:music/API/saavn.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'music.dart';

main() async {
  runApp(MaterialApp(
    theme: ThemeData(accentColor: accent, primaryColor: accent),
    home: AppName(),
  ));
}

class AppName extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new AppState();
  }
}

class AppState extends State<AppName> {
  TextEditingController searchBar = new TextEditingController();

  search(searchQuery) async {
    fetchSongsList(searchQuery);
    setState(() {});
  }

  getSongDetails(String id, var context) async {
    fetchSongDetails(id);
    Navigator.push(context, MaterialPageRoute(builder: (context) => AudioApp()));
  }

  downloadSong(id) async {
    ProgressDialog pr = ProgressDialog(context);
    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
      showLogs: false,
    );

    fetchSongDetails(id);

    pr.style(
      backgroundColor: Color.fromARGB(255, 20, 20, 20),
      elevation: 4,
      textAlign: TextAlign.left,
      progressTextStyle: TextStyle(color: Colors.white),
      message: "Downloading " + title,
      messageTextStyle: TextStyle(color: accent),
      progressWidget: Padding(
        padding: const EdgeInsets.all(20.0),
        child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(accent)),
      ),
    );
    await pr.show();

    final filename = title + ".mp3";
    final artname = title + "_artwork.jpg";
    String filepath = "storage/emulated/0/Download/" + filename;
    String filepath2 = "storage/emulated/0/Download/" + artname;

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
    print("Done");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.black,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Builder(builder: (contextt) {
            return FloatingActionButton.extended(
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
                  Scaffold.of(contextt).showSnackBar(new SnackBar(
                    content: new Text("Nothing is Playing."),
                    action: SnackBarAction(label: 'Okay', textColor: accent, onPressed: Scaffold.of(contextt).hideCurrentSnackBar),
                    backgroundColor: Color.fromARGB(255, 20, 20, 20),
                    duration: Duration(seconds: 2),
                  ))
              },
              tooltip: 'Increment',
              icon: Icon(Icons.music_note),
              label: Text("Now playing"),
            );
          }),
        ),
        body: new SingleChildScrollView(
          padding: EdgeInsets.all(12.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Padding(padding: EdgeInsets.only(top: 30, bottom: 20.0)),
              new Text(
                "Musify.",
                style: TextStyle(color: accent, fontSize: 35, fontWeight: FontWeight.bold),
              ),
              new Padding(padding: EdgeInsets.only(top: 20)),
              new TextField(
                onSubmitted: (String value) {
                  search(value);
                },
                controller: searchBar,
                style: TextStyle(
                  fontSize: 16,
                  color: accent,
                ),
                decoration: InputDecoration(
                  fillColor: Color.fromARGB(255, 22, 22, 22),
                  filled: true,
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 22, 22, 22),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accent),
                  ),
                  suffixIcon: Icon(
                    Icons.search,
                    color: accent,
                  ),
                  border: InputBorder.none,
                  hintText: "Search...",
                  hintStyle: TextStyle(
                    color: accent,
                  ),
                  contentPadding: const EdgeInsets.only(
                    left: 16,
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
                          color: Color.fromARGB(255, 20, 20, 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                                      Icons.music_note,
                                      size: 30,
                                      color: accent,
                                    ),
                                  ),
                                  title: Text(
                                    (searchedList[index]['title']).toString().split("(")[0],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    searchedList[index]['more_info']["singers"],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  trailing: IconButton(color: accent, icon: Icon(Icons.file_download), onPressed: () => downloadSong(searchedList[index]["id"])),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
            ],
          ),
        ));
  }
}
