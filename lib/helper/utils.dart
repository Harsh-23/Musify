import 'package:url_launcher/url_launcher.dart';

Future<void> launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

parseJson(List<dynamic> data) {
  
}