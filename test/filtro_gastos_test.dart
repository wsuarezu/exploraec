import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:exploraec/controllers/auth_controller.dart';
import 'package:exploraec/controllers/gastos_controller.dart';
import 'package:exploraec/screens/gastos_screen.dart';
import 'package:exploraec/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

/// Backend de gastos falso, en memoria: solo las rutas que necesita la pantalla
/// de Gastos al abrirse. No hace falta el backend real ni el emulador.
class _Servidor implements HttpClientAdapter {
  /// Cada prueba recibe un usuario distinto: así abre su propia caja de Hive
  /// (`gastos_<id>`) y no hay que cerrar ni borrar nada entre pruebas.
  static var _usuarios = 0;
  final idUsuario = ++_usuarios;
  final gastos = <Map<String, dynamic>>[];
  var _id = 1;

  ResponseBody _json(Object? cuerpo, int codigo, [Map<String, List<String>> h = const {}]) =>
      ResponseBody.fromString(cuerpo == null ? '' : jsonEncode(cuerpo), codigo,
          headers: {Headers.contentTypeHeader: ['application/json'], ...h});

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? cuerpo, Future<void>? cancelar) async {
    final texto = cuerpo == null ? '' : utf8.decode((await cuerpo.toList()).expand((x) => x).toList());
    final ruta = o.path;
    if (ruta == '/usuarios/token') {
      return _json({'access_token': 'tok-a@b.com', 'token_type': 'bearer'}, 200);
    }
    if (ruta == '/usuarios/me') return _json({'id': idUsuario, 'email': 'a@b.com'}, 200);
    if (ruta == '/gastos/categorias') {
      return _json({
        'categorias': ['comida', 'transporte', 'entretenimiento', 'otros'],
        'limite_por_categoria': 500.0,
      }, 200);
    }
    if (ruta == '/gastos/' && o.method == 'GET') {
      return _json(gastos, 200, {'x-total-count': ['${gastos.length}']});
    }
    if (ruta == '/gastos/' && o.method == 'POST') {
      final nuevo = {'id': _id++, 'fecha': '2026-10-08', ...jsonDecode(texto) as Map<String, dynamic>};
      gastos.add(nuevo);
      return _json(nuevo, 201);
    }
    return _json({'detail': 'ruta no prevista en la prueba: $ruta'}, 404);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUpAll(() => Hive.init(Directory.systemTemp.createTempSync('hive_filtro').path));

  late _Servidor servidor;

  /// Monta la app con el servidor falso, la sesión iniciada y tres gastos:
  /// dos de «comida» y uno de «transporte».
  Future<void> montar() async {
    Get.reset();
    Get.testMode = true;
    FlutterSecureStorage.setMockInitialValues({});
    servidor = _Servidor();
    servidor.gastos.addAll([
      {'id': 1, 'descripcion': 'Almuerzo', 'monto': 6.5, 'categoria': 'comida', 'fecha': '2026-10-08'},
      {'id': 2, 'descripcion': 'Café', 'monto': 1.5, 'categoria': 'comida', 'fecha': '2026-10-08'},
      {'id': 3, 'descripcion': 'Taxi', 'monto': 3.25, 'categoria': 'transporte', 'fecha': '2026-10-08'},
    ]);
    Get.put(ApiClient(dio: Dio(BaseOptions(baseUrl: 'http://prueba'))..httpClientAdapter = servidor));
    final auth = Get.put(AuthController());
    await auth.iniciarSesion('a@b.com', 'clave-1234');
    final gastos = Get.put(GastosController());
    for (var i = 0; i < 200 && gastos.gastos.isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  /// Alterna tiempo real (para que terminen las «peticiones» falsas y el disco)
  /// con avance del reloj de la prueba (para los temporizadores de dio).
  Future<void> esperarRed(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 40)));
      await tester.pump(const Duration(milliseconds: 40));
    }
  }

  Future<void> abrirGastos(WidgetTester tester) async {
    await tester.runAsync(montar);
    await tester.pumpWidget(const GetMaterialApp(home: GastosScreen()));
    await esperarRed(tester);
  }

  testWidgets('al elegir «comida» solo se ven los gastos de comida', (tester) async {
    await abrirGastos(tester);
    // De entrada («Todas») se ven los tres.
    expect(find.text('Almuerzo'), findsOneWidget);
    expect(find.text('Café'), findsOneWidget);
    expect(find.text('Taxi'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'comida'));
    await tester.pump();

    // Se comprueban las descripciones, no la categoría: el subtítulo de la fila
    // es «comida · 2026-10-08» y el chip dice «comida», así que buscar por
    // descripción no deja lugar a dudas.
    expect(find.text('Almuerzo'), findsOneWidget);
    expect(find.text('Café'), findsOneWidget);
    expect(find.text('Taxi'), findsNothing);
  });

  testWidgets('«Todas» vuelve a mostrar los gastos de todas las categorías', (tester) async {
    await abrirGastos(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'transporte'));
    await tester.pump();
    expect(find.text('Almuerzo'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Todas'));
    await tester.pump();
    expect(find.text('Almuerzo'), findsOneWidget);
    expect(find.text('Taxi'), findsOneWidget);
  });

  testWidgets('los chips solo ofrecen las categorías que aparecen en los gastos', (tester) async {
    await abrirGastos(tester);
    expect(find.widgetWithText(ChoiceChip, 'Todas'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'comida'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'transporte'), findsOneWidget);
    // El backend también define «entretenimiento» y «otros», pero no hay ningún
    // gasto de esas categorías: no deben aparecer.
    expect(find.widgetWithText(ChoiceChip, 'entretenimiento'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, 'otros'), findsNothing);
  });
}
