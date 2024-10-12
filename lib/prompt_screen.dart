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
                    ),

                    // Padding for genre list

                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 5.0),
                      child: StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return Wrap(
                          children: genres.map((genre) {
                            final isSelected = _selectedGenres.contains(genre);

                            // Container with border for each genre
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_selectedGenres.contains(genre)) {
                                    _selectedGenres.remove(genre);
                                  } else {
                                    _selectedGenres.add(genre);
                                  }
                                });
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(3.0),
                                  margin: const EdgeInsets.only(
                                      right: 4.0, top: 4.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      border: Border.all(
                                        width: 0.4,
                                        color: const Color(0xFFFFFFFF)
                                            .withOpacity(0.8),
                                      )),
                                  // Container for each genre

                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: isSelected
                                          ? const Color(0xFF0000FF)
                                          : const Color(0xFFFFFFFF)
                                              .withOpacity(0.8),
                                    ),

                                    // Text for each genre

                                    child: Text(
                                      genre,
                                      style: GoogleFonts.inter(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? const Color(0xFFFFFFFF)
                                            : const Color(0xFF000000),
                                      ),
                                    ),
                                  )),
                            );
                          }).toList(),
                        );
                      }),
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
