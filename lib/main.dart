import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MatriculaApp());
}

class MatriculaApp extends StatelessWidget {
  const MatriculaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matrícula App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
