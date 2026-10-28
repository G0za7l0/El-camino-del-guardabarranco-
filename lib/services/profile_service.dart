import '../services/api_service.dart';

class ProfileService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getProfile({
    required int userId,
    required String token,
  }) async {
    final response = await _api.get(
      '/api/Perfil/$userId',
      token: token,
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Respuesta inválida del servidor.');
    }

    if (response['success'] != true) {
      throw Exception(
        response['message'] ?? 'No se pudo obtener el perfil.',
      );
    }

    final data = response['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception('Los datos del perfil no son válidos.');
    }

    return data;
  }
}