import '../providers/products.dart';
import '../widgets/product_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductGrid extends StatelessWidget {
  final bool showFavourites;
  ProductGrid(this.showFavourites);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products =
        showFavourites ? productsData.favouriteItems : productsData.items;
    final deviceWidth = MediaQuery.of(context).size.width;
    return GridView.builder(
      padding: EdgeInsets.all(deviceWidth * 0.04),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ChangeNotifierProvider.value(
          /// Initializing the Provider
          /// alternate 1 ChangeNotifierProvider()
          // create: (BuildContext context) => products[index],
          /// alternate 2 ChangeNotifierProvider.value() ⭐ preferred
          value: products[index],
          child: ProductItem(),
        );
      },
    );
  }
}
