import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estudiante_model.dart';

class EstudianteService {
  static const String baseUrl = 'https://products-api-c6e5debfdrd9dba7.westus3-01.azurewebsites.net/api/estudiantes';

  static Future<List<EstudianteModel>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => EstudianteModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Error al cargar estudiantes');
    }
  }

  static Future<EstudianteModel> getByCedula(String cedula) async {
    final response = await http.get(Uri.parse('$baseUrl/$cedula'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return EstudianteModel.fromJson(data);
    } else {
      throw Exception('Error al cargar estudiante');
    }
  }

  static Future<EstudianteModel> create(EstudianteModel estudiante) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(estudiante.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Puede que la API no retorne el estudiante, en ese caso retornamos el mismo
      if (response.body.isNotEmpty) {
        return EstudianteModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      return estudiante;
    } else {
      throw Exception('Error al crear estudiante: ${response.statusCode}');
    }
  }

  static Future<void> update(String cedula, EstudianteModel estudiante) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$cedula'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'apellidos': estudiante.apellidos,
        'nombres': estudiante.nombres,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar estudiante');
    }
  }

  static Future<void> delete(String cedula) async {
    final response = await http.delete(Uri.parse('$baseUrl/$cedula'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar estudiante: $cedula');
    }
  }
}
