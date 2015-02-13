// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:appengine/appengine.dart';
import 'package:gcloud/db.dart';
import 'package:mustache/mustache.dart' as mustache;

final HTML = new ContentType('text', 'html', charset: 'charset=utf-8');

final MAIN_PAGE = mustache.parse('''
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
    <p class='lead'>Current user: {{user}}</p>
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

@Kind()
class Greeting extends Model {
  @StringProperty()
  String author;

  @StringProperty()
  String content;

  @DateTimeProperty()
  DateTime date;
}

void _serveMainPage(HttpRequest request) {
  var db = context.services.db;
  var logging = context.services.logging;

  // We will place all Greeting entries under this key. This allows us to do
  // strongly consistent ancestor queries as opposed to eventually consistent
  // queries.
  var rootKey = db.emptyKey.append(Greeting, id: 1);

  logging.debug('Got request ${request.uri} .');
  var users = context.services.users;

  if (users.currentUser == null) {
    users.createLoginUrl('${request.uri}').then((String url) {
      logging.info('Redirecting user to login $url.');
      return request.response.redirect(Uri.parse(url));
    });
    return;
  }

  if (request.method == 'GET') {
    logging.info('Fetch greetings from datastore.');
    var query = db.query(Greeting, ancestorKey: rootKey)..order('-date');
    query.run().toList().then((List<Greeting> greetings) {
      var renderMap = {
        'entries': greetings,
        'user': users.currentUser.email,
      };
      logging.info('Sending list of greetings back.');
      return _sendResponse(request.response, MAIN_PAGE.renderString(renderMap));
    });
  } else {
    request.transform(UTF8.decoder).join('').then((String formData) {
      var parms = Uri.splitQueryString(formData);
      var greeting = new Greeting()
          ..parentKey = rootKey
          ..author = parms['author'] + ' (${users.currentUser.email})'
          ..content = parms['text']
          ..date = new DateTime.now();
      logging.info('Store greeting to datastore ...');
      return db.commit(inserts: [greeting]).then((_) {
        return request.response.redirect(request.uri);
      });
    });
  }
}

Future _sendResponse(HttpResponse response, String message) {
  response
      ..headers.contentType = HTML
      ..headers.set("Cache-Control", "no-cache")
      ..statusCode = HttpStatus.OK
      ..add(UTF8.encode(message));

  return response.close();
}

void main() {
  runAppEngine(_serveMainPage);
}
