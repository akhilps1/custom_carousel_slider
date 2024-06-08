import 'dart:developer';

import 'package:custom_carousal_slider/custom_carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  debugPrint = (String? message, {int? wrapWidth}) =>
      debugPrintSynchronously(message!, wrapWidth: wrapWidth);
  runApp(const MyApp());
}

final List<String> images = [
  "assets/image1.jpg",
  "assets/image6.jpg",
  "assets/image2.jpg",
  "assets/image4.jpg",
  "assets/image3.jpg",
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter BABA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CarouselClass(),
    );
  }
}

class CarouselClass extends StatelessWidget {
  const CarouselClass({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Carousel',
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        height: 190,
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
        ),
        child: CustomCarouselSlider(
          // width: MediaQuery.sizeOf(context).width,
          height: 190,
          length: images.length,
          borderRadius: 20,
          slideAnimationDuration: 400,
          titleFadeAnimationDuration: 300,
          childClick: (int index) {
            log("Clicked $index");
          },
          childBuilder: (index) => Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.contain,
                  image: AssetImage(
                    images[index],
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
