class EstudianteModel {
  String cedula;
  String nombres;
  String apellidos;

  EstudianteModel({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
  });

  factory EstudianteModel.fromJson(Map<String, dynamic> json) {
    return EstudianteModel(
      cedula: json['cedula'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    // Al crear (POST), la cédula va en el body.
    // Al actualizar (PUT), la cédula va en la ruta, pero podemos enviarla igual o adaptarlo.
    return {
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
    };
  }
}
