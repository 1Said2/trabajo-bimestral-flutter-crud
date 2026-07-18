class CursoModel {
  int? id;
  String nombre;
  double precio;

  CursoModel({
    this.id,
    required this.nombre,
    required this.precio,
  });

  factory CursoModel.fromJson(Map<String, dynamic> json) {
    // Manejar tanto 'id' (de /cursos) como 'id_curso' (de /inscripciones nested)
    return CursoModel(
      id: json['id'] ?? json['id_curso'],
      nombre: json['nombre'] ?? '',
      precio: (json['precio'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nombre': nombre,
      'precio': precio,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}
