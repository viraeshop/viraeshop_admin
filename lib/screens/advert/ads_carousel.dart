import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_bloc/adverts/adverts_event.dart';
import 'package:viraeshop_bloc/adverts/adverts_state.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/gradients.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_bloc/adverts/adverts_bloc.dart';
import 'package:viraeshop_api/apiCalls/adverts.dart';
import 'package:viraeshop_api/models/adverts/adverts.dart';

import '../../utils/advert_enums.dart';
import 'ads_card.dart';
import 'ads_provider.dart';

class AdsCarousel extends StatefulWidget {
  final String adsId;
  const AdsCarousel({
    Key? key,
    required this.adsId,
  }) : super(key: key);

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  AdsEvents currentEvent = AdsEvents.initial;
  late String adIdInAction;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdvertsBloc(advertCalls: AdvertCalls()),
      child: BlocListener<AdvertsBloc, AdvertState>(
        listener: (context, state) {
          debugPrint('listener called');
          if (state is RequestFinishedAdvertState) {
            final Map details = state.response.result ?? {};
            if (currentEvent == AdsEvents.create) {
              Provider.of<AdsProvider>(context, listen: false)
                  .addController(details['adId'].toString(), {
                'title1': TextEditingController(),
                'title2': TextEditingController(),
                'title3': TextEditingController(),
              });
              Provider.of<AdsProvider>(context, listen: false)
                  .addAdCard(details['adId'].toString(), {
                'title1': 'Title 1',
                'title2': 'Title 2',
                'title3': 'Title 3',
                'image': '',
                'imagePath': '',
                'adId': details['adId'].toString(),
                'adsCategory': widget.adsId,
                'isEdit': false,
                'imageBytes': null,
              });
            } else if (currentEvent == AdsEvents.update) {
              ///Todo: Add update here
              Provider.of<AdsProvider>(context, listen: false).updateAdCard(
                  details['adId'].toString(),
                  details['title1'],
                  details['title2'],
                  details['title3']);
              Provider.of<AdsProvider>(context, listen: false)
                  .onEdit(details['adId'].toString(), false);
            } else if (currentEvent == AdsEvents.delete) {
              ///Todo: Add delete here
              Provider.of<AdsProvider>(context, listen: false)
                  .deleteAdCard(details['adId'].toString());
            }
            toast(
              title: currentEvent == AdsEvents.delete
                  ? 'Advert deleted successfully'
                  : currentEvent == AdsEvents.create
                      ? 'Advert Created successfully'
                      : 'Advert updated successfully',
              context: context,
              color: kNewMainColor,
            );
          } else if (state is OnCUDAdvertsErrorState) {
            debugPrint('i got called on OnCUDError');
            snackBar(
              text: state.message,
              context: context,
              duration: 200,
            );
          }
        },
        child: Consumer<AdsProvider>(builder: (context, childs, widgets) {
          List ads = childs.adCards.where((element) {
            return element['adsCategory'] == widget.adsId;
          }).toList();
          if (kDebugMode) {
            print('Ads list: $ads');
          }
          Map<String, Map<String, TextEditingController>> controllers =
              childs.controllers;
          if (kDebugMode) {
            print('Controllers: $controllers');
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                ads.length + 1,
                (int itemIndex) {
                  if (itemIndex == ads.length) {
                    return InkWell(
                      onTap: () {
                        final advertBloc =
                            BlocProvider.of<AdvertsBloc>(context);
                        snackBar(
                          text: 'Creating please wait....',
                          context: context,
                          duration: 200,
                          color: kNewMainColor,
                        );
                        AdvertsModel advert = AdvertsModel(
                          image: '',
                          advertsCategory: widget.adsId,
                          title1: 'title1',
                          title2: 'title2',
                          title3: 'title3',
                        );
                        final jWTToken = Hive.box('adminInfo').get('token');
                        advertBloc.add(AddAdvertEvent(
                            token: jWTToken,
                            advertModel: advert));
                        setState(() {
                          currentEvent = AdsEvents.create;
                        });
                      },
                      child: Container(
                        height: 150.0,
                        width: 100.0,
                        margin: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          gradient: kLinearGradient,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Center(
                          child: Text(
                            'New',
                            style: kTableHeadingStyle,
                          ),
                        ),
                      ),
                    );
                  }
                  String imageKey = ads[itemIndex]['imageKey'] ?? '';
                  String currentId = ads[itemIndex]['adId'];
                  return AdsCard(
                    isEdit: ads[itemIndex]['isEdit'],
                    title1: ads[itemIndex]['title1'],
                    title1Controller: controllers[currentId]!['title1']!,
                    title2: ads[itemIndex]['title2'],
                    title2Controller: controllers[currentId]!['title2']!,
                    title3: ads[itemIndex]['title3'],
                    title3Controller: controllers[currentId]!['title3']!,
                    image: ads[itemIndex]['image'] ?? '',
                    imageBytes: ads[itemIndex]['imageBytes'],
                    imagePath: ads[itemIndex]['imagePath'],
                    onEdit: () {
                      Provider.of<AdsProvider>(context, listen: false)
                          .onEdit(ads[itemIndex]['adId'], true);
                    },
                    getImage: () async {
                      if (imageKey.isNotEmpty) {
                        try {
                          await NetworkUtility.deleteImage(key: ads[itemIndex]['imageKey']);
                        } on FirebaseException catch (e) {
                          if (kDebugMode) {
                            print(e);
                          }
                        }
                      }
                      if (kIsWeb) {
                        // getImageWeb('ads_banners').then((value) {
                        //   Provider.of<AdsProvider>(context, listen: false)
                        //       .saveImages(
                        //           adId: ads[itemIndex]['adId'],
                        //           image: value.item2,
                        //           imagesBytes: value.item1!);
                        // });
                      } else {
                        getImageNative('ads_banners').then((value) {
                          Provider.of<AdsProvider>(context, listen: false)
                              .saveImages(
                            adId: ads[itemIndex]['adId'],
                            image: value['imageData']['url'],
                            imageKey: value['imageData']['key'],
                            imagePath: value['path'],
                          );
                        });
                      }
                    },
                    onEditDone: () {
                      final advertBloc = BlocProvider.of<AdvertsBloc>(context);
                      snackBar(
                        text: 'Updating.......',
                        context: context,
                        duration: 100,
                        color: kNewMainColor,
                      );
                      String title1 = controllers[currentId]!['title1']!.text;
                      String title2 = controllers[currentId]!['title2']!.text;
                      String title3 = controllers[currentId]!['title3']!.text;
                      Map<String, dynamic> advert = {
                        'adId': currentId,
                        'image': ads[itemIndex]['image'] ?? '',
                        'imageKey': ads[itemIndex]['imageKey'] ?? '',
                        'advertsCategory': ads[itemIndex]['adsCategory'],
                        'title1': title1,
                        'title2': title2,
                        'title3': title3,
                      };
                      final jWTToken = Hive.box('adminInfo').get('token');
                      advertBloc.add(UpdateAdvertEvent(
                        token: jWTToken,
                          adId: currentId, advertModel: advert));
                      setState(() {
                        currentEvent = AdsEvents.update;
                      });
                    },
                    onDelete: () async {
                      final advertBloc = BlocProvider.of<AdvertsBloc>(context);
                      snackBar(
                        text: 'Deleting.......',
                        context: context,
                        duration: 300,
                        color: kNewMainColor,
                      );
                      try {
                        await NetworkUtility.deleteImage(key: imageKey);
                        final jWTToken = Hive.box('adminInfo').get('token');
                        advertBloc.add(
                            DeleteAdvertEvent(
                                token: jWTToken,
                                adId: ads[itemIndex]['adId']));
                        setState(() {
                          currentEvent = AdsEvents.delete;
                        });
                      } catch (e) {
                        if (kDebugMode) {
                          print(e);
                        }
                        debugPrint('On delete image error');
                        snackBar(
                          text: e.toString(),
                          context: context,
                          color: kRedColor,
                          duration: 300,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}
