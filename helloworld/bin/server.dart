// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:appengine/appengine.dart';

main(List<String> args) {
  int port = 8080;
  if (args.length > 0) port = int.parse(args[0]);

  runAppEngine((HttpRequest request) {
    request.response..write('Hello, world!')
                    ..close();
  }, port: port);
}
