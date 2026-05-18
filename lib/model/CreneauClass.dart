class CreneauClass {
  String datetimeStart;
  String datetimeEnd;


  CreneauClass(this.datetimeStart,this.datetimeEnd);
  factory CreneauClass.fromJson(dynamic json) {
    return CreneauClass(json['datetimeStart'] as String,json['datetimeEnd'] as String);
  }
  Map<String, dynamic> toMap() {
    return {
      'datetimeStart':datetimeStart,
      'datetimeEnd':datetimeEnd,

    };
  }
  @override
  String toString() {
    return ' start time : $datetimeStart, end time : $datetimeEnd';
  }
}
