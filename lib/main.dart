import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restopos/config/router_config.dart';
import 'package:restopos/core/network/dio_client.dart';
import 'package:restopos/widget/session_manager.dart';
import 'package:restopos/core/services/token_service.dart';
import 'package:restopos/core/guards/auth_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔑 Verificar si existe sesión antes de iniciar la app
  final hasSession = await TokenService.hasValidSession();

  runApp(
    ProviderScope(
      overrides: [
        initialSessionProvider.overrideWithValue(hasSession),
      ],
      child: const App(),
    ),
  );
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();

    final goRouter = ref.read(goRouterProvider);
    ApiClient.init(goRouter);
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(goRouterProvider);

    // Registrar contexto global seguro
    SessionManager().setContext(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'RestoPos',

      routerConfig: goRouter,

      locale: const Locale('es', 'CO'),
      supportedLocales: const [
        Locale('es', 'CO'),
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}