import 'package:flutter/material.dart';

class OvalBottomBar extends StatelessWidget {
  const OvalBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        height: 90,
        child: Stack(
          children: [
            Positioned(
              left: -(898 - MediaQuery.of(context).size.width) / 2,
              bottom: -(182.0 - 80),
              child: Container(
                width: 898,
                height: 182,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(449, 91), // создает овал
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x00000000).withOpacity(0.04),
                      blurRadius: 12.8,
                      spreadRadius: 0,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
