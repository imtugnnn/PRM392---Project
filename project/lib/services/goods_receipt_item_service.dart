import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/goods_receipt_item.dart';

class GoodsReceiptItemService {
  static const String baseUrl =
      'https://s40lp1.ucc.cit.tum.de:8100/sap/opu/odata/sap/Z_DEV376__SU26_WMS_SRV';

  static const String username = 'DEV-376';
  static const String password = 'MDSAh1!h2@';

  String get basicAuth =>
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  Map<String, String> get headers => {
        'Authorization': basicAuth,
        'Accept': 'application/json',
      };

  /// ==========================
  /// GET ALL ITEM OF ONE GR
  /// ==========================
  Future<List<GoodsReceiptItem>> getByGrId(String grId) async {
        debugPrint(
      "$baseUrl/GoodsReceiptItemSet?\$filter=GrId eq '$grId'&\$format=json",
    );
    final response = await http.get(
      Uri.parse(
        "$baseUrl/GoodsReceiptItemSet?\$filter=GrId eq '$grId'&\$format=json",
      ),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);

    return (data['d']['results'] as List)
        .map((e) => GoodsReceiptItem.fromJson(e))
        .toList();
  }

  /// ==========================
  /// GET CSRF TOKEN
  /// ==========================
  Future<Map<String, String>> _getCsrfToken() async {
    final response = await http.get(
      Uri.parse('$baseUrl/GoodsReceiptItemSet'),
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

  /// ==========================
  /// NORMALIZE COOKIE
  /// ==========================
  String normalizeCookie(String rawCookie) {
    final cookies = rawCookie.split(',');

    final result = <String>[];

    for (final cookie in cookies) {
      result.add(cookie.split(';').first.trim());
    }

    return result.join('; ');
  }

  /// ==========================
  /// CREATE ITEM
  /// ==========================
  Future<void> create(GoodsReceiptItem item) async {
    // print(jsonEncode(item.toJson()));
    final csrf = await _getCsrfToken();

    final cookie = normalizeCookie(csrf['cookie']!);

    final response = await http.post(
      Uri.parse('$baseUrl/GoodsReceiptItemSet'),
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-csrf-token': csrf['token']!,
        'Cookie': cookie,
      },
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode != 201 &&
        response.statusCode != 200) {
      throw Exception(
        'Create Goods Receipt Item failed (${response.statusCode})\n'
        '${response.body}',
      );
    }
  }

  /// ==========================
  /// DELETE ITEM
  /// ==========================
  Future<void> delete(String grItemId) async {
    final csrf = await _getCsrfToken();

    final cookie = normalizeCookie(csrf['cookie']!);

    final response = await http.delete(
      Uri.parse(
        "$baseUrl/GoodsReceiptItemSet('$grItemId')",
      ),
      headers: {
        'Authorization': basicAuth,
        'Accept': 'application/json',
        'x-csrf-token': csrf['token']!,
        'Cookie': cookie,
      },
    );

    if (response.statusCode != 204 &&
        response.statusCode != 200) {
      throw Exception(
        'Delete Goods Receipt Item failed\n${response.body}',
      );
    }
  }

  /// ==========================
  /// UPDATE ITEM
  /// ==========================
  Future<void> update(GoodsReceiptItem item) async {
    final csrf = await _getCsrfToken();

    final cookie = normalizeCookie(csrf['cookie']!);

    final response = await http.put(
      Uri.parse(
        "$baseUrl/GoodsReceiptItemSet('${item.grItemId}')",
      ),
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-csrf-token': csrf['token']!,
        'Cookie': cookie,
      },
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode != 204 &&
        response.statusCode != 200) {
      throw Exception(
        'Update Goods Receipt Item failed\n${response.body}',
      );
    }
  }
}