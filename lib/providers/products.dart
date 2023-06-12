import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
   
  ];
  String authToken;
  String userId;

  Products(this.authToken, this._items, this.userId);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favProducts {
    return _items.where((product) => product.isFavorite == true).toList();
  }

  Product findById(String productId) {
    return _items.firstWhere((product) => product.id == productId);
  }

  Future<void> addItem(Product product) async {
    final url = Uri.parse("https://shopapp-2daad-default-rtdb.firebaseio.com/shopapp/products/.json?auth=$authToken");

    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageurl': product.imageUrl,
            'creatorId': userId,
          }));

      final newProduct = Product(
          title: product.title,
          description: product.description,
          id: json.decode(response.body)['name'],
          imageUrl: product.imageUrl,
          price: product.price);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
     debugPrint(userId);
    debugPrint(authToken);
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        "https://shopapp-2daad-default-rtdb.firebaseio.com/shopapp/products.json?auth=$authToken&$filterString");

    final response = await http.get(url);
    if (response.body == 'null') {
      return;
    }
    final Map<String, dynamic> extractedData = json.decode(response.body);
    
   
    if (json.decode(response.body) == null) {
      return;
    }
     final List<Product> loadedProducts = [];

    url = Uri.parse(
        "https://shopapp-2daad-default-rtdb.firebaseio.com/shopapp/userFavorites/$userId.json?auth=$authToken");

    final favoriteResponse = await http.get(url);
    final favoriteData = json.decode(favoriteResponse.body);
    extractedData.forEach((prodId, prodData) {
      loadedProducts.add(Product(
        id: prodId,
        description: prodData['description'].toString(),
        imageUrl: prodData['imageurl'].toString(),
        price: prodData['price'] ?? 0.0,
        title: prodData['title'].toString(),
        isFavorite:
            favoriteData == null ? false : favoriteData[prodId] ?? false,
      ));
    });
    _items = loadedProducts;
    notifyListeners();
    // } catch (error) {
    //   rethrow;
    // }
  }

  Future<void> updateItem(String id, Product product) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == product.id);
    if (prodIndex >= 0) {
      final url = Uri.parse("https://shopapp-2daad-default-rtdb.firebaseio.com/shopapp/products/$id.json?auth=$authToken");

      await http.patch(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageurl': product.imageUrl,
          }));
      _items[prodIndex] = product;
    }

    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    final url = Uri.parse("https://shopapp-2daad-default-rtdb.firebaseio.com/shopapp/products/$id.json?auth=$authToken");
    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(
      url,
    );

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete Product.');
    }
    existingProduct = null;
  }
}
