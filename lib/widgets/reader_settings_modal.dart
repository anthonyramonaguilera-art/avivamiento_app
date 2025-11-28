// lib/widgets/reader_settings_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/reader_settings_model.dart';
import 'package:avivamiento_app/providers/reader_settings_provider.dart';

/// Modal Bottom Sheet para configurar la experiencia de lectura
class ReaderSettingsModal extends ConsumerWidget {
  const ReaderSettingsModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(readerSettingsProvider);
    final notifier = ref.read(readerSettingsProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: settings.theme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del modal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Configuración del Lector',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: settings.theme.textColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: settings.theme.textColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sección: Tamaño de fuente
          _SectionTitle(
            title: 'Tamaño de Fuente',
            textColor: settings.theme.textColor,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.text_fields,
                  color: settings.theme.textColor, size: 16),
              Expanded(
                child: Slider(
                  value: settings.fontSize,
                  min: 14.0,
                  max: 30.0,
                  divisions: 16,
                  label: '${settings.fontSize.round()}',
                  onChanged: (value) => notifier.updateFontSize(value),
                ),
              ),
              Icon(Icons.text_fields,
                  color: settings.theme.textColor, size: 28),
            ],
          ),

          // Preview del tamaño de fuente
          Center(
            child: Text(
              'Ejemplo de texto (${settings.fontSize.round()}pt)',
              style: TextStyle(
                fontSize: settings.fontSize,
                fontFamily: settings.fontFamily.fontFamily,
                color: settings.theme.textColor,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sección: Tema
          _SectionTitle(
            title: 'Tema',
            textColor: settings.theme.textColor,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ReaderTheme.values.map((theme) {
              final isSelected = settings.theme == theme;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _ThemeButton(
                    theme: theme,
                    isSelected: isSelected,
                    onTap: () => notifier.updateTheme(theme),
                    currentTextColor: settings.theme.textColor,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Sección: Familia de fuente
          _SectionTitle(
            title: 'Fuente',
            textColor: settings.theme.textColor,
          ),
          const SizedBox(height: 12),
          Row(
            children: ReaderFontFamily.values.map((fontFamily) {
              final isSelected = settings.fontFamily == fontFamily;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _FontFamilyButton(
                    fontFamily: fontFamily,
                    isSelected: isSelected,
                    onTap: () => notifier.updateFontFamily(fontFamily),
                    textColor: settings.theme.textColor,
                    backgroundColor: settings.theme.backgroundColor,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Widget para el título de cada sección
class _SectionTitle extends StatelessWidget {
  final String title;
  final Color textColor;

  const _SectionTitle({
    required this.title,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}

/// Botón para seleccionar tema
class _ThemeButton extends StatelessWidget {
  final ReaderTheme theme;
  final bool isSelected;
  final VoidCallback onTap;
  final Color currentTextColor;

  const _ThemeButton({
    required this.theme,
    required this.isSelected,
    required this.onTap,
    required this.currentTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          border: Border.all(
            color: isSelected ? Colors.blue : currentTextColor.withOpacity(0.2),
            width: isSelected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.circle,
              color: theme.backgroundColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              theme.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: theme.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón para seleccionar familia de fuente
class _FontFamilyButton extends StatelessWidget {
  final ReaderFontFamily fontFamily;
  final bool isSelected;
  final VoidCallback onTap;
  final Color textColor;
  final Color backgroundColor;

  const _FontFamilyButton({
    required this.fontFamily,
    required this.isSelected,
    required this.onTap,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: isSelected ? Colors.blue : textColor.withOpacity(0.2),
            width: isSelected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Abc',
            style: TextStyle(
              fontSize: 20,
              fontFamily: fontFamily.fontFamily,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
