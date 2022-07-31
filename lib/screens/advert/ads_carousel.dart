import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/styles/gradients.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';

import 'ads_card.dart';
import 'ads_provider.dart';

class AdsCarousel extends StatelessWidget {
  final String adsId;
  AdsCarousel({
    required this.adsId,
  });
  @override
  Widget build(BuildContext context) {
    return Consumer<AdsProvider>(builder: (context, childs, widgets) {
      List ads = childs.adCards.where((element) {
        return element['adsCategory'] == adsId;
      }).toList();
      print('Ads list: $ads');
      Map<String, Map<String, TextEditingController>> controllers =
          childs.controllers;
      // print('Controllers: $controllers');
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            ads.length + 1,
            (int itemIndex) {
              Random random = Random();
              String adId = adsId + random.nextInt(100000).toString();
              if (itemIndex == ads.length) {
                return InkWell(
                  onTap: () {
                    Provider.of<AdsProvider>(context, listen: false)
                        .addController(adId, {
                      'title1': TextEditingController(),
                      'title2': TextEditingController(),
                      'title3': TextEditingController(),
                    });
                    Provider.of<AdsProvider>(context, listen: false)
                        .addAdCard(adId, {
                      'title1': 'Title 1',
                      'title2': 'Title 2',
                      'title3': 'Title 3',
                      'image': '',
                      'adId': adId,
                      'adsCategory': adsId,
                      'isEdit': false,
                      'imageBytes': null,
                    });
                  },
                  child: Container(
                    height: 150.0,
                    width: 100.0,
                    margin: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      gradient: kLinearGradient,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        'New',
                        style: kTableHeadingStyle,
                      ),
                    ),
                  ),
                );
              }
              String currentId = ads[itemIndex]['adId'];
              return AdsCard(
                isEdit: ads[itemIndex]['isEdit'],
                title1: ads[itemIndex]['title1'],
                title1Controller: controllers[currentId]!['title1']!,
                title2: ads[itemIndex]['title2'],
                title2Controller: controllers[currentId]!['title2']!,
                title3: ads[itemIndex]['title3'],
                title3Controller: controllers[currentId]!['title3']!,
                image: ads[itemIndex]['image'],
                imageBytes: ads[itemIndex]['imageBytes'],
                imagePath: ads[itemIndex]['imagePath'],
                onEdit: () {
                  Provider.of<AdsProvider>(context, listen: false)
                      .onEdit(ads[itemIndex]['adId'], true);
                },
                getImage: () {
                  if(kIsWeb){
                    getImageWeb('ads_banners').then((value) {
                      Provider.of<AdsProvider>(context, listen: false).saveImages(
                         adId: ads[itemIndex]['adId'],
                          image: value.item2,
                          imagesBytes: value.item1!);
                    });
                  }else{
                    getImageNative('ads_banners').then((value){
                      Provider.of<AdsProvider>(context, listen: false).saveImages(
                          adId: ads[itemIndex]['adId'],
                          image: value.item2,
                          imagePath: value.item1!,
                      );
                    });
                  }
                },
                onEditDone: () {
                  String title1 = controllers[currentId]!['title1']!.text;
                  String title2 = controllers[currentId]!['title2']!.text;
                  String title3 = controllers[currentId]!['title3']!.text;
                  Provider.of<AdsProvider>(context, listen: false)
                      .updateAdCard(currentId, title1, title2, title3);
                  Provider.of<AdsProvider>(context, listen: false)
                      .onEdit(currentId, false);
                },
                onDelete: () {
                  Provider.of<AdsProvider>(context, listen: false)
                      .deleteAdCard(ads[itemIndex]['adId']);
                  print('Original Advert List: ${childs.adCards}');
                },
              );
            },
          ),
        ),
      );
    });
  }
}
