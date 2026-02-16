import 'package:flutter/material.dart';
import 'package:scroll_edge_hint/scroll_edge_hint.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scroll Edge Hint Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A7E8C)),
      ),
      home: const DemoHome(),
    );
  }
}

class DemoHome extends StatelessWidget {
  const DemoHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scroll Edge Hint'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Vertical'),
              Tab(text: 'Horizontal'),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[VerticalListDemo(), HorizontalChipsDemo()],
        ),
      ),
    );
  }
}

class VerticalListDemo extends StatelessWidget {
  const VerticalListDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollEdgeHint.builder(
      extent: 24,
      fadeInDistance: 28,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      builder: (BuildContext context, ScrollController controller) {
        return ListView.separated(
          controller: controller,
          padding: const EdgeInsets.all(16),
          itemCount: 40,
          separatorBuilder: (_, int separatorIndex) =>
              const SizedBox(height: 8),
          itemBuilder: (_, int index) {
            return ListTile(
              tileColor: Theme.of(context).colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text('Item $index'),
              subtitle: const Text(
                'Scroll to see edge hints change naturally.',
              ),
            );
          },
        );
      },
    );
  }
}

class HorizontalChipsDemo extends StatefulWidget {
  const HorizontalChipsDemo({super.key});

  @override
  State<HorizontalChipsDemo> createState() => _HorizontalChipsDemoState();
}

class _HorizontalChipsDemoState extends State<HorizontalChipsDemo> {
  bool _isRtl = false;

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = _isRtl
        ? TextDirection.rtl
        : TextDirection.ltr;

    return Column(
      children: <Widget>[
        SwitchListTile(
          title: const Text('RTL preview'),
          subtitle: const Text('Check leading/trailing placement in RTL.'),
          value: _isRtl,
          onChanged: (bool value) => setState(() => _isRtl = value),
        ),
        Expanded(
          child: Directionality(
            textDirection: direction,
            child: Center(
              child: SizedBox(
                height: 96,
                child: ScrollEdgeHint.builder(
                  extent: 26,
                  fadeInDistance: 30,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  builder: (BuildContext context, ScrollController controller) {
                    return ListView.separated(
                      controller: controller,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 30,
                      separatorBuilder: (_, int separatorIndex) =>
                          const SizedBox(width: 8),
                      itemBuilder: (_, int index) {
                        return Chip(label: Text('Tag $index'));
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
