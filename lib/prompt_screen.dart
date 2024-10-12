import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PromptScreen extends StatefulWidget {
  final VoidCallback showHomeScreen;
  const PromptScreen({super.key, required this.showHomeScreen});

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  //Genre List

  final List<String> genres = [
    "Jazz",
    "Rock",
    "Amapiano",
    "Rap",
    "Hip-Hop",
    "R&B",
    "Punk",
    "Pop",
    "Blues",
    "Gospel",
    "Country",
    "Metal",
    "Hip-Life",
    "Latin"
  ];

  // Selected Genre List

  final Set<String> _selectedGenres = {};

  // Functoin to toggle genre

  void _onGenreTap(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Container for all content

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF330000), Color(0xFF000000)],
          ),
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        // Padding around content
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First expanded for moods

              const Expanded(
                  child: Center(
                      child: Text(
                "Mood",
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ))),

              // Second expanded for genres and submit

              Expanded(
                  // Column for various genres and submit button in a padding
                  child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                // Column for various genres and submit button
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Genre Text
                    Text(
                      "Genre",
                      style: GoogleFonts.inter(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFFFFF).withOpacity(0.8)),
                    )
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
