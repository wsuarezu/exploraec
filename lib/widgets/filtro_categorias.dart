import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fila de chips para filtrar una lista por categoría. No sabe de dónde salen
/// las categorías ni qué hacer con la elección: recibe los datos y avisa hacia
/// arriba, igual que `EmptyView` o `ErrorView`. Una `seleccionada` vacía
/// significa «Todas».
class FiltroCategorias extends StatelessWidget {
  final List<String> categorias;
  final String seleccionada;
  final ValueChanged<String> alSeleccionar;

  const FiltroCategorias({
    super.key,
    required this.categorias,
    required this.seleccionada,
    required this.alSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    // Por qué scroll horizontal y no `Wrap`: así la fila ocupa siempre el mismo
    // alto y no le roba espacio a la lista cuando hay muchas categorías.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _chip(etiqueta: 'Todas', valor: ''),
          for (final categoria in categorias) ...[
            const SizedBox(width: AppSpacing.sm),
            _chip(etiqueta: categoria, valor: categoria),
          ],
        ],
      ),
    );
  }

  Widget _chip({required String etiqueta, required String valor}) {
    return ChoiceChip(
      label: Text(etiqueta),
      selected: seleccionada == valor,
      onSelected: (_) => alSeleccionar(valor),
    );
  }
}
