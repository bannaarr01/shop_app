import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shop_app/models/http_execption.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
//ds token expires at some point in time, that's d security mechanism
//for firebase generated token, expires after one hour
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  //getter
  String get userId {
    return _userId;
  }

  //getter
  bool get isAuth {
    return token != null; // we are authenticad
  }

  //getter
  String get token {
    //if its after now den it's valid
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

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
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autoLogout(); //activate when user log in
      notifyListeners();
      //setting shared_preferences, it also involve working with Future
      final prefs = await SharedPreferences.getInstance();
      //return future  which will return a shared_preferences instance and thats is then basically ur tunnel to that on device storage
      //json.encode({''})incase u have a map or complex data u can use json.encode
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      }); //stored my serialized, my converted data here
      prefs.setString('userData', userData); //key n value
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

//Retrieving d SharedPreferences
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      //if expiryDateTime is < dan currentTime, den token is invalid
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true; //return true wen succeed
  }

  void logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    _authTimer = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData'); for single clearing
    prefs.clear(); //clear/purge all
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }

    //btw expiry time n current time
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    //test wit 3 seconds to check
    // _authTimer = Timer(Duration(seconds: 3), logout);
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
