import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:topicos_app1/config/bloc/chat/chat_bloc.dart';
import 'package:topicos_app1/config/const/colores.const.dart';
import 'package:topicos_app1/config/const/generalizador.const.dart';

class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  @override
  void initState() {
    super.initState();
    final chatBloc = BlocProvider.of<ChatBloc>(context);
    chatBloc.add(OnContruccionDatos());

    Future.delayed(const Duration(seconds: 5), () {
      // ignore: use_build_context_synchronously
      context.go("/chat");
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state.estadoDatos == EstadoDatos.exito ||
            state.estadoDatos == EstadoDatos.error) {
          // context.go("/chat");
        }
      },
      child: Scaffold(
        backgroundColor: colorTerciario,
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/logoApp.png",
                      width: size.width * 0.3,
                      height: size.height * 0.15,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text("RODALEX", style: textos.textoBienvenida),
                  ],
                ),
              ),
              Positioned(
                bottom: size.height * 0.03,
                left: 0,
                right: 0,
                child: Center(
                  child: Text("BY UAGRM", style: textos.textoBienvenida2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
