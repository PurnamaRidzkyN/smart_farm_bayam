class InformationModel {
  final String id;
  final String title;
  final String content;

  InformationModel({required this.id, required this.title, required this.content});

  factory InformationModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return InformationModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
    };
  }

  InformationModel copyWith({String? title, String? content}) {
    return InformationModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

}
