import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/goods_receipt.dart';

class GoodsReceiptService {
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

  Future<List<GoodsReceipt>> getGoodsReceipts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/GoodsReceiptSet?\$format=json'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);

    return (data['d']['results'] as List)
        .map((e) => GoodsReceipt.fromJson(e))
        .toList();
  }

  Future<Map<String, String>> _getCsrfToken() async {
    final response = await http.get(
      Uri.parse('$baseUrl/GoodsReceiptSet'),
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

  Future<GoodsReceipt> createGoodsReceipt(
      GoodsReceipt goodsReceipt) async {
    final csrf = await _getCsrfToken();

    final cookie = normalizeCookie(csrf['cookie']!);

    final response = await http.post(
      Uri.parse('$baseUrl/GoodsReceiptSet'),
      headers: {
        'Authorization': basicAuth,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'x-csrf-token': csrf['token']!,
        'Cookie': cookie,
      },
      body: jsonEncode(goodsReceipt.toJson()),
    );

    if (response.statusCode != 201 &&
        response.statusCode != 200) {
      throw Exception(
        'Create Goods Receipt failed (${response.statusCode})\n'
        '${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    return GoodsReceipt.fromJson(data['d']);
  }

  Future<void> updateGoodsReceipt(
      GoodsReceipt goodsReceipt) async {
    final csrf = await _getCsrfToken();

    final cookie = normalizeCookie(csrf['cookie']!);
    print(jsonEncode(goodsReceipt.toJson()));
    final response = await http.put(
      Uri.parse(
          "$baseUrl/GoodsReceiptSet('${goodsReceipt.grId}')"),
      headers: {
        'Authorization': basicAuth,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'x-csrf-token': csrf['token']!,
        'Cookie': cookie,
      },
      body: jsonEncode(goodsReceipt.toJson()),
    );

    if (response.statusCode != 204 &&
        response.statusCode != 200) {
      throw Exception(
        'Update Goods Receipt failed (${response.statusCode})\n'
        '${response.body}',
      );
    }
  }

  Future<GoodsReceipt?> getGoodsReceiptById(
      String grId) async {
    final response = await http.get(
      Uri.parse(
          "$baseUrl/GoodsReceiptSet('$grId')?\$format=json"),
      headers: headers,
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);

    return GoodsReceipt.fromJson(data['d']);
  }

  String normalizeCookie(String rawCookie) {
    final cookies = rawCookie.split(',');

    final result = <String>[];

    for (final cookie in cookies) {
      result.add(cookie.split(';').first.trim());
    }

    return result.join('; ');
  }
}