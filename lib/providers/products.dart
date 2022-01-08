import 'dart:convert'; //convert data into JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_execption.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  // Product(
  //   id: 'p1',
  //   title: 'Red Shirt',
  //   description: 'A red shirt - it is pretty red!',
  //   price: 29.99,
  //   imageUrl:
  //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  // ),
  // Product(
  //   id: 'p2',
  //   title: 'Trousers',
  //   description: 'A nice pair of trousers.',
  //   price: 59.99,
  //   imageUrl:
  //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
  // ),
  // Product(
  //   id: 'p3',
  //   title: 'Yellow Scarf',
  //   description: 'Warm and cozy - exactly what you need for the winter.',
  //   price: 19.99,
  //   imageUrl:
  //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
  // ),
  // Product(
  //   id: 'p4',
  //   title: 'A Pan',
  //   description: 'Prepare any meal you want.',
  //   price: 49.99,
  //   imageUrl:
  //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
  // ),
  //];
  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetsProducts() async {
    const url =
        'https://flutterchat-bee3f-default-rtdb.asia-southeast1.firebasedatabase.app/products.json';
    try {
      final response = await http.get(url);
      // print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        //adding product to ds list above👆🏻
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: prodData['isFavorite'],
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners(); //to update all places in my app dats
      //product overview
    } catch (error) {
      throw (error);
    }
  }

//makes d method automatically wrapped in future
  Future<void> addProduct(Product product) async {
    //sending HTTP request
    const url =
        'https://flutterchat-bee3f-default-rtdb.asia-southeast1.firebasedatabase.app/products.json';
    try {
      //no need return here n get rid of then catch
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
        }), //conver map 2 json
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct); //add to local list of products
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
    //this block will b skipped if error apen above
    // .then((response) {
    //run after d above complete

    //to see what's inside d response
    // print(json.decode(response.body));// output
    //{name: -MsthSSn6mVKIk3_S9U3}

    //with await, ds auto execute also wen d above is done
    // final newProduct = Product(
    //   title: product.title,
    //   description: product.description,
    //   price: product.price,
    //   imageUrl: product.imageUrl,
    //   id: json.decode(response.body)['name'],
    // );
    // _items.add(newProduct); //add to local list of products
    // // _items.insert(0, newProduct); // at the start of the list
    // notifyListeners();
    // return Future.value();
    //})
    // .catchError((error) {
    //   //print(error);
    //   throw error;
    // });
  }

//updating product, use try catch
  Future<void> updateProduct(String id, Product newProduct) async {
    final url =
        'https://flutterchat-bee3f-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json';
    //target a specific profuct
    await http.patch(url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'price': newProduct.price,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
          //isFavorite status !
        }));
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      _items[prodIndex] = newProduct; //update in local memory
      notifyListeners();
    } else {
      print('...');
    }
  }

//Utilizing Optimistic updating
  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutterchat-bee3f-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json';
    final existingProductIdex = _items.indexWhere(
        (prod) => prod.id == id); //givs us d product index we want to remove
    var existingProduct = _items[
        existingProductIdex]; //reference 2 dt product dts abt to be deleted, d item lives in d memory
    //Dart will clear it from memory if it finds no one who is
    //still interested in d data
    _items.removeAt(
        existingProductIdex); //will remove d item from the list not from d memory
    // await http.delete(url).then((response) {
    final response = await http.delete(url);

    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();

    if (response.statusCode >= 400) {
      _items.insert(existingProductIdex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    //print(response.statusCode);
    //if succeed, remove d obj in memory
    existingProduct = null;
    //delete product
// .catchError((_) {
//       _items.insert(existingProductIdex, existingProduct);
//       //this will Re-Insert d product to same index if it fails to delete
//       notifyListeners(); //after ROll BacK
//     });
  }
}
