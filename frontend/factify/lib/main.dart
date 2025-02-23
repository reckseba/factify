import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

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
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
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

void main() {
  runApp(const MyApp());
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
  Future<List<dynamic>>? _jsonData; // Store the future

  @override
  void initState() {
    super.initState();
    _jsonData = _loadJsonData(); // Start loading in initState
  }

  Future<List<dynamic>> _loadJsonData() async {
    final String jsonString = await rootBundle.loadString(
      'assets/relevante-personen.json',
    ); // Load from assets
    final List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _jsonData, // Use the stored future
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          ); // Show loading indicator
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          ); // Show error message
        } else {
          final data =
              snapshot
                  .data!; // Access the loaded data (non-null assertion is safe here)
          // print(data);

          List<Container> cards =
              data.map((card) {
                final bgColor = getRandomMaterialColor();
                final textColor = getComplementaryTextColor(bgColor);
                return Container(
                  alignment: Alignment.center,
                  color: bgColor,
                  child: Center(
                    child: Text(
                      card['claim'] ?? '',
                      style: TextStyle(color: textColor, fontSize: 50),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList();

          return Swiper(cards: cards);
        }
      },
    );
  }
}

class MyDataWidget extends StatelessWidget {
  final List<dynamic> data;

  const MyDataWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          print("-------------------------------\n\n");

          final item = data[index]; // Access each item in the array

          return ListTile(
            title: Text(
              item['person'] ?? '',
            ), // Access properties of the object
            subtitle: Text(item['claim'] ?? ''),
          );
        },
      ),
    );
  }
}

class Swiper extends StatelessWidget {
  final List<dynamic> cards;

  Swiper({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("factify"),
      ),
      body: Center(
        child: CardSwiper(
          cardsCount: cards.length,
          cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
            return cards[index];
          },
        ),
      ),
    );
  }
}
