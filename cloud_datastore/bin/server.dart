// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:appengine/appengine.dart';
import 'package:gcloud/db.dart';
import 'package:mustache/mustache.dart' as mustache;

void main() {
  runAppEngine(_serveMainPage);
}

@Kind()
class Greeting extends Model {
  @StringProperty()
  String author;

  @StringProperty()
  String content;

  @DateTimeProperty()
  DateTime date;
}

_serveMainPage(HttpRequest request) async {
  final db = context.services.db;
  final logging = context.services.logging;

  // We will place all Greeting entries under this key. This allows us to do
  // strongly consistent ancestor queries as opposed to eventually consistent
  // queries.
  final rootKey = db.emptyKey.append(Greeting, id: 1);

  logging.debug('Got request ${request.uri} .');

  if (request.method == 'GET') {
    logging.info('Fetch greetings from datastore.');
    final query = db.query<Greeting>(ancestorKey: rootKey)..order('-date');
    final List<Greeting> greetings = await query.run().toList();
    final renderMap = {
      'entries': greetings,
    };
    logging.info('Sending list of greetings back.');
    await _sendResponse(request.response, MAIN_PAGE.renderString(renderMap));
  } else {
    final formData = await request.transform(utf8.decoder).join('');
    final parms = Uri.splitQueryString(formData);
    final greeting = new Greeting()
      ..parentKey = rootKey
      ..author = parms['author']
      ..content = parms['text']
      ..date = new DateTime.now();
    logging.info('Store greeting to datastore ...');
    await db.commit(inserts: [greeting]);
    await request.response.redirect(request.uri);
  }
}

Future _sendResponse(HttpResponse response, String message) {
  response
    ..headers.contentType = ContentType.html
    ..headers.set("Cache-Control", "no-cache")
    ..statusCode = HttpStatus.ok
    ..add(utf8.encode(message));
  return response.close();
}

final MAIN_PAGE = mustache.Template('''
<html>
<head>
  <title>Dart Datastore Sample</title>
  <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.0/css/bootstrap.min.css">
  <style>
    body {
      padding: 24px;
    }
    label {
      display: block;
      font-weight: normal;
    }
    input, textarea, label {
      margin-top: 8px;
    }
    .post {
      margin-top: 8px;
      padding: 10px;
      background: lightgray;
    }
  </style>
</head>
<body>
  <div class='container'>
    <form role='form' class="form-horizontal" method="POST">
      <div class="form-group">
        <label for="author" class="col-sm-2 control-label">Author</label>
        <div class="col-sm-10">
          <input type="text" class="form-control" name='author' placeholder="Author">
        </div>
      </div>
      <div class="form-group">
        <label for="text" class="col-sm-2 control-label">Message</label>
        <div class="col-sm-10">
          <textarea class="form-control" name="text" rows="5"></textarea>
        </div>
      </div>
      <div class="form-group">
        <div class="col-sm-offset-2 col-sm-10">
          <button type="submit" class="btn btn-default">Sign the Guestbook</button>
        </div>
      </div>
    </form>
    {{#entries}}
    <div class="post">
      Author: {{author}}<br />
      Date: {{date}}<br />
      Message:<br />
      <pre>{{content}}</pre>
    </div>
    {{/entries}}
  </div>
</body>
</html>
''');
