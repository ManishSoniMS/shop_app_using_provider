import 'dart:convert';
import '../providers/cart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  String? _userID;
  String? _authToken;

  update(token, userID, orders) {
    _authToken = token;
    _userID = userID;
    _orders = orders;
    notifyListeners();
  }

  static const String baseURL =
      "https://shop-app-using-provider-default-rtdb.firebaseio.com/";

  Future<void> fetchAndSetOrder() async {
    final url = Uri.parse("$baseURL/orders/$_userID.json?auth=$_authToken");
    final response = await http.get(url);
    final extractedDate = jsonDecode(response.body) as Map<String, dynamic>;
    if (extractedDate.isEmpty) {
      return;
    }
    final List<OrderItem> loadedOrders = [];
    extractedDate.forEach((orderID, orderData) {
      loadedOrders.add(OrderItem(
        id: orderID,
        amount: orderData["amount"],
        products: (orderData["products"] as List<dynamic>)
            .map((item) => CartItem(
                  id: item["id"],
                  title: item["title"],
                  quantity: item["quantity"],
                  price: item["price"],
                ))
            .toList(),
        dateTime: DateTime.parse(orderData["dateTime"]),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        "$baseURL/orders/$_userID.json?auth=$_authToken");
    final timeStamp = DateTime.now();
    final response = await http.post(
      url,
      body: jsonEncode({
        "amount": total,
        "dateTime": timeStamp.toIso8601String(),
        "products": cartProducts
            .map(
              (cartProd) => {
                "id": cartProd.id,
                "title": cartProd.title,
                "quantity": cartProd.quantity,
                "price": cartProd.price,
              },
            )
            .toList(),
      }),
    );

    /// .add adds value to the end of the list,
    /// where .insert adds at the beginning of the list
    _orders.insert(
      0,
      OrderItem(
        id: jsonDecode(response.body)["name"],
        amount: total,
        products: cartProducts,
        dateTime: timeStamp,
      ),
    );
    notifyListeners();
  }
}
