// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:appengine/appengine.dart';

void _printHeaders(HttpRequest request) {
  var headers = request.headers;
  request.drain().then((_) {
    var buffer = new StringBuffer();
    buffer.writeln("Here is a list of the http headers from the client:");
    buffer.writeln("");
    headers.forEach((String name, List<String> values) {
      buffer.writeln("  $name : [${values.join(', ')}]");
    });
    _sendResponse(request.response, HttpStatus.OK, buffer.toString());
  });
}

void _printEnvironment(HttpRequest request) {
  request.drain().then((_) {
    var buffer = new StringBuffer();
    for (var key in Platform.environment.keys) {
      buffer.writeln('$key="${Platform.environment[key]}"');
    }
    _sendResponse(request.response, HttpStatus.OK, buffer.toString());
  });
}

void _printVersion(HttpRequest request) {
  request.drain().then((_) {
    var buffer = new StringBuffer();
    buffer.writeln('Dart version: ${Platform.version}');
    buffer.writeln('Dart executable: ${Platform.executable}');
    buffer.writeln(
        'Dart executable arguments: ${Platform.executableArguments}');
    _sendResponse(request.response, HttpStatus.OK, buffer.toString());
  });
}

void _printModules(HttpRequest request) {
  var modules = context.services.modules;
  request.drain().then((_) {
    var futures = [
        modules.defaultVersion(modules.currentModule),
        modules.hostname(modules.currentModule,
                         modules.currentVersion,
                         modules.currentInstance),
        modules.hostname(modules.currentModule,
                         null,
                         null)
    ];
    Future.wait(futures).then((results) {
      var buffer = new StringBuffer();
      buffer
          ..writeln('Module: ${modules.currentModule}')
          ..writeln('Version: ${modules.currentVersion}')
          ..writeln('Instance: ${modules.currentInstance}')
          ..writeln('Default version: ${results[0]}')
          ..writeln('Hostname: ${results[1]}')
          ..writeln('Hostname: ${results[2]}');
      _sendResponse(request.response, HttpStatus.OK, buffer.toString());
    });
  });
}

void _defaultHandler(HttpRequest request) {
  request.drain().then((_) {
    _sendResponse(request.response,
                 HttpStatus.NOT_FOUND,
                 "Hello world from dart application.");
  });
}

void _sendResponse(HttpResponse response, int statusCode, String message) {
  var data = UTF8.encode(message);
  response.headers.contentType =
      new ContentType('text', 'plain', charset: 'charset=utf-8');
  response.headers.set("Cache-Control", "no-cache");
  response.statusCode = statusCode;
  response.contentLength = data.length;
  response.add(data);
  response.close();
}

void _requestHandler(HttpRequest request) {
  if (request.uri.path == '/_utils/headers') {
    _printHeaders(request);
  } else if (request.uri.path == '/_utils/environment') {
    _printEnvironment(request);
  } else if (request.uri.path == '/_utils/version') {
    _printVersion(request);
  } else if (request.uri.path == '/_utils/modules') {
    _printModules(request);
  } else {
    _defaultHandler(request);
  }
}

main(List<String> args) {
  int port = 8080;
  if (args.length > 0) port = int.parse(args[0]);
  runAppEngine(_requestHandler, port: port);
}
