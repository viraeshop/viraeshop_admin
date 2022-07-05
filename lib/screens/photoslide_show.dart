import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PhotoSlideShow extends StatelessWidget {
  final List images;
  PhotoSlideShow({required this.images});

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      backgroundColor: kBlackColor,
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.center,
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, i){
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: CachedNetworkImage(                    
                      // width: size.width,
                      // fit: BoxFit.cover,
                      imageUrl: images[i],              
                      errorWidget: (context, url, childs) {
                        return Image.asset(
                          'assets/default.jpg',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  );
                },
                ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.cancel,
                    size: 30.0,
                    color: kBackgroundColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}