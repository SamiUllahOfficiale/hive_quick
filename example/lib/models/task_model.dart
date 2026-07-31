class TaskModel {
  String? id;
  String? title;
  bool? isCompleted;

  TaskModel({this.id, this.title, this.isCompleted});

  TaskModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    isCompleted = json['isCompleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['isCompleted'] = this.isCompleted;
    return data;
  }
}
