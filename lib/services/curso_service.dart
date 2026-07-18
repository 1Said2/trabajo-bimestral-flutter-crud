import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/curso_model.dart';

class CursoService {
  static const String baseUrl = 'https://products-api-c6e5debfdrd9dba7.westus3-01.azurewebsites.net/api/cursos';

  static Future<List<CursoModel>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => CursoModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Error al cargar cursos');
    }
  }

  static Future<CursoModel> getById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return CursoModel.fromJson(data);
    } else {
      throw Exception('Error al cargar curso');
    }
  }

  static Future<CursoModel> create(CursoModel curso) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'nombre': curso.nombre,
        'precio': curso.precio,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isNotEmpty) {
        return CursoModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      return curso;
    } else {
      throw Exception('Error al crear curso');
    }
  }

  static Future<void> update(int id, CursoModel curso) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'nombre': curso.nombre,
        'precio': curso.precio,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar curso');
    }
  }

  static Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar curso');
    }
  }
}
