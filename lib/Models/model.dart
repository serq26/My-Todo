
enum TodoStatus { active, done }

class Todo {
  int id;
  String title;
  DateTime created;
  DateTime updated;
  int status;
  String category;
  int isImportant;

  Todo({this.id, this.title, this.created, this.updated, this.status,this.category,this.isImportant});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'created': created.toString(),
      'updated': updated.toString(),
      'status': status,
      'category': category,
      'isImportant': isImportant
    };
  }

  Map<String, dynamic> toMapAutoID() {
    return {
      'title': title,
      'created': created.toString(),
      'updated': updated.toString(),
      'status': TodoStatus.active.index,
      'category' : category,
      'isImportant': isImportant
    };
  }
}
