import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'myITS App',
      theme: ThemeData(
  
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F4D92)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'myITS'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB0E0E6), 
      
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4D92), 
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white), 
        ),
      ),
      
      body: Center(
        child: Text(
          'Welcome',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            color: Color.fromARGB(255, 191, 129, 13),
          ),
        ),
      ),
    );
  }
}