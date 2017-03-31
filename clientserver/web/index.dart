// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:clientserver/model.dart';

final nameInput = querySelector("#name");
final itemsTable = querySelector("#items");
final errorMessage = querySelector("#error_text");

main() async {
  querySelector("#create")..onClick.listen(onCreate);

  final result = await restGet('/items');
  result.forEach((json) => addItem(Item.deserialize(json)));
}

void addItem(Item item) {
  final cell = new TableCellElement()..text = item.name;
  final row = new TableRowElement()..children.add(cell);
  itemsTable.children.add(row);
}

onCreate(MouseEvent event) async {
  final item = new Item()..name = nameInput.value;
  final error = item.validate();
  if (error != null) {
    window.alert(error);
  } else {
    final result = await restPost('/items', item.serialize());
    if (!result['success']) {
      errorMessage.text = 'Server error: ${result['error']}';
    } else {
      errorMessage.text = '';
      addItem(item);
    }
  }
}

Future restGet(String path) async {
  final response = await HttpRequest.getString(path);
  final json = JSON.decode(response);
  if (json['success']) {
    errorMessage.text = '';
    return json['result'];
  } else {
    errorMessage.text = 'Server error: ${json['error']}';
  }
}

Future restPost(String path, json) async {
  final HttpRequest request = await HttpRequest.request(path,
      method: 'POST', sendData: JSON.encode(json));
  return JSON.decode(request.response);
}
