// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:appengine/appengine.dart';
import 'package:mustache/mustache.dart' as mustache;

void main() {
  runAppEngine(_serveMustache);
}

Future _serveMustache(HttpRequest request) async {
  final logging = context.services.logging;
  final memcache = context.services.memcache;
  var users = [];

  final encodedUsers = await memcache.get('users');
  if (encodedUsers != null) {
    try {
      users = JSON.decode(encodedUsers);
    } catch (err) {
      logging.error("Error when decoding '$encodedUsers':\n$err");
    }
  }

  if (request.uri.path == '/clear') {
    await memcache.remove('users');

    // Redirect back to the root of the application
    request.response.redirect(new Uri(path: '/'));
    return;
  }

  final newUser = request.uri.queryParameters['user'];

  if (newUser != null && newUser.trim().isNotEmpty) {
    users.add({'user': newUser});

    // Add the new value to memcache
    await memcache.set('users', JSON.encode(users));

    // Redirect back to the root of the application
    await request.response.redirect(new Uri(path: '/'));
  } else {
    final body = _MAIN_PAGE.renderString({'users': users});
    await _sendResponse(request.response, HttpStatus.OK, body);
  }
}

Future _sendResponse(HttpResponse response, int statusCode, String message) {
  final data = UTF8.encode(message);
  response
    ..headers.contentType = ContentType.HTML
    ..headers.set("Cache-Control", "no-cache")
    ..statusCode = statusCode
    ..contentLength = data.length
    ..add(data);
  return response.close();
}

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
