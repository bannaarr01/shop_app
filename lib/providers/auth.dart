import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Auth with ChangeNotifier {
//ds token expires at some point in time, that's d security mechanism
//for firebase generated token, expires after one hour
  String _token;
  DateTime _expiryDate;
  String _userId;

  Future<void> signup(String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyB76FnEfWVzAkSJIK4XRErtUhp9SL2Vn1g');
    final response = await http.post(url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ));
    print(json.decode(response.body));
  }
}
