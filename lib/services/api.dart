import 'dart:convert';

import 'package:Musify/models/song.dart';
import "package:dio/dio.dart";
import 'package:dio_http_cache/dio_http_cache.dart';
import "package:flutter/material.dart";

final Dio dio = Dio(
  BaseOptions(
    baseUrl: "https://www.jiosaavn.com",
    headers: {'x-access-token': 'YYvnqg2l6R48uTUr1NcxRauZ79KGikhD'},
  ),
)..interceptors.add(DioCacheManager(
    CacheConfig(
      baseUrl: "https://www.jiosaavn.com",
      defaultMaxAge: Duration(days: 7),
    ),
  ).interceptor);

Future<List> getTopSongs() async {
  final Response resp = await dio.get(
      "/api.php?__call=webapi.get&token=8MT-LQlP35c_&type=playlist&p=1&n=20&includeMetaTags=0&ctx=web6dot0&api_version=4&_format=json&_marker=0");

  // print(resp.data);

  final data = json.decode(resp.data);
  print(data["list"]);

  return data["list"].map((song) => Song.fromJSON(song)).toList();
}
