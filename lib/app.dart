import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OpenStackApp extends StatelessWidget {
  const OpenStackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _HelloScreen(),
      ),
    );
  }
}

class _HelloScreen extends StatelessWidget {
  const _HelloScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('OpenStack — Flutter skeleton is ready ✅')),
    );
  }
}
