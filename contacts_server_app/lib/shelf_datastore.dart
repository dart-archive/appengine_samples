library shelf_datastore;

import 'dart:async';
import 'dart:convert';

import 'package:cloud_datastore/cloud_datastore.dart';
import 'package:appengine/appengine.dart' as ae;
import 'package:shelf/shelf.dart';

import 'json_mapper.dart';

Handler getApiHandler(Map<String, JsonMapper> dataTypes) {
  return (Request request) {
    var segments = request.url.pathSegments;

    if (segments.length == 1) {
      var typeSegment = segments.first;

      var type = dataTypes[typeSegment];
      if (type != null) {
        request = request.change(scriptName: '/$typeSegment');
        return _typeHandler(typeSegment, type, request);
      }
    }

    return _jsonNotFound();
  };
}

dynamic _typeHandler(String name, JsonMapper dataType, Request request) {
  List jsonEncodeModels(Iterable<Model> models) =>
      models.map(dataType.encode).toList();

  Future<List<Map>> getList() {
    var datastore = ae.context.services.db;
    return datastore.query(dataType.type).run().then(jsonEncodeModels);
  }

  Future<Model> decode(Request request) {
    return request.readAsString().then((str) {
      var json = JSON.decode(str);
      var object = dataType.decode(json);
      return object;
    });
  }

  Future create(Model model) {
    var datastore = ae.context.services.db;
    return datastore.commit(inserts: [model]);
  }

  var segments = request.url.pathSegments;

  if (segments.isEmpty) {
    if (request.method == 'GET') {
      return getList().then((items) {
        return {
          name: items
        };
      }).then(_jsonResponse);
    } else if (request.method == 'POST') {
      return decode(request).then((model) {
        return create(model).then((_) {
          var json = {
            name: [dataType.encode(model)]
          };
          return _jsonResponse(json, statusCode: 201);
        });
      });
    }
  }

  return _jsonNotFound();
}

Response _jsonResponse(Object data, {int statusCode: 200}) {
  var body = _JSON_ENCODER.convert(data);
  var headers = { 'Content-Type' : 'application/json' };
  return new Response(statusCode, body: body, headers: headers);
}

const _JSON_ENCODER = const JsonEncoder.withIndent('  ');

Response _jsonNotFound() => _jsonResponse('Not found', statusCode: 404);
