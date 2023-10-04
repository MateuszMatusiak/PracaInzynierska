import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

class ImageData {
  int id = 0;
  Uint8List bytes = Uint8List(0);

  ImageData(this.id, this.bytes);

  ImageData.empty() {}

  factory ImageData.fromJson(dynamic json) {
    if (json == null) return ImageData.empty();
    List<int> imageBytes = base64Decode(json['bytes']);
    Uint8List b = Uint8List.fromList(imageBytes);
    return ImageData(json['id'], b);
  }
}
