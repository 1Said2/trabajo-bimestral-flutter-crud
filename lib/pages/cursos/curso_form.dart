import 'package:flutter/material.dart';
import '../../models/curso_model.dart';
import '../../services/curso_service.dart';

class CursoForm extends StatefulWidget {
  const CursoForm({super.key, this.curso});

  final CursoModel? curso;

  @override
  State<CursoForm> createState() => _CursoFormState();
}

class _CursoFormState extends State<CursoForm> {
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  bool _isSubmitting = false;
  String _error = '';
  bool get _isEditMode => widget.curso != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _nombreController.text = widget.curso!.nombre;
      _precioController.text = widget.curso!.precio.toString();
    }
  }

  Future<void> _submitForm() async {
    if (_nombreController.text.trim().isEmpty ||
        _precioController.text.trim().isEmpty) {
      setState(() {
        _error = 'Por favor, complete todos los campos.';
      });
      return;
    }

    final double? precio = double.tryParse(_precioController.text.trim());
    if (precio == null) {
      setState(() {
        _error = 'El precio debe ser un valor numérico válido.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = '';
    });

    try {
      final curso = CursoModel(
        id: widget.curso?.id,
        nombre: _nombreController.text.trim(),
        precio: precio,
      );

      if (_isEditMode) {
        await CursoService.update(curso.id!, curso);
      } else {
        await CursoService.create(curso);
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
        title: Text(_isEditMode ? 'Modificar Curso' : 'Crear Curso'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del Curso'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _precioController,
              decoration: const InputDecoration(labelText: 'Precio (\$)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
