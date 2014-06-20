// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:appengine/appengine.dart';
import 'package:cloud_datastore/cloud_datastore.dart';
import 'package:mustache/mustache.dart' as mustache;

final HTML = new ContentType('text', 'html', charset: 'charset=utf-8');
final MAIN_PAGE = mustache.parse('''
<html>
  <body>
    <head>
      <title>Greetings page.</title>
    </head>
  </body>
  <div>
    <h1>Greetings from db :) [user: {{user}}]</h1>
    {{#entries}}
      <div style="border: 1px solid gray; margin: 10px;">
        Author: {{author}}<br />
        Date: {{date}}<br />
        Message:<br />
        <pre>{{content}}</pre>
      </div>
    {{/entries}}
    <br /><br />
    <form method="POST">
       Author: <input name="author" type="text" /><br/>
       <textarea name="text" rows="5" cols="60"></textarea><br/>
       <input type="submit" value="Submit to Guestbook" />
    </form>
  </div>
</html>
''');

Map _convertGreeting(Greeting g) {
  return {'date' : g.date, 'author' : g.author, 'content' : g.content};
}

@ModelMetadata(const GreetingDesc())
class Greeting extends Model {
  String author;
  String content;
  DateTime date;
}

class GreetingDesc extends ModelDescription {
  final id = const IntProperty();
  final author = const StringProperty();
  final content = const StringProperty();
  final date = const DateTimeProperty();

  const GreetingDesc() : super('Greeting');
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
    return users.createLoginUrl('${request.uri}').then((String url) {
      logging.info('Redirecting user to login $url.');
      return request.response.redirect(Uri.parse(url));
    });
  }

  if (request.method == 'GET') {
    logging.info('Fetch greetings from datastore.');
    var query = db.query(Greeting, ancestorKey: rootKey)..order('-date');
    return query.run().then((List<Greeting> greetings) {
      var renderMap = {
        'entries' : greetings.map(_convertGreeting).toList(),
        'user' : users.currentUser.email,
      };
      logging.info('Sending list of greetings back.');
      return _sendResponse(request.response, MAIN_PAGE.renderString(renderMap));
    });
  } else {
    return request.transform(UTF8.decoder).join('').then((String formData) {
      var parms = Uri.splitQueryString(formData);
      var greeting = new Greeting()
          ..parentKey = rootKey
          ..author = parms['author'] + ' (${users.currentUser.email})'
          ..content  = parms['text']
          ..date = new DateTime.now();
      logging.info('Store greeting to datastore ...');
      return db.commit(inserts: [greeting]).then((_) {
        return request.response.redirect(request.uri);
      });
    });
  }
}

void _sendResponse(HttpResponse response, String message) {
  response
      ..headers.contentType = HTML
      ..headers.set("Cache-Control", "no-cache")
      ..statusCode = HttpStatus.OK
      ..add(UTF8.encode(message));

  return response.close();
}

void main() {
  runAppEngine(_serveMainPage).then((_) {
    // Server running.
  });
}
