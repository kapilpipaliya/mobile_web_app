import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_web/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'core/navigator/app_router.dart';
import 'core/theme/app_theme.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
          builder: (context, ThemeProvider themeNotifier, child) {
        return MaterialApp.router(
          title: 'Mobile web',
          theme: (themeNotifier.isDark) ? ThemeData.dark() : ThemeData.light(),
          backButtonDispatcher: RootBackButtonDispatcher(),
          routeInformationParser: _appRouter.defaultRouteParser(),
          routerDelegate: _appRouter.delegate(
            navigatorObservers: () => [],
          ),
          debugShowCheckedModeBanner: false,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        );
      }),
    );
  }
}
