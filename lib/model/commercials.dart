class Comercials {
  String fname;
  String lname;
  String definition;
  String characteristic;
  String image;



  Comercials(this.fname, this.lname,this.definition, this.characteristic,this.image);
  factory Comercials.fromJson(dynamic json) {
    return Comercials(json['fname'] as String, json['lname'] as String,
      json['definition'] as String, json['characteristic'] as String,json['image'] as String,);
  }
  Map<String, dynamic> toMap() {
    return {
      'fname': fname,
      'lname': lname,
      'definition': definition,
      'characteristic': characteristic,
      'image':image,
    };
  }
  @override
  String toString() {
    return 'firstname : $lname,lastname : $fname,definition : $definition,characteristic : $characteristic,image : $image';
  }
}
