import 'package:flutter/material.dart';
import '../../models/curso_model.dart';
import '../../services/curso_service.dart';
import 'curso_form.dart';

class CursoList extends StatefulWidget {
  const CursoList({super.key});

  @override
  State<CursoList> createState() => _CursoListState();
}

class _CursoListState extends State<CursoList> {
  String _error = '';
  bool _isLoading = false;
  List<CursoModel> _cursos = [];

  Future<void> _fetchCursos() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final cursos = await CursoService.getAll();
      setState(() {
        _cursos = cursos;
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

  Future<void> _openCursoForm({CursoModel? curso}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CursoForm(curso: curso)),
    );
    _fetchCursos();
  }

  Future<void> _deleteCurso(CursoModel curso) async {
    if (curso.id == null) return;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Seguro que quiere eliminar el curso ${curso.nombre}?'),
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
        await CursoService.delete(curso.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Curso eliminado correctamente')),
          );
        }
        await _fetchCursos();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(   
            SnackBar(content: Text('Error al eliminar curso: $e')),
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
    _fetchCursos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Cursos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCursoForm(curso: null),
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
              onRefresh: _fetchCursos,
              child: _cursos.isEmpty
                  ? const Center(
                      child: Text('No hay cursos registrados'),
                    )
                  : ListView.builder(
                      itemCount: _cursos.length,
                      itemBuilder: (context, index) {
                        final curso = _cursos[index];
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.book)),
                          title: Text(curso.nombre),
                          subtitle: Text('Precio: \$${curso.precio}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _openCursoForm(curso: curso),
                                icon: const Icon(Icons.edit, color: Colors.blue),
                              ),
                              IconButton(
                                onPressed: () => _deleteCurso(curso),
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
