import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/picking_summary.dart';

class PickingSummaryService {
  static const String baseUrl =
      'https://s40lp1.ucc.cit.tum.de/sap/opu/odata/SAP/Z_DEV376__SU26_WMS_SRV';

  static const String username = 'DEV-376';
  static const String password = 'MDSAh1!h2@';

  String get basicAuth =>
      'Basic ${base64Encode(
        utf8.encode('$username:$password'),
      )}';

  Future<List<PickingSummary>> getSummary() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/PickingSummarySet?\$format=json',
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': basicAuth,
      },
    );

    print(response.body);

    final data = jsonDecode(response.body);

    print(data['d']['results']);

    return (data['d']['results'] as List)
        .map((e) => PickingSummary.fromJson(e))
        .toList();
  }
}