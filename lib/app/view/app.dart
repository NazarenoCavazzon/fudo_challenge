import 'package:client/client.dart';
import 'package:data_persistence/data_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fudo_challenge/create_post/create_post.dart';
import 'package:fudo_challenge/home/home.dart';
import 'package:fudo_challenge/l10n/l10n.dart';
import 'package:fudo_challenge/login/login.dart';
import 'package:go_router/go_router.dart';

class App extends StatefulWidget {
  const App({
    required this.dataPersistenceRepository,
    super.key,
  });

  final DataPersistenceRepository dataPersistenceRepository;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final _router = router(context);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => Client(),
        ),
        RepositoryProvider(
          create: (context) => widget.dataPersistenceRepository,
        ),
      ],
      child: MaterialApp.router(
        theme: ThemeData(useMaterial3: true),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerDelegate: _router.routerDelegate,
        routeInformationProvider: _router.routeInformationProvider,
        routeInformationParser: _router.routeInformationParser,
      ),
    );
  }

  GoRouter router(BuildContext context) {
    final isLogged = widget.dataPersistenceRepository.isLoggedIn;

    return GoRouter(
      redirect: (context, state) {
        if (!isLogged) {
          return LoginPage.route;
        }
        return null;
      },
      initialLocation: isLogged ? HomePage.route : LoginPage.route,
      routes: <GoRoute>[
        GoRoute(
          path: LoginPage.route,
          name: LoginPage.route,
          builder: (context, state) => LoginPage(key: state.pageKey),
        ),
        GoRoute(
          path: HomePage.route,
          name: HomePage.route,
          builder: (context, state) => HomePage(key: state.pageKey),
        ),
        GoRoute(
          path: CreatePostPage.route,
          name: CreatePostPage.route,
          builder: (context, state) => CreatePostPage(key: state.pageKey),
        ),
      ],
    );
  }
}
