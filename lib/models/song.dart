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
    title = json["title"];
    title = json["subtitle"] ?? "";
    type = json["type"];
    image = json["image"] ?? "";
    url = json["perma_url"];
  }
}
