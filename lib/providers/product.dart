import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    // isFavorite = oldStatus; //rollback if fail
    isFavorite = newValue;
    notifyListeners();
  }

//Proper Optimistic Update
  Future<void> toggleFavoriteStatus(String authToken, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    // final url = Uri.parse(
    //     'https://flutterchat-bee3f-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken');
    final url = Uri.parse(
        'https://flutterchat-bee3f-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$authToken');
    try {
      //now put request to override
      final response = await http.put(
        url,
        //send jes d value  not with curly braces or isfavorit:true
        body: json.encode(isFavorite
            //'isFavorite': isFavorite,
            ),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
      // isFavorite = oldStatus; //rollback if fail
      // notifyListeners();
    }
  }
}
