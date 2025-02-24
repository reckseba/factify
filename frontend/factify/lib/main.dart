import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

MaterialColor getRandomMaterialColor() {
  // Generate a random hue value (0-360).
  final random = Random();

  // Define a list of available MaterialColor primary swatches.  You can customize this.
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'factify',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<dynamic>>? _jsonData;
  Future<List<dynamic>>? _supaData;

  @override
  void initState() {
    super.initState();
    _jsonData = _loadJsonData(); // Start loading in initState
    _supaData = _loadSupaData();
  }

  Future<List<dynamic>> _loadJsonData() async {
    final String jsonString = await rootBundle.loadString(
      'assets/relevante-personen.json',
    ); // Load from assets
    final List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData;
  }

  Future<List<dynamic>> _loadSupaData() async {
    final supabase = Supabase.instance.client;
    final myQuery = supabase.from('facts').select();
    return await myQuery.gt('id', 0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _supaData, //_jsonData
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final data = snapshot.data!;

          List<Container> cards =
              data.map((card) {
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
                Container(
                  margin: EdgeInsets.only(bottom: 50),
                  child: Swiper(cards: cards, data: data),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    // Center horizontally
                    child: ElevatedButton(
                      onPressed: () {
                        Share.share('check out my website https://example.com');
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(30), // button size
                      ),
                      child: const Icon(Icons.share),
                    ),
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

void _showMyDialog(context, data, direction) {
  final guessIsCorrect =
      direction == CardSwiperDirection.right && data['correct'] == true ||
      direction == CardSwiperDirection.left && data['correct'] == false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          (guessIsCorrect ? 'Ja' : 'Nein') +
              ', diese Aussage ist ' +
              (data['correct'] ? 'RICHTIG' : 'FALSCH'),
        ),
        content: Text(data['person'] + '\n\n ' + data['explanation']),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
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

class Swiper extends StatelessWidget {
  final List<dynamic> cards;
  final List<dynamic> data;

  Swiper({super.key, required this.cards, required this.data});

  @override
  Widget build(BuildContext context) {
    return CardSwiper(
      cardsCount: cards.length,
      cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
        return cards[index];
      },
      onSwipe: (previousIndex, currentIndex, direction) {
        _showMyDialog(context, data[previousIndex], direction);
        return true;
      },
    );
  }
}
