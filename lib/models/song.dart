import 'package:Musify/helper/utils.dart';

class Song {
  String id;
  String title;
  String subtitle;
  String type;
  String image;
  String url;

  Song(this.id, this.title, this.type, this.image, this.url);

  Song.fromJSON(Map<String, dynamic> json) {
    id = json["id"];
    title = fixHtmlChars(json["title"]);
    title = fixHtmlChars(json["subtitle"]) ?? "";
    type = fixHtmlChars(json["type"]);
    image = imageQuality(json["image"]) ?? "";
    url = json["perma_url"];
  }
}
