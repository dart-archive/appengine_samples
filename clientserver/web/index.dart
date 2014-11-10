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

void main() {
  querySelector("#create")
      ..onClick.listen(onCreate);

  restGet('/items').then((result) {
    result.forEach((json) => addItem(Item.deserialize(json)));
  });
}

void addItem(Item item) {
  var cell = new TableCellElement()
      ..text = item.name;
  var row = new TableRowElement()
      ..children.add(cell);
  itemsTable.children.add(row);
}

void onCreate(MouseEvent event) {
  var item = new Item()..name = nameInput.value;
  var error = item.validate();
  if (error != null) {
    window.alert(error);
  } else {
    restPost('/items', item.serialize()).then((result) {
      if (!result['success']) {
        errorMessage.text = 'Server error: ${result['error']}';
      } else {
        errorMessage.text = '';
        addItem(item);
      }
    });
  }
}

Future restGet(String path) {
  return HttpRequest.getString(path).then((response) {
    var json = JSON.decode(response);
    if (json['success']) {
      errorMessage.text = '';
      return json['result'];
    } else {
      errorMessage.text = 'Server error: ${json['error']}';
    }
  });
}

Future restPost(String path, json) {
  return HttpRequest.request(path, method: 'POST', sendData: JSON.encode(json))
      .then((HttpRequest request) {
        return JSON.decode(request.response);
      });
}
