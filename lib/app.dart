// lib/app.dart
import 'package:dhyana/providers/router_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dhyana/providers/theme_provider.dart';
import 'package:dhyana/core/theme/app_theme.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeModeAsync = ref.watch(themeProvider);

    return themeModeAsync.when(
      data: (themeMode) {
        return MaterialApp.router(
          routerConfig: router,
          title: 'Dhyana',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
        );
      },
      loading: () => const MaterialApp(
        home: Scaffold(
            body: Center(child: LoadingWidget(message: "Loading Theme..."))),
      ),
      error: (err, stack) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Error loading theme: $err'))),
      ),
    );
  }
}