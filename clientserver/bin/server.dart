// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:appengine/appengine.dart';
import 'package:gcloud/db.dart';
import 'package:http_server/http_server.dart';

import 'package:clientserver/model.dart';

void main() {
  runAppEngine(requestHandler);
}

final staticFiles = new VirtualDirectory('build')
    ..allowDirectoryListing = true;

Future requestHandler(HttpRequest request) async {
  if (request.uri.path == '/items') {
    await handleItems(request);
  } else if (request.uri.path == '/clean') {
    await handleClean(request);
    await request.response.redirect(Uri.parse('/index.html'));
  } else if (request.uri.path == '/') {
    await request.response.redirect(Uri.parse('/index.html'));
  } else {
    await staticFiles.serveRequest(request);
  }
}

Future handleItems(HttpRequest request) async {
  if (request.method == 'GET') {
    final List<Item> items = await queryItems();
    final result = items.map((item) => item.serialize()).toList();
    final json = {'success': true, 'result': result};
    await sendJSONResponse(request, json);
  } else if (request.method == 'POST') {
    final json = await readJSONRequest(request);
    final item = Item.deserialize(json)..parentKey = itemsRoot;
    final error = item.validate();
    if (error != null) {
      await sendJSONResponse(request, {'success': false, 'error': error});
    } else {
      await dbService.commit(inserts: [item]);
      await sendJSONResponse(request, {'success': true});
    }
  }
}

Future handleClean(HttpRequest request) async {
  final items = await queryItems();
  final deletes = items.map((item) => item.key).toList();
  return dbService.commit(deletes: deletes);
}

Future readJSONRequest(HttpRequest request) =>
    request.transform(utf8.decoder).transform(json.decoder).single;

Future sendJSONResponse(HttpRequest request, json) {
  request.response
    ..headers.contentType = ContentType.json
    ..headers.set("Cache-Control", "no-cache")
    ..add(utf8.encode(jsonEncode(json)));

  return request.response.close();
}
