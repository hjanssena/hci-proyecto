import 'dart:typed_data';

import 'package:bebeia_front/repositories/media_repository.dart';
import 'package:flutter/material.dart';

class MediaViewModel extends ChangeNotifier {
  final MediaRepository _repository;
  MediaViewModel(this._repository);

  Future<Uint8List> getSecureImage(String url) {
    return _repository.fetchSecureImage(url);
  }
}
