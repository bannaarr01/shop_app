import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shop_app/models/http_execption.dart';

class Auth with ChangeNotifier {
//ds token expires at some point in time, that's d security mechanism
//for firebase generated token, expires after one hour
  String _token;
  DateTime _expiryDate;
  String _userId;

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyB76FnEfWVzAkSJIK4XRErtUhp9SL2Vn1g');
    try {
      final response = await http.post(url,
          body: json.encode(
            {
              'email': email,
              'password': password,
              'returnSecureToken': true,
            },
          ));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      throw error;
    }
    //print(json.decode(response.body));
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
    // final url = Uri.parse(
    //     'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyB76FnEfWVzAkSJIK4XRErtUhp9SL2Vn1g');
    // final response = await http.post(url,
    //     body: json.encode(
    //       {
    //         'email': email,
    //         'password': password,
    //         'returnSecureToken': true,
    //       },
    //     ));
    // print(json.decode(response.body));
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
    // final url = Uri.parse(
    //     'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyB76FnEfWVzAkSJIK4XRErtUhp9SL2Vn1g');
    // final response = await http.post(url,
    //     body: json.encode(
    //       {
    //         'email': email,
    //         'password': password,
    //         'returnSecureToken': true,
    //       },
    //     ));
    // print(json.decode(response.body));
  }
}
