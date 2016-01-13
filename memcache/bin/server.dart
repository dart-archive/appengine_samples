// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:appengine/appengine.dart';
import 'package:mustache/mustache.dart' as mustache;

final _MAIN_PAGE = mustache.parse("""
<html>
  <head>
    <title>Main page</title>
    <style>
      div {
        padding: 24px;
      }
    </style>
    <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.0/css/bootstrap.min.css">
</head>
  </head>
  <body>
    <div>
      <form name="input" method="get">
        <input type="text" name="user">
        <input type="submit" value="Create user">
      </form>
      <form name="input" action='/clear' method="get">
        <input type="submit" value="Clear all users">
      </form>

      <h2>Users:</h2>
      <ul>
        {{#users}}
          <li>{{user}}</li>
        {{/users}}
      </ul>
    </div>
  </body>
</html>
""");

Future _sendResponse(HttpResponse response, int statusCode, String message) {
  var data = UTF8.encode(message);
  response
      ..headers.contentType = new ContentType('text', 'html', charset: 'utf-8')
      ..headers.set("Cache-Control", "no-cache")
      ..statusCode = statusCode
      ..contentLength = data.length
      ..add(data);
  return response.close();
}

void _serveMustache(HttpRequest request) {
  var logging = context.services.logging;
  var memcache = context.services.memcache;
  var users = [];

  memcache.get('users').then((encodedUsers) {
    if (encodedUsers == null) return;
    try {
      users = JSON.decode(encodedUsers);
    } catch (err) {
      logging.error("Error when decoding '$encodedUsers':\n$err");
    }
  }).then((_) {
    if (request.uri.path == '/clear') {
      return memcache.remove('users').then((_) {
        // redirect back to the root of the application
        return request.response.redirect(new Uri(path: '/'));
      });
    }

    var newUser = request.uri.queryParameters['user'];

    if (newUser != null && newUser.trim().isNotEmpty) {
      users.add({'user': newUser});

      // add the new value to memcache
      return memcache.set('users', JSON.encode(users)).then((_) {
        // redirect back to the root of the application
        return request.response.redirect(new Uri(path: '/'));
      });
    } else {
      var body = _MAIN_PAGE.renderString({'users': users});
      return _sendResponse(request.response, HttpStatus.OK, body);
    }
  });
}

main(List<String> args) {
  int port = 8080;
  if (args.length > 0) port = int.parse(args[0]);
  runAppEngine(_serveMustache, port: port);
}
