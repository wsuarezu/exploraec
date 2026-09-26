import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ExploraEcApp());
}

/// Paleta del sistema de diseño "Andean Horizon" generado en Stitch.
abstract final class AndeanHorizon {
  static const surface = Color(0xFFF7F9FB);
  static const onSurface = Color(0xFF191C1E);
  static const onSurfaceVariant = Color(0xFF3D4947);
  static const primary = Color(0xFF00685F);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF008378);
  static const secondaryContainer = Color(0xFFBDECE2);
  static const outline = Color(0xFF6D7A77);

  /// Semilla de marca (teal andino), usada para derivar el tema oscuro.
  static const semilla = Color(0xFF0D9488);

  static const esquema = ColorScheme.light(
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: Color(0xFFF4FFFC),
    secondary: Color(0xFF3B665F),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: Color(0xFF416C65),
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
  );

  // Escala tipográfica de Stitch: Plus Jakarta Sans.
  // El `height` traduce el line-height y el `letterSpacing` va en px, no en em.
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 48 / 40,
        letterSpacing: -1.2,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 22 / 14,
        letterSpacing: 0.14,
      );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.14,
      );
}

class ExploraEcApp extends StatelessWidget {
  const ExploraEcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExploraEC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: AndeanHorizon.esquema,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AndeanHorizon.semilla,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        useMaterial3: true,
      ),
      home: const BienvenidaScreen(),
    );
  }
}

class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key, this.onEmpezar});

  /// Se invoca al pulsar "Empezar". Aquí se conecta la navegación al mapa.
  final VoidCallback? onEmpezar;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colores.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, restricciones) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: restricciones.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    // margin: 1.5rem del sistema de diseño.
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Center(child: _Encabezado())),
                        _BotonEmpezar(
                          onPressed:
                              onEmpezar ?? () => _avisarPendiente(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _avisarPendiente(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pantalla de lugares aún no disponible')),
    );
  }
}

class _Encabezado extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colores.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.explore_outlined,
            size: 36,
            color: colores.primary,
          ),
        ),
        // space-xl: 2.5rem.
        const SizedBox(height: 40),
        Text(
          'ExploraEC',
          textAlign: TextAlign.center,
          style: AndeanHorizon.displayLarge.copyWith(color: colores.onSurface),
        ),
        // space-sm: 0.5rem.
        const SizedBox(height: 8),
        Text(
          'Descubre lugares increíbles cerca de ti',
          textAlign: TextAlign.center,
          style: AndeanHorizon.bodyMedium
              .copyWith(color: colores.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _BotonEmpezar extends StatelessWidget {
  const _BotonEmpezar({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colores.primary,
        foregroundColor: colores.onPrimary,
        // Botón primario: 56px de alto, forma de píldora.
        minimumSize: const Size.fromHeight(56),
        shape: const StadiumBorder(),
        elevation: 0,
        textStyle: AndeanHorizon.labelLarge,
      ),
      child: const Text('Empezar'),
    );
  }
}
