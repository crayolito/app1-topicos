import 'package:go_router/go_router.dart';
import 'package:topicos_app1/features/presentation/busqueda/screens/busqueda.screen.dart';
import 'package:topicos_app1/features/presentation/historial/screens/home.screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const BusquedaScreen()),
    GoRoute(path: '/chat', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
  ],
);
