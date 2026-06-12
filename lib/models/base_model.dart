abstract class BaseModel {
  int? id;

  void setId(int id) {
    this.id = id;
  }

  static BaseModel fromMap(Map<String, dynamic> map) => throw UnimplementedError();

  toMap() {}
}