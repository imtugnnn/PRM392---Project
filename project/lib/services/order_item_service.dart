import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/order_item.dart';

class OrderItemService {
  static const String baseUrl =
      'https://s40lp1.ucc.cit.tum.de/sap/opu/odata/SAP/Z_DEV376__SU26_WMS_SRV';

  static const String username = 'DEV-376';
  static const String password = 'MDSAh1!h2@';
  

  String get basicAuth =>
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  Future<void> createOrderItem(
    OrderItem item,
    
  ) async {
    final csrf = await _getCsrfToken();

    final body = jsonEncode(item.toJson());

    print('ORDER ITEM BODY:');
    print(body);

    final response =
        await http.post(
      Uri.parse(
        '$baseUrl/OrderItemSet',
      ),
      headers: {
        'Authorization': basicAuth,
        'Content-Type':
            'application/json',
        'Accept':
            'application/json',
        'x-csrf-token':
            csrf['token']!,
        'Cookie':
            normalizeCookie(
          csrf['cookie']!,
        ),
      },
      body: body,
    );

    if (response.statusCode != 201 &&
        response.statusCode != 200) {
      throw Exception(
        'Create order item failed: '
        '${response.body}',
      );
    }
  }

  Future<Map<String, String>> _getCsrfToken() async {
    final response = await http.get(
      Uri.parse('$baseUrl/OrderItemSet'),
      headers: {
        'Authorization': basicAuth,
        'X-CSRF-Token': 'Fetch',
      },
    );

    final token =
        response.headers['x-csrf-token'];

    final cookie =
        response.headers['set-cookie'];

    if (token == null || cookie == null) {
      throw Exception(
        'Cannot get CSRF token',
      );
    }

    return {
      'token': token,
      'cookie': cookie,
    };
  }

  String normalizeCookie(
    String rawCookie,
  ) {
    final cookies =
        rawCookie.split(',');

    final result = <String>[];

    for (final cookie in cookies) {
      result.add(
        cookie.split(';').first.trim(),
      );
    }

    return result.join('; ');
  }

  Future<List<OrderItem>> getByOrderId(
    String orderId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/OrderItemSet?\$filter=OrderId eq \'$orderId\'&\$format=json',
      ),
      headers: {
        'Authorization': basicAuth,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Load order items failed');
    }

    final data =
        jsonDecode(response.body)['d']['results'];

    final allItems = data
        .map<OrderItem>(
          (e) => OrderItem.fromJson(e),
        )
        .toList();

    return allItems.where(
      (e) => e.orderId == orderId,
    ).toList();
  }
}