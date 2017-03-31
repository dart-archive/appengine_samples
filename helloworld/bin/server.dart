// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:appengine/appengine.dart';

main() async {
  await runAppEngine(requestHandler);
}

requestHandler(HttpRequest request) {
  request.response
    ..write('Hello, world!')
    ..close();
}
