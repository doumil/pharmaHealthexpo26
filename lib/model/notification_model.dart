// lib/model/notification_model.dart
class NotifClass {
  int? id;
  String name;      // سدّاً لأي توافقية قديمة (يأخد الـ title)
  String title;     // الحقل القادم من الـ API
  String body;      // الحقل القادم من الـ API
  String date;
  String dtime;
  String discription; // سدّاً لأي توافقية قديمة (يأخد الـ body)
  bool isRead;

  NotifClass({
    this.id,
    required this.name,
    required this.title,
    required this.body,
    required this.date,
    required this.dtime,
    required this.discription,
    this.isRead = false,
  });

  // تحويل الكلاس إلى Map لتخزينه في قاعدة البيانات
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': title, // نخزن الـ title في name احتياطاً
      'title': title,
      'body': body,
      'date': date,
      'dtime': dtime,
      'discriptions': body, // نخزن الـ body في discriptions احتياطاً
      'isRead': isRead ? 1 : 0,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // إنشاء كلاس من Map جاية من قاعدة البيانات أو الـ API JSON
  factory NotifClass.fromMap(Map<String, dynamic> map) {
    final extractedTitle = map['title'] ?? map['name'] ?? '';
    final extractedBody = map['body'] ?? map['discriptions'] ?? map['discription'] ?? '';

    return NotifClass(
      id: map['id'],
      name: extractedTitle,
      title: extractedTitle,
      body: extractedBody,
      date: map['created_at'] ?? map['date'] ?? '',
      dtime: map['dtime'] ?? '',
      discription: extractedBody,
      isRead: map['is_read'] == 1 || map['is_read'] == true || map['isRead'] == 1 || map['isRead'] == true,
    );
  }
}