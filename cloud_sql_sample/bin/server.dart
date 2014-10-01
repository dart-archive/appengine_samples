// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:appengine/appengine.dart';
import 'package:mustache/mustache.dart' as mustache;
import 'package:sqljocky/sqljocky.dart';

/// See the README.md file for instructions on how to run this sample
/// application.

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

Greeting _row2Greeting(Row row) {
  return new Greeting()
    ..id = row.id
    ..author = row.author
    ..content = row.content
    ..date = row.date;
}

Map _convertGreeting(Greeting g) {
  return {'date' : g.date, 'author' : g.author, 'content' : g.content};
}

class Greeting {
  int id;
  String author;
  String content;
  DateTime date;
}

void _serveMainPage(ConnectionPool pool, HttpRequest request) {
  var logging = context.services.logging;
  var users = context.services.users;

  if (users.currentUser == null) {
    users.createLoginUrl('${request.uri}').then((String url) {
      logging.info('Redirecting user to login $url.');
      return request.response.redirect(Uri.parse(url));
    });
    return;
  }

  if (request.method == 'GET') {
    logging.info('Fetch greetings from SQL server.');

    var sw = new Stopwatch()..start();
    pool.query('SELECT id, author, content, date '
               'FROM greetings '
               'ORDER BY date '
               'LIMIT 20'
        ).then((rows) => rows.toList()).then((List<Row> rows) {
      var renderMap = {
        'entries' : rows.map(_row2Greeting).map(_convertGreeting).toList(),
        'user' : users.currentUser.email,
      };
      logging.info('mysql: SELECT took ${sw.elapsed}');
      logging.info('Sending list of greetings back.');
      return _sendResponse(request.response, MAIN_PAGE.renderString(renderMap));
    });
  } else {
    request.transform(UTF8.decoder).join('').then((String formData) {
      var parms = Uri.splitQueryString(formData);
      var greeting = new Greeting()
          ..author = parms['author'] + ' (${users.currentUser.email})'
          ..content  = parms['text']
          ..date = new DateTime.now();
      logging.info('Store greeting to SQL server ...');

      var sw = new Stopwatch()..start();
      return pool.prepareExecute(
          'INSERT INTO greetings (author, content, date) VALUES (?, ?, ?)',
          [greeting.author, greeting.content, greeting.date]).then((_) {
        logging.info('mysql: INSERT took ${sw.elapsed}');
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
  var pool = new ConnectionPool(host: '<please-fill-in>',
                                port: 3306,
                                user: 'root',
                                password: '<please-fill-in>',
                                db: 'greetingsdb',
                                useSSL: true);
  runAppEngine((req) => _serveMainPage(pool, req)).then((_) {
    // Server running.
  });
}
