// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:appengine/appengine.dart';
import 'package:route/server.dart';

printHeaders(HttpRequest request) {
  var headers = request.headers;
  request.drain().then((_) {
    var buffer = new StringBuffer();
    buffer.writeln("Here is a list of the http headers from the client:");
    buffer.writeln("");
    headers.forEach((String name, List<String> values) {
      buffer.writeln("  $name : [${values.join(', ')}]");
    });
    sendResponse(request.response, HttpStatus.OK, buffer.toString());
  });
}

printEnvironment(HttpRequest request) {
  var headers = request.headers;
  request.drain().then((_) {
    var buffer = new StringBuffer();
    for (var key in Platform.environment.keys) {
      buffer.writeln('$key="${Platform.environment[key]}"');
    }
    sendResponse(request.response, HttpStatus.OK, buffer.toString());
  });
}

defaultHandler(HttpRequest request) {
  request.drain().then((_) {
    sendResponse(request.response,
                 HttpStatus.NOT_FOUND,
                 "Hello world from dart application.");
  });
}

sendResponse(HttpResponse response, int statusCode, String message) {
  var data = UTF8.encode(message);
  response.headers.contentType =
      new ContentType('text', 'plain', charset: 'charset=utf-8');
  response.headers.set("Cache-Control", "no-cache");
  response.statusCode = statusCode;
  response.contentLength = data.length;
  response.add(data);
  response.close();
}

main() {
  runAppEngine().then((Stream<HttpRequest> requestStream) {
    var router = new Router(requestStream)
        ..serve(new UrlPattern(r'/_utils/headers')).listen(printHeaders)
        ..serve(new UrlPattern(r'/_utils/environment')).listen(printEnvironment)
        ..defaultStream.listen(defaultHandler);
  });
}
