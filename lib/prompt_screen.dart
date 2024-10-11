import 'package:flutter/material.dart';

class PromptScreen extends StatefulWidget {
   final VoidCallback showHomeScreen;
  const PromptScreen({super.key, required this.showHomeScreen});

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      
    );
  }
}