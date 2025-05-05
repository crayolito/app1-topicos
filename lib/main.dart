import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topicos_app1/config/bloc/chat/chat_bloc.dart';
import 'package:topicos_app1/config/const/colores.const.dart';
import 'package:topicos_app1/config/const/initHelpers.const.dart';
import 'package:topicos_app1/config/router/app.router.dart';
import 'package:topicos_app1/features/services/basedatos.service.dart';

void main() async {
  // Es importante llamar a esto antes de cualquier interacción nativa
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar el servicio de base de datos
  try {
    final ServicioBaseDatos dbService = ServicioBaseDatos();

    // Solo inicializar la base de datos
    await dbService.database;

    // No hacemos nada más aquí - la inicialización y carga
    // de datos se manejan internamente en la clase ServicioBaseDatos
    print('Base de datos inicializada correctamente');
  } catch (e) {
    // Si hay un error, solo lo registramos pero permitimos que la app continúe
    print('Error al inicializar la base de datos: $e');
  }

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (context) => ChatBloc())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: colorTerciario,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Builder(
      builder: (context) {
        InitHelpers.inicializar(context);

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
        );
      },
    );
  }
}
