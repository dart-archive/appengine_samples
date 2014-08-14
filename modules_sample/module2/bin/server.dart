// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:convert';

import 'package:appengine/appengine.dart';

void _sendResponse(HttpResponse response, int statusCode, String message) {
  var data = UTF8.encode(message);
  response
      ..headers.contentType =
          new ContentType('text', 'plain', charset: 'charset=utf-8')
      ..headers.set('Cache-Control', 'no-cache')
      ..statusCode = statusCode
      ..contentLength = data.length
      ..add(data)
      ..close();
}

void _requestHandler(HttpRequest request) {
  request.drain().then((_) {
    _sendResponse(request.response,
                  HttpStatus.NOT_FOUND,
                  'Hello from Dart module (${request.uri.path}).');
  });
}

void main() {
  runAppEngine(_requestHandler).then((_) {
    // Server running.
  });
}
