import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/baxes.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/category/categories.dart';
import 'package:viraeshop_admin/reusable_widgets/drawer.dart';
import 'package:viraeshop_admin/screens/advert/ads_carousel.dart';

import '../../components/styles/colors.dart';
import '../messages_screen/users_screen.dart';
import '../notification/notification_screen.dart';
import 'ads_provider.dart';

class AdvertScreen extends StatefulWidget {
  const AdvertScreen({Key? key}) : super(key: key);

  @override
  State<AdvertScreen> createState() => _AdvertScreenState();
}

class _AdvertScreenState extends State<AdvertScreen> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder(
            valueListenable: Hive.box(productsBox).listenable(),
            builder: (context, Box box, widgets) {
              List catgs = box.get(catKey);
              return Categories(
                catLength: catgs.length + 1,
                categories: catgs,
              );
            }),
        LimitedBox(
          maxHeight: size.height * 0.68,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FractionallySizedBox(
                alignment: Alignment.topCenter,
                heightFactor: 0.9,
                child: LimitedBox(
                  //maxHeight: size.height * 0.58,
                  child: Consumer<AdsProvider>(builder: (context, ads, childs) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ads.currentCatg == 'All'
                          ? const AdvertListWidget()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AdsCarousel(adsId: ads.currentCatg),
                              ],
                            ),
                    );
                  }),
                ),
              ),
              FractionallySizedBox(
                heightFactor: 0.1,
                alignment: Alignment.bottomCenter,
                child:
                    Consumer<AdsProvider>(builder: (context, advert, widgets) {
                  List currentAds = advert.adCards.where((element) {
                    if (advert.currentCatg == 'All') {
                      return element['adsCategory'] == 'Top Discount' ||
                          element['adsCategory'] == 'Top Sales' ||
                          element['adsCategory'] == 'New Arrivals' ||
                          element['adsCategory'] == 'Vira Shop';
                    }
                    return element['adsCategory'] == advert.currentCatg;
                  }).toList();
                  List refinedAds = [];
                  currentAds.forEach((element) {
                    refinedAds.add({
                      'title1': element['title1'],
                      'title2': element['title2'],
                      'title3': element['title3'],
                      'image': element['image'],
                      'adId': element['adId'],
                      'adsCategory': element['adsCategory'],
                    });
                  });
                  return InkWell(
                    onTap: () {
                      snackBar(
                        text: 'Updaing please wait....',
                        context: context,
                        duration: 30,
                      );
                      print('Refined Ads: $refinedAds');
                      FirebaseFirestore.instance
                          .collection('adverts')
                          .doc('adverts')
                          .set({
                        'adverts': refinedAds,
                      }).then((value) {
                        // setState(() {
                        //   isLoading = false;
                        // });
                        snackBar(
                          text: 'Updated Successfully',
                          context: context,
                          duration: 30,
                        );
                      }).catchError((error) {
                        // setState(() {
                        //   isLoading = false;
                        // });
                        snackBar(
                            text: 'Oops an error occured! please try again',
                            context: context,
                            duration: 30,
                            color: kNewMainColor);
                      });
                    },
                    child: Container(
                        margin: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: kNewMainColor,
                            width: 3.0,
                          ),
                        ),
                        child: const Center(
                          child: Text('Update',
                              style: TextStyle(
                                color: kNewMainColor,
                                fontSize: 15.0,
                                fontFamily: 'Montserrat',
                                letterSpacing: 1.3,
                              )),
                        )),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AdvertListWidget extends StatelessWidget {
  const AdvertListWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('adverts')
            .doc('adverts')
            .get(),
        builder: (context, snapshot) {
          List data = [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Shimmers(),
                      Shimmers(),
                      Shimmers(),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Shimmers(),
                      Shimmers(),
                      Shimmers(),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Shimmers(),
                      Shimmers(),
                      Shimmers(),
                    ],
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return const Center(
              child: Text(
                'An error occured',
                style: kTableCellStyle,
              ),
            );
          } else if (snapshot.data!.data() != null) {
            data = snapshot.data!.get('adverts');
            print('Adverts from Database: $data');
            SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
              data.forEach((element) {
                print('yeah');
                Map advert = {
                  'title1': element['title1'],
                  'title2': element['title2'],
                  'title3': element['title3'],
                  'image': element['image'],
                  'adId': element['adId'],
                  'adsCategory': element['adsCategory'],
                  'isEdit': false,
                  'imageBytes': null,
                };
                Provider.of<AdsProvider>(context, listen: false)
                    .addAdCard(element['adId'], advert);
                Provider.of<AdsProvider>(context, listen: false)
                    .addController(element['adId'], {
                  'title1': TextEditingController(text: element['title1']),
                  'title2': TextEditingController(text: element['title2']),
                  'title3': TextEditingController(text: element['title3']),
                });
              });
            });
          }
          return ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Discount',
                style: kTableCellStyle,
              ),
              const SizedBox(
                height: 10.0,
              ),
              AdsCarousel(
                adsId: 'Top Discount',
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                'Top Sales',
                style: kTableCellStyle,
              ),
              const SizedBox(
                height: 10.0,
              ),
              AdsCarousel(
                adsId: 'Top Sales',
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                'New Arrivals',
                style: kTableCellStyle,
              ),
              const SizedBox(
                height: 10.0,
              ),
              AdsCarousel(
                adsId: 'New Arrivals',
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                'Vira Shop',
                style: kTableCellStyle,
              ),
              const SizedBox(
                height: 10.0,
              ),
              AdsCarousel(
                adsId: 'Vira Shop',
              ),
              const SizedBox(
                height: 10.0,
              ),
            ],
          );
        });
  }
}

class Shimmers extends StatelessWidget {
  const Shimmers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 100.0,
        width: MediaQuery.of(context).size.width * 0.3,
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.grey,
        ),
        // child: Row(
        //   children: [
        //     Expanded(
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //         children: [
        //           shimmerRect(),
        //           shimmerRect(),
        //           shimmerRect(),
        //         ],
        //       ),
        //     ),
        //     SizedBox(
        //       width: 10.0,
        //     ),
        //     Container(
        //       height: double.infinity,
        //       width: 100.0,
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(10.0),
        //         color: Colors.grey,
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }

  Container shimmerRect() {
    return Container(
      height: 20.0,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.grey,
      ),
    );
  }
}
