library contacts_server.data_store_contact;

import 'package:cloud_datastore/cloud_datastore.dart';
import 'package:io_2014_contacts_demo/src/contact.dart';
import 'json_mapper.dart';

final contactJsonMapper = new JsonMapper<DSContact>(
    (DSContact c) => c.toJson(),
    (Map json) => new DSContact.fromJson(json));

@ModelMetadata(const ContactDesc())
class DSContact extends Contact with Model {
  DSContact() : super ('', '', false, null);

  DSContact.withValues(String name, String notes, bool important, int id)
      : super(name, notes, important, id);

  factory DSContact.fromJson(Map json) => new DSContact.withValues(json['name'],
      json['notes'], json['important'], json['id']);
}

class ContactDesc extends ModelDescription {
  final id = const IntProperty();
  final name = const StringProperty();
  final notes = const StringProperty();
  final important = const BoolProperty();

  const ContactDesc() : super('Contact');
}
