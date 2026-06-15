import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductSearchDelegate extends SearchDelegate<Product?> {
  final List<Product> products;

  ProductSearchDelegate(this.products);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() {
    final filtered = products.where((p) {
      return p.productName
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final product = filtered[index];

        return ListTile(
          title: Text(product.productName),
          subtitle: Text(
            '${product.price.toStringAsFixed(2)}',
          ),
          onTap: () {
            close(context, product);
          },
        );
      },
    );
  }
}