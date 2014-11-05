// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:appengine/appengine.dart';

void _printModules(HttpRequest request) {
  var modules = context.services.modules;
  request.drain().then((_) {
    var futures = [
        modules.defaultVersion(modules.currentModule),
        modules.hostname(),
        modules.hostname(modules.currentModule),
        modules.hostname(null,
                         modules.currentVersion),
        modules.hostname(modules.currentModule,
                         modules.currentVersion),
        modules.hostname(modules.currentModule,
                         modules.currentVersion,
                         modules.currentInstance),
    ];
    Future.wait(futures).then((results) {
      var buffer = new StringBuffer();
      buffer
          ..writeln('Module: ${modules.currentModule}')
          ..writeln('Version: ${modules.currentVersion}')
          ..writeln('Instance: ${modules.currentInstance}')
          ..writeln('Default version: ${results[0]}')
          ..writeln('Hostname (current module): ${results[1]}')
          ..writeln('Hostname (current module): ${results[2]}')
          ..writeln('Hostname (current module): ${results[3]}')
          ..writeln('Hostname (current module): ${results[4]}')
          ..writeln('Hostname (current module): ${results[5]}');

      // Get the name of all modules.
      modules.modules().then((moduleNames) {
        var futures = [];
        buffer.writeln('Modules: $moduleNames');

        // Get the hostname of all modules.
        moduleNames.forEach((module) {
          futures.add(modules.hostname(module));
        });
        Future.wait(futures).then((results) {
          for (var i = 0; i < results.length; i++) {
            buffer.writeln('Hostname (${moduleNames[i]}): ${results[i]}');
          }
          _sendResponse(request.response, HttpStatus.OK, buffer.toString());
        });
      });
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
  _printModules(request);
}

void main() {
  runAppEngine(_requestHandler);
}
