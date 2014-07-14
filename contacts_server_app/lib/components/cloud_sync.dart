library contacts_server.cloud_sync;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:io_2014_contacts_demo/src/contact.dart';
import 'package:io_2014_contacts_demo/src/sync.dart';
import 'package:contacts_server/data_store_contact.dart';
import 'package:polymer/polymer.dart';

const _JSON_ENCODER = const JsonEncoder.withIndent('  ');
const _CONTACTS_API_PATH = '/api/contacts';
const _CONTENT_TYPE = 'application/json';

@CustomTag('cloud-sync')
class CloudSync extends PolymerElement implements Sync {
  final List<Contact> _cache = new List<Contact>();

  CloudSync.created() : super.created();

  Future<List<Contact>> load() {
    return _getJson(_CONTACTS_API_PATH).then((json) {
      var jContacts = json['contacts'] as List;
      var contacts = jContacts.map((j) => new DSContact.fromJson(j)).toList();
      return contacts;
    });
  }

  Future<Contact> add(Contact contact) {
    assert(contact.id == null);
    var json = contact.toJson();
    return _postJson(_CONTACTS_API_PATH, json).then((json) {
      return new Contact.fromJson(json);
    });
  }

  Future<bool> delete(Contact contact) {
    throw 'not impld';
  }
}

Future<Object> _postJson(String path, Object obj, {String method}) {
  if (method == null) method = 'POST';
  var body = JSON.encode(obj);

  var headers = { 'Content-Type': _CONTENT_TYPE };

  return HttpRequest.request(path, method: 'POST', requestHeaders: headers,
      sendData: body).then((request) {

    var jsonObj = JSON.decode(request.responseText);
    return jsonObj;
  });
}

Future _getJson(String path) {
  return HttpRequest.getString(path).then((content) {
    return JSON.decode(content);
  });
}
