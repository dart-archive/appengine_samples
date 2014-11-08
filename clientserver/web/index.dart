import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'model.dart';

var nameInput;
var itemsTable;
var errorMessage;

void main() {
  querySelector("#create")
      ..onClick.listen(onCreate);
  nameInput = querySelector("#name");
  itemsTable = querySelector("#items");
  errorMessage = querySelector("#error_text");

  restGet('/items').then((result) {
    result.forEach((json) => addItem(Item.deserialize(json)));
  });
}

void addItem(Item item) {
  var row = new TableRowElement();
  var cell = new TableCellElement();
  cell.text = item.name;
  row.children.add(cell);
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
