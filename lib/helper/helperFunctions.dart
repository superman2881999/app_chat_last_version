import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String sharedPreferenceLoggedInKey = "ISLOGGEDIN";
  static String sharedPreferenceUserNameKey = "USERNAMEKEY";
  static String sharedPreferenceUserEmailKey = "USEREMAILKEY";

  static Future<void> saveuserLoggedInSharePreference(bool  isUserLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(sharedPreferenceLoggedInKey, isUserLoggedIn);
  }
  static Future<void> saveuserNameSharePreference(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceUserNameKey, userName);
  }
  static Future<void> saveuserEmailSharePreference(String userEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceUserEmailKey, userEmail);
  }

  static Future<bool> getuserLoggedInSharePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return  prefs.getBool(sharedPreferenceLoggedInKey);
  }
  static Future<String> getuserNameSharePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return  prefs.getString(sharedPreferenceUserNameKey);
  }
  static Future<String> getuserEmailSharePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return  prefs.getString(sharedPreferenceUserEmailKey);
  }
}
