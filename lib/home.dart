import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

double _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.width;
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final String AppTitle = "GPU Memory Model";
    final String AppGuide = "App Guide";
    final String AppPageLayout = "Test Page Layout";
    final TextStyle AppTitleStyle = TextStyle(
        color: Colors.black,
        fontSize: screenWidth * 0.045,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        height: 1,
    );
    final TextStyle SubTitleStyle = TextStyle(
        color: Colors.black,
        fontSize: screenWidth * 0.036,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        height: 1,
    );

    return Scaffold(
      body: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Container(
                    width: screenWidth,
                    height: screenHeight,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: Colors.white),
                    child: Stack(
                      children: [
                        Positioned(//title
                          left: screenWidth * 0.04,
                          top: screenHeight * 0.10,
                          child: Text(
                              'GPU Memory Model Tests',
                              style: AppTitleStyle,
                          ),
                        ),
                        Positioned( //bar under title
                          left: screenWidth * 0.04,
                          top: screenHeight * 0.125,
                          child: Container(
                            width: screenWidth * 0.60,
                            height: screenHeight * 0.004,
                            decoration: BoxDecoration(color: Color(0xFF1F3DD2)),
                          ),
                        ),
                        Positioned(//logo
                          left: screenWidth * .75,
                          top: screenHeight * 0.08,
                          child: Container(
                            width: screenWidth * .12,
                            height: screenHeight * .05,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/logo.png'),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                        Positioned(//app description box
                          left: screenWidth * 0.04,
                          top: screenHeight * 0.155,
                          child: Container(
                            width: screenWidth * 0.90,
                            height: screenHeight * 0.11,
                            decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                          ),
                        ),
                        Positioned(//app description text
                          left: screenWidth * 0.05,
                          top: screenHeight * 0.160,
                          child: SizedBox(
                            width: screenWidth * 0.85,
                            height: screenHeight * 0.115,
                            child: Text(
                              'This application is focused on testing mobile GPU’s memory models, which specifies the semantics and rules threads must follow when sharing memory. Specifically, we use litmus tests, small parallel programs that showcase the allowed behaviors of a given memory model.',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.03,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                        Positioned(//app guide title
                          left: screenWidth * 0.04,
                          top: screenHeight * 0.289,
                          child: SizedBox(
                            width: screenWidth * .5,
                            height: screenHeight * 0.02125,
                            child: Text(
                              'App Guide',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.036,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                        Positioned( //bar under title
                          left: screenWidth * 0.04,
                          top: screenHeight * 0.31,
                          child: Container(
                            width: _textSize(AppGuide, SubTitleStyle),
                            height: screenHeight * 0.003,
                            decoration: BoxDecoration(color: Color(0xFF1F3DD2)),
                          ),
                        ),
                        Positioned(//app guide box
                          left: screenWidth * 0.04,
                          top: screenHeight * 0.33,
                          child: Container(
                            width: screenWidth * 0.90,
                            height: screenHeight * 0.22,
                            decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                          ),
                        ),
                        Positioned(//app guide text
                          left: screenWidth * 0.05,
                          top: screenHeight * 0.335,
                          child: SizedBox(
                            width: screenWidth * 0.85,
                            height: screenHeight * 0.20,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'The goals of this app are to explore ways to better test memory models and to use the results to empirically verify the implementation of mobile GPU’s memory models. In order to do this, we define a suite of litmus tests, which are available by clicking the tests icon.\n\nThis suite comprises of ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenWidth * 0.03,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Weak Memory Tests: ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenWidth * 0.03,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'These test the semantics of memory when two threads access multiple memory locations concurrently, specifically whether hardware is allowed to re-order certain combinations of reads and writes to different memory locations.',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenWidth * 0.03,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(//test page layout title
                          left: screenWidth * 0.04,
                          top: screenHeight * 0.59,
                          child: SizedBox(
                            width: screenWidth * .5,
                            height: screenHeight * 0.289,
                            child: Text(
                              'Test Page Layout',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.036,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                        Positioned( //bar under title
                          left: screenWidth * 0.04,
                          top: screenHeight * 0.61,
                          child: Container(
                            width: _textSize(AppPageLayout, SubTitleStyle),
                            height: screenHeight * 0.003,
                            decoration: BoxDecoration(color: Color(0xFF1F3DD2)),
                          ),
                        ),
                        Positioned(//layout guide box
                          left: screenWidth * 0.04,
                          top: screenHeight * 0.63,
                          child: Container(
                            width: screenWidth * 0.90,
                            height: screenHeight * 0.22,
                            decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                          ),
                        ),
                        Positioned(//app layout guide text
                          left: screenWidth * 0.05,
                          top: screenHeight * 0.635,
                          child: SizedBox(
                            width: screenWidth * 0.85,
                            height: screenHeight * 0.20,
                            child: Text(
                              'Each test page contains a brief description of the program under test, as well as pseudocode showing the instructions executed by each thread. The psuedocode also shows where each thread executes relative to the other and calls out the behavior of interest.\n\nThe test page contains an explorer mode, where users can try different combinations of parameters to induce interesting behaviors. A few preset parameter sets are included to test quickly. Clicking "Start Test" runs the test, displaying the results in the histogram in real time.',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.03,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
        ),
      ),
    );
  }
}