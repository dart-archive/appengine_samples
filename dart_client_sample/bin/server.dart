// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:appengine/appengine.dart';

void _requestHandler(HttpRequest request) {
  if (request.uri.path == '/') {
    context.services.modules.hostname().then((hostname) {
      var location = new Uri.http(hostname, '/index.html');
      request.response.redirect(location);
    });
  } else {
    context.assets.serve(request.uri.path);
  }
}

void main() {
  runAppEngine(_requestHandler).then((_) {
    // Server running.
  });
}
