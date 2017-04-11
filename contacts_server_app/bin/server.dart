// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:shelf/shelf.dart';
import 'package:shelf_appengine/shelf_appengine.dart' as shelf_ae;

import 'package:contacts_server/shelf_datastore.dart';
import 'package:contacts_server/data_store_contact.dart';

final _dataStoreHandler = getApiHandler({'contacts': contactJsonMapper});

void main() {

  var handler = new Cascade()
      .add(_apiHandler)
      .add(shelf_ae.assetHandler)
      .handler;

  shelf_ae.serve(handler);
}

_apiHandler(Request request) {
  var segments = request.url.pathSegments;

  if (segments.isEmpty || segments.first != 'api') {
    return new Response.notFound('not found');
  }

  return _dataStoreHandler(request.change(scriptName: '/api'));
}
