import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../../../../core/constants/app_constants.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage;
  late Box<UserModel> _userBox;

  AuthService(this._secureStorage);

  Future<void> init() async {
    _userBox = await Hive.openBox<UserModel>(AppConstants.userBox);
  }

  // Hash password with SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Generate simple JWT-like token
  String _generateToken(String userId, String email) {
    final payload = base64Encode(utf8.encode(
        jsonEncode({'userId': userId, 'email': email, 'iat': DateTime.now().millisecondsSinceEpoch})));
    final signature = _hashPassword('$userId.$email.secret_key').substring(0, 16);
    return 'eyJ.$payload.$signature';
  }

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    // Check if email exists
    final existingUser = _userBox.values.where((u) => u.email == email).firstOrNull;
    if (existingUser != null) {
      throw Exception('Cet email est déjà utilisé.');
    }

    final user = UserModel(
      id: const Uuid().v4(),
      username: username,
      email: email,
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now().toIso8601String(),
      favoriteGenreIds: [],
      watchedMovieIds: [],
      movieRatings: {},
    );

    await _userBox.put(user.id, user);
    final token = _generateToken(user.id, user.email);
    await _secureStorage.write(key: AppConstants.jwtTokenKey, value: token);
    await _secureStorage.write(key: AppConstants.currentUserKey, value: user.id);

    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final user = _userBox.values.where((u) => u.email == email).firstOrNull;
    if (user == null) {
      throw Exception('Aucun compte trouvé avec cet email.');
    }
    if (user.passwordHash != _hashPassword(password)) {
      throw Exception('Mot de passe incorrect.');
    }

    final token = _generateToken(user.id, user.email);
    await _secureStorage.write(key: AppConstants.jwtTokenKey, value: token);
    await _secureStorage.write(key: AppConstants.currentUserKey, value: user.id);

    return user;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.jwtTokenKey);
    await _secureStorage.delete(key: AppConstants.currentUserKey);
  }

  Future<UserModel?> getCurrentUser() async {
    final userId = await _secureStorage.read(key: AppConstants.currentUserKey);
    if (userId == null) return null;
    return _userBox.get(userId);
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: AppConstants.jwtTokenKey);
    final userId = await _secureStorage.read(key: AppConstants.currentUserKey);
    return token != null && userId != null;
  }

  Future<UserModel> updateUser(UserModel user) async {
    await _userBox.put(user.id, user);
    return user;
  }
}
