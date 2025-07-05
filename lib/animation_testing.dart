import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/screens/general_provider.dart';

import 'components/styles/colors.dart';

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final matrix = renderObject?.getTransformTo(null);

    if (matrix != null && renderObject?.paintBounds != null) {
      final rect = MatrixUtils.transformRect(matrix, renderObject!.paintBounds);
      return rect;
    } else {
      return null;
    }
  }
}
class AnimationTest extends StatefulWidget {
  const AnimationTest({Key? key}) : super(key: key);

  @override
  State<AnimationTest> createState() => _AnimationTestState();
}

class _AnimationTestState extends State<AnimationTest> {
  OverlayEntry? entry;
  static List items = List.generate(10, (index) => index);
  List<GlobalKey> keys = List.generate(items.length, (index) => GlobalKey());
  // final key1 = GlobalKey();
  // final key2 = GlobalKey();
  void showOverlay(Rect rect,Offset offset, int index) {
    entry = OverlayEntry(builder: (context) {
      return Consumer<GeneralProvider>(builder: (context, animation, childs) {
        print('show overlay $index');
        final size = MediaQuery.of(context).size.height;
        print('Screen height: ${size.round()}');
        return AnimatedPositioned(
            height: animation.addedToCart[index] ? 0 : 50.0,
            width: animation.addedToCart[index] ? 0 : 50.0,
            left: offset.dx,
            //right: rect.right,
            bottom: animation.addedToCart[index] ? 0 :  (size - (offset.dy.round() + (offset.dy.round()/2))).round().toDouble(),
            duration: const Duration(milliseconds: 200),
            child: Container(
              color: kNewMainColor,
              height: 30,
              width: 30,
            ));
      });
    });
    final overlay = Overlay.of(context);
    overlay.insert(entry!);
  }

  void unShowOverlay() {
    setState(() {
      entry!.remove();
      entry = null;
    });
  }

  Offset calculateWidgetPosition(GlobalKey? key) {
    Offset? offset = const Offset(0, 0);
    final RenderBox? box =
        key!.currentContext?.findRenderObject() as RenderBox?;
    //print('Render Box: $box');
    offset = box?.localToGlobal(Offset.zero);
    print(offset);
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   print(key!.currentContext);
    //   final RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
    //   print('Render Box: $box');
    //   offset = box?.localToGlobal(Offset.zero);
    //   //print(offset);
    // });
    return offset!;
  }

  void cartAnimation(int index) {
    Provider.of<GeneralProvider>(context, listen: false)
        .animationTrigger(true, index);
    Future.delayed(
      const Duration(milliseconds: 200),
      () {
        unShowOverlay();
        Provider.of<GeneralProvider>(context, listen: false)
            .animationTrigger(false, index);
        Provider.of<GeneralProvider>(context, listen: false)
            .animationTracker(false);
      },
    );
    // Future.delayed(Duration(milliseconds: 200), (){
    //   unShowOverlay();
    // });
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   Provider.of<GeneralProvider>(context, listen: false)
    //       .updateAnimationTrigger(
    //           List.generate(items.length, (index) => false));
    // });
    return Scaffold(
      backgroundColor: kBackgroundColor,
      floatingActionButton:
          Consumer<GeneralProvider>(builder: (context, animation, childs) {
        return FloatingActionButton(
          onPressed: () {
            unShowOverlay();
            //Provider.of<GeneralProvider>(context, listen: false).animationTrigger(!animation.addedToCart);
          },
        );
      }),
      body: Container(
        child: Center(
          child:
              Consumer<GeneralProvider>(builder: (context, animation, childs) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                items.length,
                (index) => InkWell(
                  onTap: () {
                    Rect rect = keys[index].globalPaintBounds!;
                    print('absolute coordinates on screen: $rect');
                    print('Screen bottom: ${(MediaQuery.of(context).size.height - calculateWidgetPosition(keys[index]).dy).round()}');
                    if (!animation.isStarted) {
                      Provider.of<GeneralProvider>(context, listen: false)
                          .animationTracker(true);
                      Offset offset = calculateWidgetPosition(keys[index]);
                      showOverlay(rect, offset, index);
                      Future.delayed(const Duration(milliseconds: 20), () {
                        cartAnimation(index);
                      });
                   }
                  },
                  child: AnimatedContainer(
                    key: keys[index],
                    margin: const EdgeInsets.all(10),
                    duration: const Duration(milliseconds: 20),
                    color: kRedColor,
                    height: animation.addedToCart[index] ? 50.0 : 45,
                    width: animation.addedToCart[index] ? 100.0 : 95,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
