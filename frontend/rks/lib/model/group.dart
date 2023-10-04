class Group {
  final int id;
  String name;

  Group(this.id, this.name);

  factory Group.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Group(-1, '');
    }
    int id = json['id'];
    String name = json['name'];
    return Group(id, name);
  }

  Group._json(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  bool exists() {
    return id != -1;
  }
}
