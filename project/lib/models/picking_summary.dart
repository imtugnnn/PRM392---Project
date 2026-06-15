class PickingSummary {
  final String productId;
  final String productName;
  final String shelfLocation;
  final int totalQuantity;

  PickingSummary({
    required this.productId,
    required this.productName,
    required this.shelfLocation,
    required this.totalQuantity,
  });

  factory PickingSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    print(json);

    return PickingSummary(
      productId: json['ProductId'] ?? '',
      productName: json['ProductName'] ?? '',
      shelfLocation: json['ShelfLocation'] ?? '',
      totalQuantity:
          int.tryParse(
            json['TotalQuantity'].toString(),
          ) ??
          0,
    );
  }
}