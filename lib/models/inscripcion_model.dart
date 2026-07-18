import 'estudiante_model.dart';
import 'curso_model.dart';

class InscripcionModel {
  int? id;
  String? fecha;
  
  // Datos para lectura (GET)
  EstudianteModel? estudiante;
  List<CursoModel>? cursos;
  
  // Datos para creación (POST / PUT)
  String? cedula;
  List<int>? detalles;

  InscripcionModel({
    this.id,
    this.fecha,
    this.estudiante,
    this.cursos,
    this.cedula,
    this.detalles,
  });

  factory InscripcionModel.fromJson(Map<String, dynamic> json) {
    return InscripcionModel(
      id: json['id_inscripcion_cab'],
      fecha: json['fecha'],
      estudiante: json['ins_estudiante'] != null 
          ? EstudianteModel.fromJson(json['ins_estudiante']) 
          : null,
      cursos: json['ins_inscripcion_det'] != null
          ? (json['ins_inscripcion_det'] as List)
              .map((e) => CursoModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      cedula: json['cedula'],
      detalles: json['detalles'] != null 
          ? (json['detalles'] as List).map((e) {
              if (e is int) return e;
              if (e is Map) return (e['id_curso'] ?? e['id']) as int;
              return int.tryParse(e.toString()) ?? 0;
            }).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Formato esperado por el POST/PUT
    return {
      'cedula': cedula ?? estudiante?.cedula,
      'fecha': fecha,
      'detalles': detalles ?? cursos?.map((c) => c.id!).toList() ?? <int>[],
    };
  }
}
