// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library clientserver.model;

import 'dart:async';

import 'package:gcloud/db.dart';

@Kind()
class ItemsRoot extends Model {}

@Kind()
class Item extends Model {
  @StringProperty()
  String name;

  String validate() {
    if (name.isEmpty) return "Name cannot be empty";
    if (name.length < 3) return "Name cannot be short";

    return null;
  }

  Map serialize() => {'name': name};

  static Item deserialize(Map json) => new Item()..name = json['name'];
}

Key get itemsRoot => dbService.emptyKey.append(ItemsRoot, id: 1);

Future<List<Item>> queryItems() {
  
  final query = dbService.query<Item>(ancestorKey: itemsRoot)..order('name');
  return query.run().toList();
}
