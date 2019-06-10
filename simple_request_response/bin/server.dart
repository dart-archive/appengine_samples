// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:convert';

import 'package:appengine/appengine.dart';

void main() {
  runAppEngine(_requestHandler);
}

void _requestHandler(HttpRequest request) {
  if (request.uri.path == '/_utils/headers') {
    _printHeaders(request);
  } else if (request.uri.path == '/_utils/environment') {
    _printEnvironment(request);
  } else if (request.uri.path == '/_utils/version') {
    _printVersion(request);
  } else {
    _defaultHandler(request);
  }
}

_printHeaders(HttpRequest request) async {
  var headers = request.headers;
  await request.drain();

  final buffer = new StringBuffer();
  buffer.writeln("Here is a list of the http headers from the client:");
  buffer.writeln("");
  headers.forEach((String name, List<String> values) {
    buffer.writeln("  $name : [${values.join(', ')}]");
  });
  _sendResponse(request.response, HttpStatus.ok, buffer.toString());
}

_printEnvironment(HttpRequest request) async {
  await request.drain();

  final buffer = new StringBuffer();
  for (var key in Platform.environment.keys) {
    buffer.writeln('$key="${Platform.environment[key]}"');
  }
  _sendResponse(request.response, HttpStatus.ok, buffer.toString());
}

_printVersion(HttpRequest request) async {
  await request.drain();

  final buffer = new StringBuffer()
    ..writeln('Dart version: ${Platform.version}')
    ..writeln('Dart executable: ${Platform.executable}')
    ..writeln('Dart executable arguments: ${Platform.executableArguments}');
  _sendResponse(request.response, HttpStatus.ok, buffer.toString());
}

_defaultHandler(HttpRequest request) async {
  await request.drain();

  _sendResponse(request.response, HttpStatus.notFound,
      "Hello world from dart application.");
}

_sendResponse(HttpResponse response, int statusCode, String message) async {
  final data = utf8.encode(message);
  response
    ..headers.contentType = ContentType.text
    ..headers.set("Cache-Control", "no-cache")
    ..statusCode = statusCode
    ..contentLength = data.length
    ..add(data);
    await response.close();
}
