import 'dart:convert';
import 'package:des_plugin/des_plugin.dart';
import 'package:http/http.dart' as http;

List searchedList = [];
String kUrl = "", checker, image, title, album, artist;
String key = "38346591";
String decrypt = "";

Future<List> fetchSongsList(searchQuery) async {
  String searchUrl = "https://www.jiosaavn.com/api.php?app_version=5.18.3&api_version=4&readable_version=5.18.3&v=79&_format=json&query=" + searchQuery + "&__call=autocomplete.get";
  var res = await http.get(searchUrl, headers: {"Accept": "application/json"});
  var resEdited = (res.body).split("-->");
  var getMain = json.decode(resEdited[1]);

  searchedList = getMain["songs"]["data"];

  return searchedList;
}

Future fetchSongDetails(songId) async {
  String songUrl = "https://www.jiosaavn.com/api.php?app_version=5.18.3&api_version=4&readable_version=5.18.3&v=79&_format=json&__call=song.getDetails&pids=" + songId;
  var res = await http.get(songUrl, headers: {"Accept": "application/json"});
  var resEdited = (res.body).split("-->");
  var getMain = json.decode(resEdited[1]);

  title = (getMain[songUrl]["title"]).toString().split("(")[0];
  image = (getMain[songUrl]["image"]);
  artist = (getMain[songUrl]["more_info"]["artistMap"]["primary_artists"][0]["name"]);
  album = (getMain[songId]["more_info"]["album"]).toString().replaceAll("&quot;", "\"");

  kUrl = await DesPlugin.decrypt(key, getMain[songUrl]["more_info"]["encrypted_media_url"]);
  kUrl = kUrl
      .replaceAll("aac.saavncdn.com", "h.saavncdn.com")
      .replaceAll("c.saavncdn.com", "h.saavncdn.com")
      .replaceAll("_96.mp4", "_320.mp3")
      .replaceAll("https://", "https://snoidcdnems01.cdnsrv.jio.com/");
}
