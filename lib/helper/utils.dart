import 'package:url_launcher/url_launcher.dart';

Future<void> launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

fixHtmlChars(String htmlCharText) {
  htmlCharText = htmlCharText.replaceAll("&amp;", "&").replaceAll("&#039;", "'").replaceAll("&quot;", "\"");

  return htmlCharText;
}

imageQuality(String imageUrl) {
  imageUrl = imageUrl.replaceAll("150x150", "500x500");

  return imageUrl;
}

parseJson(List<dynamic> data) {}
