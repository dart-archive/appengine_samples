// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:appengine/appengine.dart';
import 'package:http_server/http_server.dart';

void main() {
  runAppEngine(_requestHandler);
}

final staticFiles = new VirtualDirectory('build')
    ..allowDirectoryListing = true;

Future _requestHandler(HttpRequest request) async {
  if (request.uri.path == '/') {
    final location = request.requestedUri.replace(path: '/index.html');
    await request.response.redirect(location);
  } else {
    await staticFiles.serveRequest(request);
  }
}
