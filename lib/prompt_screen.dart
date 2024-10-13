import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp/random_circles.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

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
          String artist =
              parts[0].replaceAll('*', '').replaceAll('**', '').trim();
          String title = parts.length > 1
              ? parts[1]
                  .replaceAll('*', '')
                  .replaceAll('**', '')
                  .replaceAll('"', '')
                  .trim()
              : 'Unknown title';
          return {
            'artist': artist,
            'title': title,
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

  Future<void> _openSpotify() async {
    final playlistQuery = _playlist
        .map((song) => '${song['artist']} - ${song['title']}')
        .join(', ');
    final url = Uri.parse('https://open.spotify.com/search/$playlistQuery');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _openAudiomack() async {
    final playlistQuery = _playlist
        .map((song) => '${song['artist']} - ${song['title']}')
        .join(', ');
    final url = Uri.parse('https://audiomack.com/search/$playlistQuery');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showFirstColumn() {
    setState(() {
      _playlist = [];
      _selectedGenres.clear();
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
              padding:
                  const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0),
              child: _isLoading
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        height: 50.0,
                        width: 50.0,
                        decoration: const BoxDecoration(
                            color: Color(0xFFFFFFFF), shape: BoxShape.circle),
                        child: const CircularProgressIndicator(
                          color: const Color(0xFF0000000),
                        ),
                      ),
                    )
                  : _playlist.isEmpty
                      ? Column(
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
                                        color: const Color(0xFFFFFFFF)
                                            .withOpacity(0.8)),
                                  ),

                                  // Padding for genre list

                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0, top: 5.0),
                                    child: StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
                                      return Wrap(
                                        children: genres.map((genre) {
                                          final isSelected =
                                              _selectedGenres.contains(genre);

                                          // Container with border for each genre
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (_selectedGenres
                                                    .contains(genre)) {
                                                  _selectedGenres.remove(genre);
                                                } else {
                                                  _selectedGenres.add(genre);
                                                }
                                              });
                                            },
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                margin: const EdgeInsets.only(
                                                    right: 4.0, top: 4.0),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                    border: Border.all(
                                                      width: 0.4,
                                                      color: const Color(
                                                              0xFFFFFFFF)
                                                          .withOpacity(0.8),
                                                    )),
                                                // Container for each genre

                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 8.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                    color: isSelected
                                                        ? const Color(
                                                            0xFF0000FF)
                                                        : const Color(
                                                                0xFFFFFFFF)
                                                            .withOpacity(0.8),
                                                  ),

                                                  // Text for each genre

                                                  child: Text(
                                                    genre,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: isSelected
                                                          ? const Color(
                                                              0xFFFFFFFF)
                                                          : const Color(
                                                              0xFF000000),
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          color: const Color(0xFFFFCCCCC)
                                              .withOpacity(0.8),
                                        ),

                                        // Submit text centered

                                        child: Center(
                                          // Submit text
                                          child: Text(
                                            "Submit",
                                            style: GoogleFonts.inter(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ))
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Stack(
                              children: [
                                Row(
                                  // Button to Create Playlist
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                  title: Text(
                                                    'Create Playlist on?',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  content: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: _openSpotify,
                                                        child: Container(
                                                          height: 50.0,
                                                          width: 50.0,
                                                          decoration: const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              image: DecorationImage(
                                                                  image: AssetImage(
                                                                      "assets/images/spotify.png"),
                                                                  fit: BoxFit
                                                                      .cover)),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 8.0,
                                                      ),
                                                      GestureDetector(
                                                        onTap: _openAudiomack,
                                                        child: Container(
                                                          height: 50.0,
                                                          width: 50.0,
                                                          decoration: const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              image: DecorationImage(
                                                                  image: AssetImage(
                                                                      "assets/images/audiomack.png"),
                                                                  fit: BoxFit
                                                                      .cover)),
                                                        ),
                                                      ),
                                                    ],
                                                  ));
                                            });
                                      },
                                      child: Container(
                                        height: 40.0,
                                        width: 40.0,
                                        decoration: const BoxDecoration(
                                            color: Color(0xFFFFFFFF),
                                            shape: BoxShape.circle),
                                        child: const Center(
                                          child:
                                              Icon(Icons.playlist_add_rounded),
                                        ),
                                      ),
                                    )
                                  ],
                                ),

                                // Padding for playlist

                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 40.0,
                                  ),
                                  // Selected mood image
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: _selectedMoodImage != null
                                        ? BoxDecoration(
                                            image: DecorationImage(
                                            image:
                                                AssetImage(_selectedMoodImage!),
                                            fit: BoxFit.contain,
                                          ))
                                        : null,
                                  ),
                                ),
                                Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      padding: const EdgeInsets.all(3.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          border: Border.all(
                                              color: const Color(0xFFFFFFFF)
                                                  .withOpacity(0.4),
                                              width: 0.4)),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 8.0),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFFFFFFF)
                                                .withOpacity(0.8),
                                            borderRadius:
                                                BorderRadius.circular(20.0)),
                                        // Selected Mood Text
                                        child: Text(
                                          _selectedMood ?? '',
                                          style: GoogleFonts.inter(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF000000),
                                          ),
                                        ),
                                      ),
                                    ))
                              ],
                            )),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Container(
                                margin: const EdgeInsets.only(top: 20.0),
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  border: const Border(
                                    top: BorderSide(
                                      width: 0.4,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child:
                                    // Playlist text here
                                    Text(
                                  'Playlist',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFFFFFF)
                                        .withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  padding: const EdgeInsets.all(0.0),
                                  itemCount: _playlist.length,
                                  itemBuilder: (context, index) {
                                    final song = _playlist[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0,
                                          right: 16.0,
                                          bottom: 20.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFCCCC)
                                              .withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFFCCCC)
                                                    .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              child: Container(
                                                width: 65.0,
                                                height: 65.0,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFFFFFFF),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  image: const DecorationImage(
                                                    image: AssetImage(
                                                        'assets/images/sonnetlogo.png'),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                    child: Text(
                                                      song['artist']!
                                                          .substring(0),
                                                      style: const TextStyle(
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: const Color(
                                                            0xFFFFFFFF),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                    child: Text(
                                                      song['title']!,
                                                      style: const TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: const Color(
                                                            0xFFFFFFFF),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      maxLines: 1,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            )
                          ],
                        )),
        ),
        floatingActionButton: _playlist.isEmpty
            ? Container()
            : Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCCCC).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  onPressed: _showFirstColumn,
                  child: const Icon(
                    Icons.add_outlined,
                  ),
                )));
  }
}
