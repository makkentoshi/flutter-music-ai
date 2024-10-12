import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class HomeScreen extends StatefulWidget {
  final VoidCallback showPromptScreen;
  const HomeScreen({super.key, required this.showPromptScreen});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF330000), Color(0xFF000000)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // First Expanded
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Stack(
                  children: [
                    // Container image
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/sonnet.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.4,
                              color: const Color(0xFFFFFFFF),
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            height: 110.0,
                            width: 110.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image:
                                    AssetImage('assets/images/sonnetlogo.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Second Expanded
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                // Column starts
                child: Column(
                  children: [
                    // RichText
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            style: GoogleFonts.inter(
                              height: 1.3,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text:
                                      'AI curated music playlist just for your mood \n',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w300,
                                    color: const Color(0xFFFFFFFF),
                                  ),
                                  ),
                                   TextSpan(
                                  text:
                                      'Get Started Now! \n',
                                  style: GoogleFonts.inter(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFFFFFF),
                                  )
                                  )
                            ],
                            ),
                            ),
                            // Container for the button in padding
                            Padding(padding: const EdgeInsets.only(top:20.0),

                            // Container for arrow forward in GestureDetector

                            child: GestureDetector(
                              onTap: widget.showPromptScreen,
                              child: Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(color: const Color(0xFFFFCCCC).withOpacity(0.3), shape: BoxShape.circle ),
                                child: Container(
                                  height: 50.0,
                                  width: 50.0,
                                  padding: const EdgeInsets.all(2.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    shape: BoxShape.circle
                                  ),
                              
                                  // Arrow forward centered
                                  child:  const Center(
                                    child: Icon(Icons.arrow_forward,),
                                  ),
                              
                              
                              
                              
                                ),
                              ),
                            ),
                            )

                            //
                  ],
                ),
                // Collumn ends
              ),
            ),
          ],
        ),
      ),
    );
  }
}
