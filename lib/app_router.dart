import 'package:flutter/material.dart';
import '/screen/screen.dart';


class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AuthScreen.routeName:
        return AuthScreen.route();

      case AddNewProductScreen.routeName:
        return AddNewProductScreen.route();

      case CartScreen.routeName:
        return CartScreen.route();

      case EditProductScreen.routeName:
        return EditProductScreen.route();

      case OrdersScreen.routeName:
        return OrdersScreen.route();

      case ProductDetailsScreen.routeName:
        return ProductDetailsScreen.route();

      case ProductsOverviewScreen.routeName:
        return ProductsOverviewScreen.route();

      case UserProductScreen.routeName:
        return UserProductScreen.route();

      default:
        return _errorRoute();
    }
  }

  static Route _errorRoute() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: "/error"),
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Error"),
          ),
          body: const Center(
            child: Text("Error"),
          ),
        );
      },
    );
  }
}
