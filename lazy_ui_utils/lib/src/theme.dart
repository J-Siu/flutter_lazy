import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

/// Wrapper function to setup a default [ThemeProvider] from 'package:theme_provider/theme_provider.dart'
/// - [child] should not be wrapped inside [MaterialApp], as the function is already doing it
/// - [debugShowCheckedModeBanner] will be passed on to [MaterialApp] inside
///
/// Example
/// ```dart
/// import 'package:lazy/lazy.dart';
/// class MyApp extends StatelessWidget {
///   const MyApp({Key? key}) : super(key: key);
///
///   @override
///   Widget build(BuildContext context) {
///     return lazy.themeProvider(
///       debugShowCheckedModeBanner: false,
///       context: context,
///       child: Home(),
///     );
///   }
/// }
/// ```
ThemeProvider themeProvider({
  bool debugShowCheckedModeBanner = false,
  required BuildContext context,
  required Widget child,
}) {
  void themeProviderAuto(
    ThemeController controller,
  ) {
    Brightness platformBrightness =
        View.of(context).platformDispatcher.platformBrightness;
    // SchedulerBinding.instance.window.platformBrightness;
    platformBrightness == Brightness.dark
        ? controller.setTheme('dark')
        : controller.setTheme('light');
    controller.forgetSavedTheme();
  }

  void themeProviderOnInitialCallBack(
    controller,
    previouslySavedThemeFuture,
  ) async {
    String? savedTheme = await previouslySavedThemeFuture;
    savedTheme != null
        ? controller.setTheme(savedTheme)
        : themeProviderAuto(controller);
  }

  return ThemeProvider(
    saveThemesOnChange: true,
    loadThemeOnInit: false,
    onInitCallback: themeProviderOnInitialCallBack,
    themes: <AppTheme>[
      AppTheme.light(id: 'light'),
      AppTheme.dark(id: 'dark'),
    ],
    child: ThemeConsumer(
      child: Builder(
        builder: (context) => MaterialApp(
          debugShowCheckedModeBanner: debugShowCheckedModeBanner,
          theme: ThemeProvider.themeOf(context).data,
          home: child,
        ),
      ),
    ),
  );
}
