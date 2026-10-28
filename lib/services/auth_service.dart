import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';

class AuthService {
  UserModel? _currentUser;
  String? _token;

int? _userId;

int? get userId => _userId;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String? get token => _token;

  // En Chrome/Windows usamos localhost.
  // En emulador Android, localhost apunta al propio emulador,
  // por eso usamos 10.0.2.2.
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5128';
    }

    return 'http://10.0.2.2:5128';
  }

  /// REGISTRO REAL
  ///
  /// API:
  /// POST /api/Auth/register
  ///
  /// En el backend:
  /// email      -> alias
  /// password   -> contrasena
  Future<UserModel> registerLocally({
    required String fullName,
    required String email,
    required String password,
    required ExplorerType explorerType,
  }) async {
    if (fullName.trim().isEmpty) {
      throw ArgumentError('El nombre completo es obligatorio');
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(email.trim())) {
      throw ArgumentError('Ingresa un correo electrónico válido');
    }

    if (password.length < 8) {
      throw ArgumentError(
        'La contraseña debe tener mínimo 8 caracteres',
      );
    }

    final url = Uri.parse('$baseUrl/api/Auth/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'alias': email.trim(),
          'contrasena': password,

          // El backend actualmente trabaja con roles.
          'nombreRol': 'Estudiante',

          // Datos adicionales requeridos por el endpoint.
          // Los dejamos con valores básicos mientras conectamos
          // los campos correspondientes de la pantalla.
          'idGradoEscolar': 1,
          'fechaNacimiento': '2010-01-01T00:00:00.000Z',
          'institucion': 'El Camino del Guardabarranco',
          'telefono': '',
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          body['message'] ?? 'No se pudo registrar el usuario.',
        );
      }

      if (body['success'] != true) {
        throw Exception(
          body['message'] ?? 'No se pudo registrar el usuario.',
        );
      }

      final data = body['data'];

      // Guardamos el token que devuelve la API.
      _token = data['token'];

      _userId = data['idUsuario'];

      // La API devuelve alias, que estamos utilizando como email.
      _currentUser = UserModel(
        fullName: fullName.trim(),
        email: data['alias'] ?? email.trim(),
        explorerType: explorerType,
      );

      return _currentUser!;
    } catch (e) {
      if (e is ArgumentError) {
        rethrow;
      }

      throw Exception(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// LOGIN REAL
  ///
  /// API:
  /// POST /api/Auth/login
  ///
  /// En el backend:
  /// email      -> alias
  /// password   -> contrasena
  Future<UserModel> loginLocally({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty) {
      throw ArgumentError('Ingresa tu correo electrónico.');
    }

    if (password.isEmpty) {
      throw ArgumentError('Ingresa tu contraseña.');
    }

    final url = Uri.parse('$baseUrl/api/Auth/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'alias': email.trim(),
          'contrasena': password,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          body['message'] ?? 'Correo o contraseña incorrectos.',
        );
      }

      if (body['success'] != true) {
        throw Exception(
          body['message'] ?? 'No se pudo iniciar sesión.',
        );
      }

      final data = body['data'];

      // Guardamos el JWT.
      _token = data['token'];

      _userId = data['idUsuario'];

      _currentUser = UserModel(
        fullName: 'Explorador',
        email: data['alias'] ?? email.trim(),
        explorerType: ExplorerType.male,
      );

      return _currentUser!;
    } catch (e) {
      if (e is ArgumentError) {
        rethrow;
      }

      throw Exception(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Permite limpiar la sesión.
  void logout() {
    _currentUser = null;
    _token = null;
    _userId = null;
  }
}