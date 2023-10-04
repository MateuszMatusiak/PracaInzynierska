class DictionaryEntry {
  final int id;
  final String entry;
  final String description;
  final String creationTime;

  DictionaryEntry(this.id, this.entry, this.description, this.creationTime);

  DictionaryEntry.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        entry = json['entry'],
        description = json['description'],
        creationTime = json['creationTime'];

}
