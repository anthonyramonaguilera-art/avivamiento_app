// lib/screens/bible_search_screen.dart
import 'package:flutter/material.dart';
import '../services/bible_service.dart'; // Importa el servicio que contiene fetchPassageContent

/// Pantalla para la Lectura y Búsqueda de la Biblia RVR09.
class BibleSearchScreen extends StatefulWidget {
  // Usamos una ruta estática para facilitar la navegación desde main.dart
  static const routeName = '/bible-search';
  const BibleSearchScreen({super.key});

  @override
  State<BibleSearchScreen> createState() => _BibleSearchScreenState();
}

class _BibleSearchScreenState extends State<BibleSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _bibleContent = 'Ingresa una referencia (ej: JHN.3.16) o una frase (ej: amor incondicional) para empezar.';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Carga un versículo por defecto (Juan 3:16) al iniciar
    _searchController.text = 'JHN.3.16';
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _bibleContent = 'Por favor, ingresa una referencia o una frase de búsqueda.';
      });
      return;
    }

    setState(() {
      _isLoading = true; // Activa el indicador de carga
      _bibleContent = 'Cargando contenido...';
    });

    try {
      final content = await fetchPassageContent(query);
      setState(() {
        _bibleContent = content;
      });
    } catch (e) {
      setState(() {
        _bibleContent = 'Ocurrió un error inesperado: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; // Desactiva el indicador de carga
      });
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lector Bíblico (RVR09)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        // Agregamos un botón de acción en el AppBar que podría usarse 
        // para un futuro selector de libros. Por ahora, solo es estético.
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'Ver Libros',
            onPressed: () {
              // Aquí se agregaría la lógica para mostrar todos los libros de la Biblia.
              // Por ahora, solo muestra un mensaje.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad de Navegación por Libros (Próximamente)')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // 1. Campo de Búsqueda y Botón
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Ej: JHN.3.16 (Pasaje) o amor incondicional (Texto)',
                      labelText: 'Buscar en la Biblia',
                      prefixIcon: const Icon(Icons.search),
                      // El estilo de border se hereda de tu main.dart.
                    ),
                    onSubmitted: (_) => _fetchContent(), 
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 60, // Ajusta la altura
                  child: ElevatedButton.icon( // Usamos ElevatedButton.icon para mejor visibilidad
                    onPressed: _isLoading ? null : _fetchContent,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.search, size: 20),
                    label: const Text('Buscar', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. Área de Contenido de la Biblia
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: SelectableText( 
                    _bibleContent,
                    textAlign: TextAlign.start,
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 17,
                      height: 1.5,
                      color: Colors.grey.shade800,
                      fontFamily: 'Roboto',
                    )
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
