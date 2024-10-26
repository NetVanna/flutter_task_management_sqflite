class Tasks {
  int? id;
  String? title;
  int? isDone;
  String? date;

  Tasks({this.id, this.title, this.isDone, this.date});

  Tasks.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    isDone = json['isDone'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['isDone'] = isDone;
    data['date'] = date;
    return data;
  }
}
