import 'package:flutter/material.dart';
import 'package:reddit_slider/slider_clipper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reddit Slider',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  //
  final pageController = PageController();
  final tabs = const ['reddit', 'Popular', 'Watch', 'Latest'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        title: SlidingHeader(tabs: tabs, pageController: pageController),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: FlutterLogo(),
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        children: [
          ...tabs.map(
            (e) => Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      pageController.previousPage(
                        duration: Durations.long4,
                        curve: Curves.ease,
                      );
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    e,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  IconButton(
                    onPressed: () {
                      pageController.nextPage(
                        duration: Durations.long4,
                        curve: Curves.ease,
                      );
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SlidingHeader extends StatefulWidget {
  const SlidingHeader({
    super.key,
    required this.tabs,
    required this.pageController,
  });

  final List<String> tabs;
  final PageController pageController;

  @override
  State<SlidingHeader> createState() => _SlidingHeaderState();
}

class _SlidingHeaderState extends State<SlidingHeader> {
  double clipOffset = 0;

  late int clippingChildIndex;
  late int reversedClippingChildIndex;

  final slideFactor = 0.2;

  @override
  void initState() {
    super.initState();

    clippingChildIndex = 0;
    reversedClippingChildIndex = clippingChildIndex + 1;

    widget.pageController.addListener(
      () {
        final page = widget.pageController.page!;
        setState(() {
          clipOffset = page - page.floor();
          clippingChildIndex = page.floor().abs();
          reversedClippingChildIndex = page.ceil().abs();
        });
      },
    );
  }

  @override
  void dispose() {
    widget.pageController.dispose();
    super.dispose();
  }

  Text textBuilder(String text) {
    return Text(
      text,
      style: switch (text) {
        'reddit' => const TextStyle(
            color: Colors.red,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        _ => const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      // Calculate the maximum width of the text elements.
      double maxTextWidth = widget.tabs.fold<double>(
        0,
        (maxWidth, text) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: text,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          return maxWidth > textPainter.width ? maxWidth : textPainter.width;
        },
      );
      return SizedBox(
        width: maxTextWidth,
        child: Stack(
          fit: StackFit.passthrough,
          alignment: Alignment.centerLeft,
          children: [
            Transform.translate(
              offset: Offset(-clipOffset * slideFactor * maxTextWidth, 0),
              child: ClipRect(
                clipper: SliderClipper(
                  position: clipOffset,
                ),
                child: textBuilder(widget.tabs[clippingChildIndex]),
              ),
            ),
            Transform.translate(
              offset: Offset((1 - clipOffset) * slideFactor * maxTextWidth, 0),
              child: ClipRect(
                clipper: SliderClipper.inverted(
                  position: clipOffset,
                ),
                child: textBuilder(widget.tabs[reversedClippingChildIndex]),
              ),
            ),
          ],
        ),
      );
    });
  }
}
