import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userID;
  Timer? _authTimer;

  static const String apiKey = "AIzaSyD5mZ7onipWiDqofVDON-KHptDooW8tyRo";

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$apiKey");
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }),
      );
      print(response.body);
      final responseData = jsonDecode(response.body);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }
      _token = responseData["idToken"];
      _userID = responseData["localId"];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData["expiresIn"])));
      autoLogOut();
      notifyListeners();
      SharedPreferences preferences = await SharedPreferences.getInstance();
      final userData = jsonEncode({
        "token": _token,
        "userID": _userID,
        "expiryDate": _expiryDate!.toIso8601String(),
      });
      preferences.setString("userData", userData);
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<bool> tryAutoLogIn() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey("userData")) {
      return false;
    }
    final extractedData =
        jsonDecode(preferences.getString("userData") as String) as Map;
    final expiryData = DateTime.parse(extractedData["expiryDate"]);
    if (expiryData.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedData["token"];
    _userID = extractedData["userID"];
    _expiryDate = expiryData;
    notifyListeners();
    autoLogOut();
    return true;
  }

  Future<void> logIn(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  String? get token {
    if (_token != null) return _token;
  }
  // if (_expiryDate != null &&
  //     _expiryDate!.isAfter(DateTime.now()) &&
  //     _token != "") {
  //   print("Token saved : $token");
  //   return token;
  // }
  // return "";

  String? get userID => _userID;

  Future<void> logOut() async {
    _token = null;
    _userID = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
  }

  void autoLogOut() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpire = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire), logOut);
  }

  bool get isAuth => token != null ? true : false;
}
