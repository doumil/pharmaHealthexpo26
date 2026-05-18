class ActivitiesClass {
  String name;
  String shortname;
  String discription;
  String datetime;




  ActivitiesClass(this.name, this.shortname,this.discription,this.datetime);
  factory ActivitiesClass.fromJson(dynamic json) {
    return ActivitiesClass(json['name'] as String, json['shortname'] as String,
        json['discription'] as String,json['datetime'] as String);
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'shortname': shortname,
      'discription':discription,
      'datetime':datetime,

    };
  }
  @override
  String toString() {
    return 'name : $name,short name : $shortname,discription : $discription, date time : $datetime';
  }
}
