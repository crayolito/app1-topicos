import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topicos_app1/config/bloc/chat/chat_bloc.dart';
import 'package:topicos_app1/config/const/colores.const.dart';
import 'package:topicos_app1/config/const/initHelpers.const.dart';
import 'package:topicos_app1/config/router/app.router.dart';

void main() {
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
