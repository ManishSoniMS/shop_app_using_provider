import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/providers.dart';
import '/screen/screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// option 1  Provider.of<T>(context)
    /// re-render whole widget, not a component
    /// if listen: true, build widget everytime if any change in data happen.
    /// if listen: false, build widget once when app is started
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailsScreen.routeName,
              arguments: product.id,
            );
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: const AssetImage("assets/images/snap.png"),
              image: NetworkImage(product.imageUrl),
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,

          /// option 2 Consumer<T>()
          /// re-render only wrapped widget
          //     Consumer<T>(
          //       builder: (context, <<reference name for T>>, child) {
          //         return Widget;
          //     });
          leading: Consumer<Product>(
            builder: (context, product, child) => IconButton(
              ///use of child:  when ever we want something which we don't want to change
              ///we use child property which takes Widget
              padding: EdgeInsets.zero,
              onPressed: () {
                product.toggleFavoriteStatus(auth.token, auth.userID);
              },

              /// referring the child widget, which not suppose to rebuilt everytime
              // icon: child,
              icon: Icon(
                product.isFavourite
                    ? Icons.favorite
                    : Icons.favorite_border_sharp,
                color: Theme.of(context).accentColor,
              ),
            ),

            /// creating child widget, immutable in nature
            // child: Icon(Icons.star),
          ),
          title: Text(
            product.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              cart.addItem(product.id, product.title, product.price);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Added item to cart!"),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: "Undo",
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    },
                  ),
                ),
              );
            },
            color: Theme.of(context).accentColor,
            icon: const Icon(Icons.shopping_cart),
          ),
        ),
      ),
    );
  }
}
