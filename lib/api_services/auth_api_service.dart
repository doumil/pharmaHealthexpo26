// lib/services/auth_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharma_health_expo/model/user_model.dart';
import '../global/app_config.dart';

class AuthApiService {
  static final String _baseUrl = "${AppConfig.baseUrl}/api";
  static final String _editionId = AppConfig.editionId;
  static final String _apiKey = AppConfig.apiKey;

  // -------------------------------------------------------------------------
  // STEP 1: Send Verification Code to Gmail
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    final Uri uri = Uri.parse('$_baseUrl/event/edition/$_editionId/sendVerificationCode/AppMobile');

    try {
      print('DEBUG: Step 1 Request to: $uri');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Api-Key': _apiKey,
        },
        body: jsonEncode({'email': email}),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Code sent successfully.',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to send code.',
        };
      }
    } catch (e) {
      print('DEBUG: Step 1 Exception: $e');
      return {'success': false, 'message': 'Network error in Step 1.'};
    }
  }

  // -------------------------------------------------------------------------
  // STEP 2: Verify Code -> Optimized for Form-Data (Postman Match)
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    final Uri uri = Uri.parse('$_baseUrl/verifyVerificationCode/AppMobile');

    try {
      print('DEBUG: Step 2 Request to: $uri (Using Multipart/form-data for Pharma)');

      // 🟩 إرسال البيانات كـ form-data باش السيرفر يقبلها 100% بحال Postman
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'X-Api-Key': _apiKey,
      });

      request.fields['email'] = email;
      request.fields['verification_code'] = code;
      request.fields['editionId'] = _editionId; // مبعوثة كـ String ف الـ fields د الـ form-data

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('DEBUG: Step 2 Status Code: ${response.statusCode}');
      print('DEBUG: Step 2 Response Body: ${response.body}');

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {

        // 🍎 1. الـ حالة الخاصّة بالـ Review (إيلا كان الإيميل د أبل أو الـ Token كيبدا بـ eyJ)
        String? directToken = responseData['token'];
        if (email.trim().toLowerCase() == "review@buzzevents.app" || (directToken != null && directToken.startsWith('eyJ'))) {
          print("DEBUG: Apple Review Flow Detected. Processing directly.");
          return await _handleAppleReviewLogin(responseData);
        }

        // 🔄 2. السيستيم القديم (Standard Path) للـ Users لخرين
        String smallToken = (responseData['user'] != null) ? responseData['user']['token'] : "";
        String qrCodeXml = responseData['order'] != null ? responseData['order']['qrcode'] ?? "" : "";

        print("DEBUG: Step 2 Success. Standard Path.");
        return await _getFinalFullToken(smallToken, responseData['user'], qrCodeXml);
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Invalid code.',
        };
      }
    } catch (e) {
      print('DEBUG: Step 2 Exception: $e');
      return {'success': false, 'message': 'Verification failed (Step 2). Error: $e'};
    }
  }

  // -------------------------------------------------------------------------
  // STEP 3: Exchange Small Token for Full Token (Standard Path)
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> _getFinalFullToken(String smallToken, Map<String, dynamic> userMap, String qrCode) async {
    final String encodedToken = Uri.encodeComponent(smallToken.trim());
    final String url = '${AppConfig.baseUrl}/api/login/link?tokenus=$encodedToken';
    final Uri uri = Uri.parse(url);

    try {
      print("DEBUG: Requesting Step 3 (GET) -> $url");
      final response = await http.get(uri, headers: {'Accept': 'application/json', 'X-Api-Key': _apiKey});

      if (response.statusCode == 200) {
        final Map<String, dynamic> linkData = json.decode(response.body);
        if (linkData.containsKey('token')) {
          String fullJwtToken = linkData['token'];
          userMap['token'] = fullJwtToken;

          final User user = User.fromJson(userMap);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', fullJwtToken);
          await prefs.setString('currentUserJson', jsonEncode(userMap));
          await prefs.setString('qrCodeXml', qrCode);

          return {'success': true, 'user': user, 'token': fullJwtToken};
        }
      }
      return {'success': false, 'message': 'Full token exchange failed.'};
    } catch (e) {
      print("DEBUG: Step 3 Exception: $e");
      return {'success': false, 'message': 'Connection error in final step.'};
    }
  }

  // -------------------------------------------------------------------------
  // STEP 4: Handle Apple Review Data Directly (No remote call)
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> _handleAppleReviewLogin(Map<String, dynamic> responseData) async {
    try {
      String appleToken = responseData['token'] ?? "apple-review-token";
      Map<String, dynamic> userMap = responseData['user'];

      userMap['token'] = appleToken;
      final User user = User.fromJson(userMap);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', appleToken);
      await prefs.setString('currentUserJson', jsonEncode(userMap));
      await prefs.setString('qrCodeXml', "");

      return {
        'success': true,
        'user': user,
        'token': appleToken,
      };
    } catch (e) {
      print("DEBUG: Error in Step 4: $e");
      return {'success': false, 'message': 'Local data processing failed.'};
    }
  }

  Future<Map<String, dynamic>> forgetPassword(String email) async {
    return await sendVerificationCode(email);
  }
}