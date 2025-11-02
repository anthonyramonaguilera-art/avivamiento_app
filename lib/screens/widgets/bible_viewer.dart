// lib/widgets/bible_viewer.dart

import 'package:flutter/material.dart';
import 'package:avivamiento_app/services/bible_service.dart';

class BibleViewer extends StatefulWidget {
  const BibleViewer({super.key});

  @override
  State<BibleViewer> createState() => _BibleViewerState();
}

class _BibleViewerState extends State<BibleViewer> {
  // Versículo que se cargará por defecto (Génesis 1:1)
  final String _initialPassage = 'GEN.1.1'; 
  
  // Estado para el texto del pasaje
  String _passageText = 'Cargando...'; 

  @override
  void initState() {
    super.initState();
    // Inicia la carga del versículo inicial
    _loadPassage(_initialPassage);
  }

  /// Función para cargar el pasaje, actualizando el estado.
  void _loadPassage(String passage) async {
    setState(() {
      _passageText = 'Cargando pasaje $passage...';
    });

    final result = await fetchPassageContent(passage);

    setState(() {
      _passageText = result;
    });
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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          // Contenedor del texto de la Biblia
          Expanded(
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _passageText,
                  style: const TextStyle(fontSize: 18, height: 1.5, fontFamily: 'Georgia'),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Botón de ejemplo para cargar otro versículo
          ElevatedButton.icon(
            icon: const Icon(Icons.menu_book),
            label: const Text('Mostrar Juan 3:16', style: TextStyle(fontSize: 16)),
            onPressed: () => _loadPassage('JHN.3.16'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}