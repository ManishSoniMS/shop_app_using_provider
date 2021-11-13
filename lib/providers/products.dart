import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import '../providers/product_model.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  String? _authToken;
  String? userId;

  static const String baseURL =
      "https://shop-app-using-provider-default-rtdb.firebaseio.com/";

  void update(token, userId, item) {
    _authToken = token;
    userId = userId;
    _items = item;
    notifyListeners();
  }

  List<Product> get items => [..._items];

  List<Product> get favouriteItems {
    return _items.where((productItems) => productItems.isFavourite).toList();
  }

  Future<void> fetchAndSetData([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? "orderBy='creatorID'&equalTo='$userId'" : "";
    final url =
        Uri.parse("$baseURL/products.json?auth=$_authToken&$filterString");
    final favUrl = Uri.parse("$baseURL/userFav/$userId.json?auth=$_authToken");
    try {
      http.Response response = await http.get(url);
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      if (extractedData.isEmpty) {
        return;
      }
      http.Response favResponse = await http.get(favUrl);
      final favData = jsonDecode(favResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData["title"],
          description: prodData["description"],
          imageUrl: prodData["imageUrl"],
          price: prodData["price"],
          isFavourite: favData == null ? false : favData[prodId] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Product findById(String id) {
    return _items.firstWhere(
      (product) => product.id == id,
    );
  }

  /// JSON: JavaScript Object Notation
  /// .json is required only in case of firebase realtime database after URL
  Future<void> addProduct(Product product) async {
    final url = Uri.parse("$baseURL/products.json?auth=$_authToken");
    try {
      http.Response response = await http.post(
        url,
        body: jsonEncode({
          "title": product.title,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
          "creatorID": userId,
        }),
      );
      final newProduct = Product(
        id: jsonDecode(response.body)["name"],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); /// at the start of the list
      /// setState((){}); of Provider
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final url = Uri.parse("$baseURL/products/$id.json?auth=$_authToken");
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      await http.patch(url,
          body: jsonEncode({
            "title": newProduct.title,
            "description": newProduct.description,
            "price": newProduct.price,
            "imageUrl": newProduct.imageUrl,
            "creatorID": userId,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print("...");
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse("$baseURL/products/$id.json?auth=$_authToken");

    /// approach 1 : progressive approach
    final existingProductIndex = _items.indexWhere((prodID) => prodID.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Couldn't delete product.");
    }
    existingProduct.dispose();

    /// approach 2 : simple approach
    // http.delete(url);
    // _items.removeWhere((prod) => prod.id == id);
  }
}
