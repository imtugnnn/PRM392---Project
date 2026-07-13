class GoodsReceipt {
  final String grId;
  final String grDate;
  final String status;
  final String remark;

  GoodsReceipt({
    required this.grId,
    required this.grDate,
    required this.status,
    required this.remark,
  });

  factory GoodsReceipt.fromJson(Map<String, dynamic> json) {
    return GoodsReceipt(
      grId: json['GrId'] ?? '',
      grDate: json['GrDate'] ?? '',
      status: json['Status'] ?? '',
      remark: json['Remark'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'GrId': grId,
      'GrDate': grDate,
      'Status': status,
      'Remark': remark,
    };
  }

  GoodsReceipt copyWith({
    String? grId,
    String? grDate,
    String? status,
    String? remark,
  }) {
    return GoodsReceipt(
      grId: grId ?? this.grId,
      grDate: grDate ?? this.grDate,
      status: status ?? this.status,
      remark: remark ?? this.remark,
    );
  }
}