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
        'Authorization': basicAuth,
        'Accept': 'application/json',
      };

  Future<List<Order>> getOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/OrderSet?\$format=json'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Load orders failed (${response.statusCode})',
      );
    }

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
      throw Exception('Cannot fetch CSRF token');
    }

    return {
      'token': token,
      'cookie': cookie,
    };
  }

  String normalizeCookie(String rawCookie) {
    return rawCookie
        .split(',')
        .map((e) => e.split(';').first.trim())
        .join('; ');
  }

  Future<Order> createOrder(Order order) async {
    final csrf = await _getCsrfToken();

    final response = await http.post(
      Uri.parse('$baseUrl/OrderSet'),
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-CSRF-Token': csrf['token']!,
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
        'Create order failed (${response.statusCode})\n'
        '${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    return Order.fromJson(data['d']);
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
        'X-CSRF-Token': csrf['token']!,
        'Cookie': normalizeCookie(csrf['cookie']!),
      },
      body: jsonEncode({
        'OrderId': order.orderId,
        'Status': order.status,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Update order failed (${response.statusCode})\n'
        '${response.body}',
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
        'X-CSRF-Token': csrf['token']!,
        'Cookie': normalizeCookie(csrf['cookie']!),
      },
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Delete order failed (${response.statusCode})\n'
        '${response.body}',
      );
    }
  }
}