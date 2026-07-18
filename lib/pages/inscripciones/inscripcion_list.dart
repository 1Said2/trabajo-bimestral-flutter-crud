import 'package:flutter/material.dart';
import '../../models/inscripcion_model.dart';
import '../../services/inscripcion_service.dart';
import 'inscripcion_form.dart';

class InscripcionList extends StatefulWidget {
  const InscripcionList({super.key});

  @override
  State<InscripcionList> createState() => _InscripcionListState();
}

class _InscripcionListState extends State<InscripcionList> {
  String _error = '';
  bool _isLoading = false;
  List<InscripcionModel> _inscripciones = [];

  Future<void> _fetchInscripciones() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final inscripciones = await InscripcionService.getAll();
      setState(() {
        _inscripciones = inscripciones;
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

  Future<void> _openInscripcionForm({InscripcionModel? inscripcion}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InscripcionForm(inscripcion: inscripcion)),
    );
    _fetchInscripciones();
  }

  Future<void> _deleteInscripcion(InscripcionModel inscripcion) async {
    if (inscripcion.id == null) return;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Seguro que quiere eliminar la inscripción de ${inscripcion.estudiante?.nombres ?? inscripcion.id}?'),
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
        await InscripcionService.delete(inscripcion.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inscripción eliminada correctamente')),
          );
        }
        await _fetchInscripciones();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(   
            SnackBar(content: Text('Error al eliminar inscripción: $e')),
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
    _fetchInscripciones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Inscripciones')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openInscripcionForm(inscripcion: null),
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
              onRefresh: _fetchInscripciones,
              child: _inscripciones.isEmpty
                  ? const Center(
                      child: Text('No hay inscripciones registradas'),
                    )
                  : ListView.builder(
                      itemCount: _inscripciones.length,
                      itemBuilder: (context, index) {
                        final inscripcion = _inscripciones[index];
                        final estudiante = inscripcion.estudiante;
                        final estudianteName = estudiante != null 
                            ? '${estudiante.nombres} ${estudiante.apellidos}'
                            : 'Cédula: ${inscripcion.cedula ?? "Desconocido"}';
                            
                        final cursosCount = inscripcion.cursos?.length ?? 0;
                        
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.list_alt)),
                          title: Text(estudianteName),
                          subtitle: Text('Fecha: ${inscripcion.fecha} - Cursos: $cursosCount'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _openInscripcionForm(inscripcion: inscripcion),
                                icon: const Icon(Icons.edit, color: Colors.blue),
                              ),
                              IconButton(
                                onPressed: () => _deleteInscripcion(inscripcion),
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
