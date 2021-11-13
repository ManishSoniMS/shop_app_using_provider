import '../providers/products.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({Key? key}) : super(key: key);

  static const String routeName = "/product-details";

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const ProductDetailsScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// fetching data from routes
    final productID = ModalRoute.of(context)!.settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productID);
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: deviceHeight * 0.4,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(height: deviceHeight * 0.02),
                Text(
                  "\$${loadedProduct.price.toStringAsFixed(2)}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: deviceHeight * 0.02),
                Container(
                  width: deviceWidth,
                  padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
                  child: Text(
                    loadedProduct.description,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
                SizedBox(height: deviceHeight * 2.02),
              ],
            ),
          ),
        ],
        // child: Column(
        //   children: [
        //     Container(
        //       height: deviceHeight * 0.4,
        //       width: deviceWidth,
        //       padding: EdgeInsets.all(deviceWidth * 0.05),
        //       child:
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
