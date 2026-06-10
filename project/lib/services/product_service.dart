import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductService {
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

  Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ProductSet?\$format=json'),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    return (data['d']['results'] as List)
        .map((e) => Product.fromJson(e))
        .toList();
  }

  Future<Map<String, String>> _getCsrfToken() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ProductSet'),
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

  Future<void> createProduct(Product product) async {
    final csrf = await _getCsrfToken();

    final cookie = normalizeCookie(csrf['cookie']!);

    final response = await http.post(
      Uri.parse('$baseUrl/ProductSet'),
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
        'Accept': 'application/json',

        'x-csrf-token': csrf['token']!,

        'Cookie': cookie,
      },
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode != 201 &&
        response.statusCode != 200) {
      throw Exception(
        'Create product failed (${response.statusCode})',
      );
    }
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