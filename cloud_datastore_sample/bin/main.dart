// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:appengine/appengine.dart';
import 'package:cloud_datastore/cloud_datastore.dart';
import 'package:route/server.dart' show Router;
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

Map convertGreeting(Greeting g) {
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

serveMainPage(HttpRequest request) {
  var context = contextFromRequest(request);
  var db = context.services.db;
  var logging = context.services.logging;

  logging.debug('Got request ${request.uri} .');
  var users = context.services.users;

  if (users.currentUser == null) {
    return users.createLoginUrl('${request.uri}').then((String url) {
      logging.info('Redirecting user to login $url !');
      return request.response.redirect(Uri.parse(url));
    });
  }

  Future saveGreeting(Greeting greeting) {
    logging.info('Store greeting to datastore..');
    return db.commit(inserts: [greeting]);
  }

  Future<List<Greeting>> queryEntries() {
    logging.info('Fetch greetings from datastore.');
    return (db.query(Greeting)..order('date')).run();
  }

  Future showGreetingList() {
    return queryEntries().then((List<Greeting> greetings) {
      var renderMap = {
        'entries' : greetings.map(convertGreeting).toList(),
        'user' : users.currentUser.email,
      };
      logging.info('Sending list of greetings back.');
      return sendResponse(request.response, MAIN_PAGE.renderString(renderMap));
    });
  }

  if (request.method == 'GET') {
    return showGreetingList();
  } else {
    return request.transform(UTF8.decoder).fold('', (a,b) => '$a$b').then((c) {
      var parms = Uri.splitQueryString(c);
      var greeting = new Greeting()
          ..parentKey = db.emptyKey
          ..author = parms['author'] + ' (${users.currentUser.email})'
          ..content  = parms['text']
          ..date = new DateTime.now();
      return saveGreeting(greeting).then((_) => showGreetingList());
    });
  }
}

sendResponse(HttpResponse response, String message) {
  return (response
      ..headers.contentType = HTML
      ..headers.set("Cache-Control", "no-cache")
      ..statusCode = HttpStatus.OK
      ..add(UTF8.encode(message)))
      .close();
}

main() {
  runAppEngine().then((Stream<HttpRequest> requestStream) {
    var router = new Router(requestStream)
      ..defaultStream.listen(serveMainPage);
  });
}
