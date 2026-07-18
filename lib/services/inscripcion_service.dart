import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inscripcion_model.dart';

class InscripcionService {
  static const String baseUrl = 'https://products-api-c6e5debfdrd9dba7.westus3-01.azurewebsites.net/api/inscripciones';

  static Future<List<InscripcionModel>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => InscripcionModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Error al cargar inscripciones');
    }
  }

  static Future<InscripcionModel> getById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return InscripcionModel.fromJson(data);
    } else {
      throw Exception('Error al cargar inscripción');
    }
  }

  static Future<InscripcionModel> create(InscripcionModel inscripcion) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(inscripcion.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isNotEmpty) {
        return InscripcionModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      return inscripcion;
    } else {
      throw Exception('Error al registrar inscripción');
    }
  }

  static Future<void> update(int id, InscripcionModel inscripcion) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(inscripcion.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar inscripción');
    }
  }

  static Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar inscripción');
    }
  }
}
