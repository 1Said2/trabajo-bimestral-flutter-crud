import 'package:flutter/material.dart';
import '../../models/estudiante_model.dart';
import '../../services/estudiante_service.dart';

class EstudianteForm extends StatefulWidget {
  const EstudianteForm({super.key, this.estudiante});

  final EstudianteModel? estudiante;

  @override
  State<EstudianteForm> createState() => _EstudianteFormState();
}

class _EstudianteFormState extends State<EstudianteForm> {
  final _cedulaController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  bool _isSubmitting = false;
  String _error = '';
  bool get _isEditMode => widget.estudiante != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _cedulaController.text = widget.estudiante!.cedula;
      _nombresController.text = widget.estudiante!.nombres;
      _apellidosController.text = widget.estudiante!.apellidos;
    }
  }

  Future<void> _submitForm() async {
    if (_cedulaController.text.trim().isEmpty ||
        _nombresController.text.trim().isEmpty ||
        _apellidosController.text.trim().isEmpty) {
      setState(() {
        _error = 'Por favor, complete todos los campos.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = '';
    });

    try {
      final estudiante = EstudianteModel(
        cedula: _cedulaController.text.trim(),
        nombres: _nombresController.text.trim(),
        apellidos: _apellidosController.text.trim(),
      );

      if (_isEditMode) {
        // Asume que la cédula original no cambia, de lo contrario habría que enviar la cédula anterior en la ruta.
        // Aquí pasamos la cédula del objeto actual.
        await EstudianteService.update(widget.estudiante!.cedula, estudiante);
      } else {
        await EstudianteService.create(estudiante);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Modificar Estudiante' : 'Crear Estudiante'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _cedulaController,
              decoration: const InputDecoration(labelText: 'Cédula'),
              textInputAction: TextInputAction.next,
              enabled: !_isEditMode, // No permitir cambiar la cédula si estamos editando
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nombresController,
              decoration: const InputDecoration(labelText: 'Nombres'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _apellidosController,
              decoration: const InputDecoration(labelText: 'Apellidos'),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 10),
            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditMode ? 'Actualizar' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
