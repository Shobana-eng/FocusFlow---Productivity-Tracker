// PART 1/3
// lib/services/shared_pref_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
SharedPrefService._();

static final SharedPrefService instance =
SharedPrefService._();

static const String _isLoggedIn = "isLoggedIn";
static const String _userName = "userName";
static const String _userEmail = "userEmail";
static const String _isDarkMode = "isDarkMode";
static const String _onboardingDone = "onboardingDone";
static const String _predictionHistory = "predictionHistory";

Future<SharedPreferences> get _prefs async =>
await SharedPreferences.getInstance();

Future<void> setLoggedIn(bool value) async {
final prefs = await _prefs;
await prefs.setBool(_isLoggedIn, value);
}

Future<bool> isLoggedIn() async {
final prefs = await _prefs;
return prefs.getBool(_isLoggedIn) ?? false;
}

Future<void> saveUser({
required String name,
required String email,
}) async {
final prefs = await _prefs;
await prefs.setString(_userName, name);
await prefs.setString(_userEmail, email);
}

Future<String> getUserName() async {
final prefs = await _prefs;
return prefs.getString(_userName) ?? "";
}

Future<String> getUserEmail() async {
final prefs = await _prefs;
return prefs.getString(_userEmail) ?? "";
}
Future<void> setDarkMode(bool value) async {
final prefs = await _prefs;
await prefs.setBool(_isDarkMode, value);
}

Future<bool> isDarkMode() async {
final prefs = await _prefs;
return prefs.getBool(_isDarkMode) ?? true;
}

Future<void> setOnboardingCompleted(bool value) async {
final prefs = await _prefs;
await prefs.setBool(_onboardingDone, value);
}

Future<bool> isOnboardingCompleted() async {
final prefs = await _prefs;
return prefs.getBool(_onboardingDone) ?? false;
}

Future<void> savePredictionHistory(
List<Map<String, dynamic>> history) async {
final prefs = await _prefs;
await prefs.setString(
_predictionHistory,
jsonEncode(history),
);
}

Future<List<dynamic>> getPredictionHistory() async {
final prefs = await _prefs;

final String? data =
prefs.getString(_predictionHistory);

if (data == null) {
return [];
}

return jsonDecode(data);
}

Future<void> clearAll() async {
final prefs = await _prefs;
await prefs.clear();
}
}
