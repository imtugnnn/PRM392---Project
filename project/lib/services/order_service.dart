import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/order.dart';

class OrderService {
  static const String baseUrl =
      'https://s40lp1.ucc.cit.tum.de/sap/opu/odata/SAP/Z_DEV376__SU26_WMS_SRV';

  static const String username = 'DEV-376';
  static const String password = 'MDSAh1!h2@';

  String get basicAuth =>
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  Map<String, String> get headers => {
        'Accept': 'application/json',
        'Authorization': basicAuth,
      };

  Future<List<Order>> getOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/OrderSet?\$format=json'),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    return (data['d']['results'] as List)
        .map((e) => Order.fromJson(e))
        .toList();
  }

  Future<Map<String, String>> _getCsrfToken() async {
    final response = await http.get(
      Uri.parse('$baseUrl/OrderSet'),
      headers: {
        'Authorization': basicAuth,
        'X-CSRF-Token': 'Fetch',
      },
    );

    final token = response.headers['x-csrf-token'];
    final cookie = response.headers['set-cookie'];

    if (token == null || cookie == null) {
      throw Exception('Cannot get CSRF token');
    }

    return {
      'token': token,
      'cookie': cookie,
    };
  }

  String normalizeCookie(String rawCookie) {
    final cookies = rawCookie.split(',');

    final result = <String>[];

    for (final cookie in cookies) {
      result.add(cookie.split(';').first.trim());
    }

    return result.join('; ');
  }

  Future<void> createOrder(Order order) async {
    final csrf = await _getCsrfToken();

    final response = await http.post(
      Uri.parse('$baseUrl/OrderSet'),
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-csrf-token': csrf['token']!,
        'Cookie': normalizeCookie(csrf['cookie']!),
      },
      body: jsonEncode({
        'OrderId': order.orderId,
        'Status': order.status,
      }),
    );

    if (response.statusCode != 201 &&
        response.statusCode != 200) {
      throw Exception(
        'Create order failed (${response.statusCode})',
      );
    }
  }

  Future<void> updateOrder(Order order) async {
    final csrf = await _getCsrfToken();

    final response = await http.put(
      Uri.parse(
        "$baseUrl/OrderSet('${order.orderId}')",
      ),
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-csrf-token': csrf['token']!,
        'Cookie': normalizeCookie(csrf['cookie']!),
      },
      body: jsonEncode({
        'OrderId': order.orderId,
        'Status': order.status,
      }),
    );

    if (response.statusCode != 204 &&
        response.statusCode != 200) {
      throw Exception(
        'Update order failed (${response.statusCode})',
      );
    }
  }

  Future<void> deleteOrder(String orderId) async {
    final csrf = await _getCsrfToken();

    final response = await http.delete(
      Uri.parse(
        "$baseUrl/OrderSet('$orderId')",
      ),
      headers: {
        'Authorization': basicAuth,
        'Accept': 'application/json',
        'x-csrf-token': csrf['token']!,
        'Cookie': normalizeCookie(csrf['cookie']!),
      },
    );

    if (response.statusCode != 204 &&
        response.statusCode != 200) {
      throw Exception(
        'Delete order failed (${response.statusCode})',
      );
    }
  }
}