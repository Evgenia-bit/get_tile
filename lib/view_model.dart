import 'dart:math';

import 'package:flutter/cupertino.dart';

class AppViewModel extends ChangeNotifier {
  final regExp = RegExp(r'-?\d{1,3}.\d+');
  double? lat;
  double? lon;
  int x = 0;
  int y = 0;
  int z = 0;
  String imageURL = '';

  Future<void> loadTile() async {
    x = _getX(lon!);
    y = _getY(lat!);
    imageURL =
        'https://core-carparks-renderer-lots.maps.yandex.net/maps-rdr-carparks/tiles?l=carparks&x=$x&y=$y&z=$z&scale=1&lang=ru_RU';
    notifyListeners();
  }

  int _getX(double lon) {
    return (pow(2, z) * (lon + 180) / 360).floor();
  }

  int _getY(double lat) {
    var sinLatitude = sin(lat * pi/180);
    return ((0.5 - log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * pi)) *  pow(2, z)).floor();
  }
}
