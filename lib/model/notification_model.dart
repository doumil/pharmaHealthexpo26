class NotifClass {
  String name;
  String date;
  String dtime;
  String discription;

  NotifClass(this.name, this.date, this.dtime, this.discription);

  // You don't strictly need toMap/fromMap for this in-memory only version,
  // but keeping them is harmless if you used them before or plan to in the future.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date,
      'dtime': dtime,
      'discription': discription,
    };
  }

  factory NotifClass.fromMap(Map<String, dynamic> map) {
    return NotifClass(
      map['name'] as String,
      map['date'] as String,
      map['dtime'] as String,
      map['discription'] as String,
    );
  }
}