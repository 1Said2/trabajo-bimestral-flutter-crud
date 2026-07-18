import 'package:flutter/material.dart';
import '../../models/inscripcion_model.dart';
import '../../models/estudiante_model.dart';
import '../../models/curso_model.dart';
import '../../services/inscripcion_service.dart';
import '../../services/estudiante_service.dart';
import '../../services/curso_service.dart';

class InscripcionForm extends StatefulWidget {
  const InscripcionForm({super.key, this.inscripcion});

  final InscripcionModel? inscripcion;

  @override
  State<InscripcionForm> createState() => _InscripcionFormState();
}

class _InscripcionFormState extends State<InscripcionForm> {
  bool _isSubmitting = false;
  bool _isLoadingData = true;
  String _error = '';
  
  List<EstudianteModel> _estudiantes = [];
  List<CursoModel> _cursos = [];
  
  String? _selectedCedula;
  final List<int> _selectedCursosIds = [];
  
  final _fechaController = TextEditingController();

  bool get _isEditMode => widget.inscripcion != null;

  @override
  void initState() {
    super.initState();
    _loadDependencies();
  }
  
  Future<void> _loadDependencies() async {
    try {
      final estudiantes = await EstudianteService.getAll();
      final cursos = await CursoService.getAll();
      
      if (!mounted) return;
      setState(() {
        _estudiantes = estudiantes;
        _cursos = cursos;
        _isLoadingData = false;
        
        if (_isEditMode) {
          _selectedCedula = widget.inscripcion?.estudiante?.cedula ?? widget.inscripcion?.cedula;
          _fechaController.text = widget.inscripcion?.fecha ?? '';
          
          if (widget.inscripcion?.cursos != null) {
            for (var c in widget.inscripcion!.cursos!) {
              if (c.id != null) {
                _selectedCursosIds.add(c.id!);
              }
            }
          }
        } else {
          // Default date for new
          _fechaController.text = DateTime.now().toString().substring(0, 10);
        }
      });
    } catch(e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error cargando datos: $e';
        _isLoadingData = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_selectedCedula == null || _selectedCursosIds.isEmpty || _fechaController.text.isEmpty) {
      setState(() {
        _error = 'Por favor, seleccione un estudiante, una fecha y al menos un curso.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = '';
    });

    try {
      final inscripcion = InscripcionModel(
        id: widget.inscripcion?.id,
        cedula: _selectedCedula,
        fecha: _fechaController.text,
        detalles: _selectedCursosIds,
      );

      if (_isEditMode) {
        await InscripcionService.update(inscripcion.id!, inscripcion);
      } else {
        await InscripcionService.create(inscripcion);
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
  
  void _toggleCurso(int? cursoId) {
    if (cursoId == null) return;
    setState(() {
      if (_selectedCursosIds.contains(cursoId)) {
        _selectedCursosIds.remove(cursoId);
      } else {
        _selectedCursosIds.add(cursoId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Modificar Inscripción' : 'Crear Inscripción'),
      ),
      body: _isLoadingData 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedCedula,
                  decoration: const InputDecoration(labelText: 'Estudiante'),
                  items: _estudiantes.map((e) {
                    return DropdownMenuItem<String>(
                      value: e.cedula,
                      child: Text('${e.nombres} ${e.apellidos} (${e.cedula})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCedula = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _fechaController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha (YYYY-MM-DD)',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _fechaController.text = pickedDate.toString().substring(0, 10);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Cursos disponibles:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  height: 200,
                  child: ListView.builder(
                    itemCount: _cursos.length,
                    itemBuilder: (context, index) {
                      final curso = _cursos[index];
                      final isSelected = _selectedCursosIds.contains(curso.id);
                      return CheckboxListTile(
                        title: Text(curso.nombre),
                        subtitle: Text('\$${curso.precio}'),
                        value: isSelected,
                        onChanged: (bool? value) {
                          _toggleCurso(curso.id);
                        },
                      );
                    },
                  ),
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
