import 'package:flutter/material.dart';
import '../../models/estudiante_model.dart';
import '../../services/estudiante_service.dart';
import 'estudiante_form.dart';

class EstudianteList extends StatefulWidget {
  const EstudianteList({super.key});

  @override
  State<EstudianteList> createState() => _EstudianteListState();
}

class _EstudianteListState extends State<EstudianteList> {
  String _error = '';
  bool _isLoading = false;
  List<EstudianteModel> _estudiantes = [];

  Future<void> _fetchEstudiantes() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final estudiantes = await EstudianteService.getAll();
      setState(() {
        _estudiantes = estudiantes;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openEstudianteForm({EstudianteModel? estudiante}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EstudianteForm(estudiante: estudiante)),
    );
    _fetchEstudiantes();
  }

  Future<void> _deleteEstudiante(EstudianteModel estudiante) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Seguro que quiere eliminar a ${estudiante.nombres} ${estudiante.apellidos}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      try {
        await EstudianteService.delete(estudiante.cedula);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Estudiante eliminado correctamente')),
          );
        }
        await _fetchEstudiantes();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(   
            SnackBar(content: Text('Error al eliminar estudiante: $e')),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEstudiantes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Estudiantes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEstudianteForm(estudiante: null),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text(_error, style: const TextStyle(color: Colors.red))],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchEstudiantes,
              child: _estudiantes.isEmpty
                  ? const Center(
                      child: Text('No hay estudiantes registrados'),
                    )
                  : ListView.builder(
                      itemCount: _estudiantes.length,
                      itemBuilder: (context, index) {
                        final estudiante = _estudiantes[index];
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text('${estudiante.nombres} ${estudiante.apellidos}'),
                          subtitle: Text('Cédula: ${estudiante.cedula}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _openEstudianteForm(estudiante: estudiante),
                                icon: const Icon(Icons.edit, color: Colors.blue),
                              ),
                              IconButton(
                                onPressed: () => _deleteEstudiante(estudiante),
                                icon: const Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
