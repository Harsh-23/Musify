import 'package:flutter/material.dart';
import 'package:music/music.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text(
          "About",
          style: TextStyle(color: accent, fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: accent,
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(child: AboutCards()),
    );
  }
}

class AboutCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 8, right: 8, bottom: 6),
          child: Column(
            children: <Widget>[
              ListTile(
                title: Icon(
                  Icons.music_note,
                  size: 100,
                  color: accent,
                ),
                subtitle: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                        "Musify  | 2.0.0",
                        style: TextStyle(color: accent_light, fontSize: 24),
                      ),
                    )),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 10, right: 10),
          child: Divider(
            color: Colors.white24,
            thickness: 0.8,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
          child: Card(
            color: Color.fromARGB(255, 20, 20, 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            elevation: 2.3,
            child: ListTile(
              leading: new Container(
                height: 50,
                width: 50,
                child: Image.network(
                  "https://telegra.ph/file/57612f81b4304b6bf7008.png",
                ),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              ),
              title: Text('Harsh V23', style: TextStyle(color: accent_light)),
              subtitle: Text('App Developer', style: TextStyle(color: accent_light)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
          child: Card(
            color: Color.fromARGB(255, 20, 20, 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            elevation: 2.3,
            child: ListTile(
              leading: new Container(
                width: 50.0,
                height: 50,
                child: Image.network(
                  "https://telegra.ph/file/8347001fa79f85ae14ab5.png",
                ),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              ),
              title: Text(
                'Sumanjay',
                style: TextStyle(color: accent_light),
              ),
              subtitle: Text('App Developer', style: TextStyle(color: accent_light)),
            ),
          ),
        ),
      ],
    ));
  }
}
