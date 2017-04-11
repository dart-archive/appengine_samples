library okoboji.json_mapper;

import 'package:cloud_datastore/cloud_datastore.dart';

class JsonMapper<T extends Model> {
  Type get type => T;
  final _ConvertFunc<T, Map<String, dynamic>> _encoder;
  final _ConvertFunc<Map<String, dynamic>, T> _decoder;

  JsonMapper(Map<String, dynamic> encoder(T source),
      T decoder(Map<String, dynamic> source))
      : _encoder = encoder,
        _decoder = decoder;

  Map<String, dynamic> encode(T source) => _encoder(source);

  T decode(Map<String, dynamic> source) => _decoder(source);
}

typedef T _ConvertFunc<S, T>(S source);
