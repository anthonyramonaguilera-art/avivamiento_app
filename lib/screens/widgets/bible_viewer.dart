// lib/widgets/bible_viewer.dart

import 'package:flutter/material.dart';
import 'package:avivamiento_app/services/bible_service.dart';

class BibleViewer extends StatefulWidget {
  const BibleViewer({super.key});

  @override
  State<BibleViewer> createState() => _BibleViewerState();
}

class _BibleViewerState extends State<BibleViewer> {
  // Versículo que se cargará por defecto (versiculo ramdon)
  final String _initialPassage = 'GEN.1.1';

  // Estado para el texto del pasaje
  String _passageText = 'Cargando...';
  bool _isLoading = false;

  // Controlador para la caja de búsqueda
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicia la carga del versículo inicial
    _loadPassage(_initialPassage);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Función para cargar el pasaje, actualizando el estado.
  void _loadPassage(String passage) async {
    setState(() {
      _isLoading = true;
      _passageText = 'Cargando pasaje $passage...';
    });

    try {
      final result = await fetchPassageContent(passage);
      setState(() {
        _passageText = result;
      });
    } catch (e) {
      setState(() {
        _passageText = 'Error al obtener pasaje: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Método que obtiene el contenido del pasaje.
  /// En la app real deberías delegar esto a un servicio en lib/services/bible_service.dart.
  /// Use `BibleService.searchOrFetch` to resolve free-text queries (book/chapter/verse or text search).
  Future<String> fetchPassageContent(String passage) async {
    final service = BibleService();
    try {
      final res = await service.searchOrFetch(passage);
      return res;
    } catch (e) {
      return 'Error al obtener pasaje: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Título de la sección
          const Text(
            'Lector de la Santa Biblia (RVR09)',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Caja de búsqueda
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (val) {
              final q = val.trim();
              if (q.isNotEmpty) _loadPassage(q);
            },
            decoration: InputDecoration(
              hintText: 'Buscar libro, capítulo o texto (ej: Juan 3:16)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  final q = _searchController.text.trim();
                  if (q.isNotEmpty) _loadPassage(q);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Contenedor del texto de la Biblia
          Expanded(
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isLoading) const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(
                      _passageText,
                      style: const TextStyle(
                          fontSize: 18, height: 1.5, fontFamily: 'Georgia'),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Botón de ejemplo para cargar otro versículo
          ElevatedButton.icon(
            icon: const Icon(Icons.menu_book),
            label:
                const Text('Mostrar Juan 3:16', style: TextStyle(fontSize: 16)),
            onPressed: () => _loadPassage('JHN.3.16'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
