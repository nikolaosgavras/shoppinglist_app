import 'package:shoppinglist_app/models/base_model.dart';

class Item extends BaseModel {
  late String _text;

  Item(this._text);

  Item.map(dynamic obj) {
    setId(obj["id"]);
    _text = obj["text"];
  }

  String get text => _text;

  @override
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map["text"] = _text;

    return map;
  }
}