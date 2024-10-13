import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp/random_circles.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

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

  // Selected mood

  String? _selectedMood;

  // Selected mood image

  String? _selectedMoodImage;

  // Playlist

  List<Map<String, String>> _playlist = [];

  // Loading state
  bool _isLoading = false;

  // Function to toggle genre

  void _onGenreTap(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
  }

  // Function submit mood and genres

  Future<void> _submitSelections() async {
    // Load enviroment variables
    await dotenv.load(fileName: ".env");

    final String? apiKey = dotenv.env['gemini_token'];

    if (apiKey == null) {
      print('There is no API  in .env');
      return;
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    //

    if (_selectedMood == null || _selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please, select a mood and at least one genre")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final promptText = 'I want a playlist for '
        'Mood: $_selectedMood, Genres: ${_selectedGenres.join(', ')}'
        'in the format artist, title';

    try {
      // Content

      final response = await model.generateContent([Content.text(promptText)]);

      print('Response text: ${response.text}');

      if (response.text != null) {
        // Markdown 
        String responseText = response.text!;

        // Seperate lines
        List<String> lines = responseText.split('\n');

        // Filter out lines that don't contain songs
        List<String> songs =
            lines.where((line) => line.contains(' - ')).toList();

        
        _playlist = songs.map((song) {
          var parts = song.split(' - ');
          return {
            'artist': parts[0].trim(), 
            'title': parts.length > 1
                ? parts[1].replaceAll('"', '').trim()
                : 'Unknown title'
          };
        }).toList();

       
        print('Parsed playlist: $_playlist');
      } else {
        throw Exception('Failed to generate content');
      }
    } catch (error, stackTrace) {
    
      print('Error: $error');
      print('StackTrace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'), 
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

              Expanded(
                child: RandomCircles(
                  onMoodSelected: (mood, image) {
                    _selectedMood = mood;
                    _selectedMoodImage = image;
                  },
                ),
              ),

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
                    ),

                    // Padding around the submit button

                    Padding(
                      padding: const EdgeInsets.only(
                          top: 60.0, left: 10.0, right: 10.0),

                      // Container for submit button in GestureDetector
                      child: GestureDetector(
                        onTap: _submitSelections,
                        // Container for submit button
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: const Color(0xFFFFCCCCC).withOpacity(0.8),
                          ),

                          // Submit text centered

                          child: Center(
                            // Submit text
                            child: Text(
                              "Submit",
                              style: GoogleFonts.inter(
                                  fontSize: 14.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
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
