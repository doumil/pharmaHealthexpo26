class NewsClass {
  String title;
  String discription;



  NewsClass(this.title, this.discription,);
  factory NewsClass.fromJson(dynamic json) {
    return NewsClass(json['title'] as String, json['discription'] as String);
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'discription': discription,
    };
  }
  @override
  String toString() {
    return 'title : $title,discription : $discription';
  }
}
