import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

MaterialColor getRandomMaterialColor() {
  final random = Random();
  final materialColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
  ];
  return materialColors[random.nextInt(materialColors.length)];
}

Color getComplementaryTextColor(MaterialColor backgroundColor) {
  // Calculate the relative luminance of the background color.
  // This is a measure of how bright a color appears.
  double luminance = backgroundColor.computeLuminance();

  // Choose a text color based on the luminance.
  // If the background is dark, use a light text color (white).
  // If the background is light, use a dark text color (black).
  return luminance > 0.5 ? Colors.black : Colors.white;
}

void shareFact(factRaw) {
  final text =
      factRaw['person'] +
      ' behauptete ' +
      (factRaw['correct'] ? 'richtigerweise' : 'fälschlicherweise') +
      ': ' +
      factRaw['claim'] +
      '\n\nErklärung: ' +
      factRaw['explanation'];
  Share.share(text);
}

void showSolution(context, factRaw, direction) {
  final guessIsCorrect =
      direction == CardSwiperDirection.right && factRaw['correct'] == true ||
      direction == CardSwiperDirection.left && factRaw['correct'] == false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          (guessIsCorrect ? 'Ja' : 'Nein') +
              ', diese Aussage ist ' +
              (factRaw['correct'] ? 'RICHTIG' : 'FALSCH'),
        ),
        content: Text(factRaw['person'] + '\n\n' + factRaw['explanation']),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              shareFact(factRaw);
            },
            child: Text('Share'),
          ),
          TextButton(
            onPressed: () {
              // Perform action and close the dialog
              Navigator.of(context).pop();
              // ... your callback logic here ...
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://aqfdfftbmmfnpzeeigez.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFxZmRmZnRibW1mbnB6ZWVpZ2V6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA0MDM3OTcsImV4cCI6MjA1NTk3OTc5N30.YByyfRq8aCBxwZUUhGGuj9-xp7ciB1g99rgNAKNTDUs',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'factify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CardSwiperController controller = CardSwiperController();
  Future<List<dynamic>>? _supaData;

  @override
  void initState() {
    super.initState();
    _supaData = _loadSupaData();
  }

  Future<List<dynamic>> _loadSupaData() async {
    final supabase = Supabase.instance.client;
    final myQuery = supabase.from('facts').select();
    return await myQuery.gt('id', 0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _supaData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final factsRaw = snapshot.data!;

          List<Container> factsContainer =
              factsRaw.map((card) {
                final bgColor = getRandomMaterialColor();
                final textColor = getComplementaryTextColor(bgColor);
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: bgColor,
                  ),
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    card['claim'] ?? '',
                    style: TextStyle(color: textColor, fontSize: 40),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                );
              }).toList();

          return Scaffold(
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 30,
                  child: Container(color: Colors.black),
                ),
                Container(
                  margin: EdgeInsets.only(top: 50, bottom: 70),
                  child: Swiper(
                    factsContainer: factsContainer,
                    factsRaw: factsRaw,
                    controller: controller,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center, // Center the buttons horizontally
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          controller.swipe(CardSwiperDirection.left);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20), // button size
                          iconColor: Colors.red.shade100,
                          backgroundColor: Colors.red.shade600,
                          shadowColor: Colors.transparent,
                          elevation: 5,
                        ),
                        child: const Icon(Icons.close_rounded, size: 25),
                      ),
                      const SizedBox(
                        width: 16.0,
                      ), // Add spacing between buttons
                      ElevatedButton(
                        onPressed: () {
                          controller.swipe(CardSwiperDirection.right);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20), // button size
                          iconColor: Colors.green.shade100,
                          backgroundColor: Colors.green.shade600,
                          shadowColor: Colors.transparent,
                          elevation: 5,
                        ),
                        child: const Icon(Icons.check_rounded, size: 25),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class Swiper extends StatelessWidget {
  final List<dynamic> factsContainer;
  final List<dynamic> factsRaw;
  final CardSwiperController controller;

  Swiper({
    super.key,
    required this.factsContainer,
    required this.factsRaw,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CardSwiper(
      controller: controller,
      cardsCount: factsContainer.length,
      cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
        return factsContainer[index];
      },
      onSwipe: (previousIndex, currentIndex, direction) {
        showSolution(context, factsRaw[previousIndex], direction);
        return true;
      },
    );
  }
}
