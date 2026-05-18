class CongressDClass {
  String title;
  String discription;
  String datetimeStart;
  String datetimeEnd;


  CongressDClass(this.title,this.discription,this.datetimeStart,this.datetimeEnd);
  factory CongressDClass.fromJson(dynamic json) {
    return CongressDClass(json['title'] as String, json['discription'] as String,
        json['datetimeStart'] as String,json['datetimeEnd'] as String);
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'discription':discription,
      'datetimeStart':datetimeStart,
      'datetimeEnd':datetimeEnd,

    };
  }
  @override
  String toString() {
    return 'title : $title,discription : $discription, start time : $datetimeStart, end time : $datetimeEnd';
  }
}
