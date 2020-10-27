import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as Http;
import 'package:shop_app/models/User.dart';
import 'dart:convert';
import '../models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/utility/constant.dart';

//vadhikari.vit@gmail.com
// vikraM97
class Auth with ChangeNotifier {
  String _token;
  DateTime _expireDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return _token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_token != null &&
        _expireDate != null &&
        _expireDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  Future<void> signUp(String email, String password, String firstName,
      String lastName, String number) async {
    return authenticate(email, password, 'signUp',
        firstName: firstName, lastName: lastName, number: number);
  }

  Future<void> authenticate(String email, String password, String urlSegment,
      {String firstName = "", String lastName = "", String number = ""}) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCQyR_58NtsW0KcBjEFALLMZsJPpQinNGE';
    try {
      final response = await Http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      print(json.decode(response.body));
      final responseBody = json.decode(response.body) as Map<String, dynamic>;
      if (responseBody['error'] != null) {
        throw HttpException(message: responseBody['error']['message']);
      }
      _token = responseBody['idToken'];
      _userId = responseBody['localId'];
      _expireDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseBody['expiresIn'])));
      print('notifiy listeners');
      if (urlSegment == 'signUp') {
        addUser(userId, firstName, lastName, email, number);
      }
      autoLogout();
      notifyListeners();
      final preferences = await SharedPreferences.getInstance();
      final userData = json.encode({
        'email': email,
        'password': password,
        'token': _token,
        'user_token': _userId,
        'expire_date': _expireDate.toIso8601String()
      });
      preferences.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> autoLogin() async {
    print('autoLogin is called');
    final preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey('userData')) {
      return false;
    }
    final userData =
        json.decode(preferences.getString('userData')) as Map<String, dynamic>;
    print('preference data $userData');
    final expiryDate = DateTime.parse(userData['expire_date']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _expireDate = expiryDate;
    _userId = userData['user_token'];
    _token = userData['token'];
    autoLogout();
    notifyListeners();
    return true;
  }

  Future<bool> hasVision() async {
    final preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey('vision')) {
      return false;
    }
    return true;
  }

  void callListener() {
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    return authenticate(email, password, 'signInWithPassword');
  }

  Future<void> logout() async {
    print('logout is called ');
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final pref = await SharedPreferences.getInstance();
    pref.remove('userData');
    pref.clear();
    _userId = null;
    _token = null;
    _expireDate = null;
    print('Preference is cleared');
    notifyListeners();
  }

  Future<void> addUser(String userId, String firstName, String lastName,
      String email, String number) async {
    var url = '${Constants.firebaseUrl}users/$_userId.json?auth=$_token';
    try {
      final response = await Http.post(url,
          body: json.encode(User(
              email: email,
              firstName: firstName,
              lastName: lastName,
              cardNumber: "",
              number: number)));
      print("add user");
    } catch (error) {
      print(error.toString());
      throw HttpException(message: 'Error Occur while placing order');
    }
  }


  void autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final _timer = _expireDate.difference(DateTime.now()).inSeconds;
    print(_timer / 60);
    _authTimer = Timer(Duration(seconds: _timer), logout);
  }
}
