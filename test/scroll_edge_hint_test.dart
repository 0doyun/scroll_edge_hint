import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_edge_hint/scroll_edge_hint.dart';

void main() {
  group('ScrollEdgeHint', () {
    testWidgets(
      'Case A: initial state shows only trailing in long vertical list',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildVerticalList(itemCount: 100));
        await tester.pump();

        final double leading = _opacity(
          tester,
          const Key('scroll_edge_hint_leading_opacity'),
        );
        final double trailing = _opacity(
          tester,
          const Key('scroll_edge_hint_trailing_opacity'),
        );

        expect(leading, closeTo(0, 0.01));
        expect(trailing, greaterThan(0));
      },
    );

    testWidgets('Case B: after scrolling to end, trailing is hidden', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildVerticalList(itemCount: 100));
      await tester.pump();

      await _scrollToEnd(tester, find.byType(ListView));

      final double leading = _opacity(
        tester,
        const Key('scroll_edge_hint_leading_opacity'),
      );
      final double trailing = _opacity(
        tester,
        const Key('scroll_edge_hint_trailing_opacity'),
      );

      expect(leading, greaterThan(0));
      expect(trailing, closeTo(0, 0.01));
    });

    testWidgets('Case C: short content shows no hint', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildVerticalList(itemCount: 2));
      await tester.pump();

      expect(
        _opacity(tester, const Key('scroll_edge_hint_leading_opacity')),
        closeTo(0, 0.01),
      );
      expect(
        _opacity(tester, const Key('scroll_edge_hint_trailing_opacity')),
        closeTo(0, 0.01),
      );
    });

    testWidgets('Case D: horizontal scroll has initial one-sided hint', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 80,
              child: ScrollEdgeHint.builder(
                animationDuration: Duration.zero,
                builder: (BuildContext context, ScrollController controller) {
                  return ListView.builder(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    itemCount: 30,
                    itemBuilder: (_, int index) => SizedBox(
                      width: 120,
                      child: Center(child: Text('Item $index')),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final double leading = _opacity(
        tester,
        const Key('scroll_edge_hint_leading_opacity'),
      );
      final double trailing = _opacity(
        tester,
        const Key('scroll_edge_hint_trailing_opacity'),
      );

      expect(leading, closeTo(0, 0.01));
      expect(trailing, greaterThan(0));
    });

    testWidgets(
      'Case E: reverse=true flips visual leading/trailing positions',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 200,
                child: ScrollEdgeHint.builder(
                  animationDuration: Duration.zero,
                  builder: (BuildContext context, ScrollController controller) {
                    return ListView.builder(
                      controller: controller,
                      reverse: true,
                      itemCount: 60,
                      itemBuilder: (_, int index) => SizedBox(
                        height: 48,
                        child: Center(child: Text('Item $index')),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        final Rect leadingRect = tester.getRect(
          find.byKey(const Key('scroll_edge_hint_leading_hint')),
        );
        final Rect trailingRect = tester.getRect(
          find.byKey(const Key('scroll_edge_hint_trailing_hint')),
        );

        expect(trailingRect.top, lessThan(leadingRect.top));
      },
    );
  });
}

Widget _buildVerticalList({required int itemCount}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 200,
        child: ScrollEdgeHint.builder(
          animationDuration: Duration.zero,
          builder: (BuildContext context, ScrollController controller) {
            return ListView.builder(
              controller: controller,
              itemCount: itemCount,
              itemBuilder: (_, int index) => SizedBox(
                height: 48,
                child: Center(child: Text('Item $index')),
              ),
            );
          },
        ),
      ),
    ),
  );
}

double _opacity(WidgetTester tester, Key key) {
  return tester.widget<Opacity>(find.byKey(key)).opacity;
}

Future<void> _scrollToEnd(WidgetTester tester, Finder finder) async {
  for (int i = 0; i < 12; i++) {
    await tester.drag(finder, const Offset(0, -500));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}
