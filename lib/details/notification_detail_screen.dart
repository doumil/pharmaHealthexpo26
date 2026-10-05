// lib/details/notification_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharma_health_expo/model/notification_model.dart';
import 'package:pharma_health_expo/providers/theme_provider.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotifClass notification;

  const NotificationDetailScreen({Key? key, required this.notification}) : super(key: key);

  // نفس دالة تنسيق وتنقيت التاريخ والوقت باش يكونوا متطابقين
  String _formatDateTime(String date, String dtime) {
    String rawDate = "$date $dtime";

    try {
      final parsedDate = DateTime.tryParse(date) ?? DateTime.tryParse(dtime);
      if (parsedDate != null) {
        String twoDigits(int n) => n.toString().padLeft(2, '0');
        String day = twoDigits(parsedDate.day);
        String month = _getMonthName(parsedDate.month);
        String year = parsedDate.year.toString();
        String hour = twoDigits(parsedDate.hour);
        String minute = twoDigits(parsedDate.minute);

        if (parsedDate.hour == 0 && parsedDate.minute == 0) {
          return "$day $month $year";
        }
        return "$day $month $year, $hour:$minute";
      }
    } catch (_) {}

    rawDate = rawDate.replaceAll('T', ' ');
    rawDate = rawDate.replaceAll('Z', '');
    rawDate = rawDate.replaceAll(RegExp(r'\.\d+'), '');
    rawDate = rawDate.replaceAll(RegExp(r'\bat\b', caseSensitive: false), '');
    rawDate = rawDate.replaceAll(RegExp(r'\s+'), ' ').trim();

    return rawDate.isNotEmpty ? rawDate : "$date $dtime";
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final formattedDate = _formatDateTime(notification.date, notification.dtime);

    return Scaffold(
      backgroundColor: theme.whiteColor,
      appBar: AppBar(
        title: Text(
          notification.title.isNotEmpty ? notification.title : notification.name,
          style: TextStyle(color: theme.whiteColor, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        iconTheme: IconThemeData(color: theme.whiteColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان الرئيسي داخل الصفحة إذا أردت إبرازه
            Text(
              notification.title.isNotEmpty ? notification.title : notification.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // التاريخ والوقت بعد التنقية
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[300], thickness: 1),
            const SizedBox(height: 20),

            // الوصف أو تفاصيل الإشعار
            Text(
              notification.body.isNotEmpty ? notification.body : notification.discription,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}