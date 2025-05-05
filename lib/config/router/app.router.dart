import 'package:go_router/go_router.dart';
import 'package:topicos_app1/features/presentation/busqueda/screens/busqueda.screen.dart';
import 'package:topicos_app1/features/presentation/chat/screens/chats.screen.dart';
import 'package:topicos_app1/features/presentation/historial/screens/bienvenida.screen.dart';
import 'package:topicos_app1/features/presentation/historial/screens/home.screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const BienvenidaScreen()),
    GoRoute(path: '/chat', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/chats', builder: (context, state) => const ChatsScreen()),
    GoRoute(
      path: '/busqueda',
      builder: (context, state) => const BusquedaScreen(),
    ),
  ],
);
