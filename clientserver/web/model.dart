library model;

import 'package:gcloud/db.dart';

@Kind()
class ItemsRoot extends Model { }

@Kind()
class Item extends Model {
  @StringProperty()
  String name;

  validate() {
    if (name.length == 0) return "Name cannot be empty";
    if (name.length < 3) return "Name cannot be short";
  }

  Map serialize() => {'name': name};
  static Item deserialize(json) => new Item()..name = json['name'];
}
