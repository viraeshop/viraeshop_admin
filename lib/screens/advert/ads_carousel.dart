import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/reusable_widgets/hive/shops_model.dart';
import 'package:viraeshop_admin/reusable_widgets/image/image_picker_service.dart';
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
  final String advertsCategoryName;
  final int? categoryId;
  const AdsCarousel({
    super.key,
    this.categoryId,
    required this.advertsCategoryName,
  });

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  AdsEvents currentEvent = AdsEvents.initial;
  late String adIdInAction;
  final ImagePickerService _imagePickerService = ImagePickerService();
  Map<String, dynamic> imageResult = {};
  PlatformFile? pickedUpdatingImage;
  // ...existing code...

// Add this helper method inside _AdsCarouselState:
  Future<void> _handleAddAdvert(int? adCategoryId) async {
    Map<String, dynamic> imageData = {};
    final advertBloc = BlocProvider.of<AdvertsBloc>(context);
    final pickedImage = await _imagePickerService.pickImage(context);
    if (pickedImage == null) return;

    try {
      imageData = await NetworkUtility.uploadImageFromNative(
        file: pickedImage,
        folder: 'ads_banners',
      );
      final advert = AdvertsModel(
        image: imageData['url'],
        imageKey: imageData['key'],
        adCategoryId: adCategoryId,
        categoryId: widget.categoryId,
        advertsCategory: widget.advertsCategoryName,
      );
      final jWTToken = Hive.box('adminInfo').get('token');
      advertBloc.add(AddAdvertEvent(
        token: jWTToken,
        advertModel: advert,
      ));
      setState(() {
        currentEvent = AdsEvents.create;
        imageResult = {
          'imageData': imageData,
          'path': pickedImage.path,
        };
      });
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future<void> _handleUpdateAdvert({
    required String imageKey,
    required String currentId,
    required Map<String, dynamic> advertData,
  }) async {
    if (imageKey.isNotEmpty) {
      try {
        await NetworkUtility.deleteImage(key: imageKey);
      } catch (e) {
        if (kDebugMode) {
          print('Error deleting image: $e');
        }
        snackBar(
          text: 'Error deleting old image: $e',
          context: context,
          color: kRedColor,
          duration: 300,
        );
        return;
      }
    }
    final advertBloc = BlocProvider.of<AdvertsBloc>(context);
    snackBar(
      text: 'Updating.......',
      context: context,
      duration: 100,
      color: kNewMainColor,
    );
    final jWTToken = Hive.box('adminInfo').get('token');
    advertBloc.add(UpdateAdvertEvent(
      token: jWTToken,
      adId: currentId,
      advertModel: advertData,
    ));
    setState(() {
      currentEvent = AdsEvents.update;
    });
  }

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
                  .addAdCard(details['adId'].toString(), {
                'image': imageResult['imageData']['url'] ?? '',
                'imagePath': imageResult['path'] ?? '',
                'imageKey': imageResult['key'] ?? '',
                'adId': details['adId'].toString(),
                'adsCategory': widget.advertsCategoryName,
                'adCategoryId': details['adCategoryId'],
                'categoryId': widget.categoryId,
                'isEdit': false,
              });
            } else if (currentEvent == AdsEvents.update) {
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
            return element['adsCategory'] == widget.advertsCategoryName;
          }).toList();
          int? adCategoryId = ads.isNotEmpty ? ads.first['adCategoryId'] : null;
          if (kDebugMode) {
            print('Ads list: $ads');
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                ads.length + 1,
                (int itemIndex) {
                  if (itemIndex == ads.length) {
                    return InkWell(
                      onTap: () => _handleAddAdvert(adCategoryId),
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
                    image: ads[itemIndex]['image'] ?? '',
                    imagePath: ads[itemIndex]['imagePath'],
                    onEdit: () async {
                      Provider.of<AdsProvider>(context, listen: false)
                          .onEdit(ads[itemIndex]['adId'], true);
                    },
                    onUpdateImage: () async {
                      try {
                        pickedUpdatingImage =
                            await _imagePickerService.pickImage(context);
                        if (pickedUpdatingImage == null) return;
                        imageResult =
                            await NetworkUtility.uploadImageFromNative(
                          file: pickedUpdatingImage!,
                          folder: 'ads_banners',
                        );
                        Provider.of<AdsProvider>(context, listen: false)
                            .saveImages(
                          adId: ads[itemIndex]['adId'],
                          image: imageResult['url'],
                          imageKey: imageResult['key'],
                          imagePath: pickedUpdatingImage!.path,
                        );
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error picking image: $e');
                        }
                      }
                    },
                    onEditDone: () async {
                      final advertData = {
                        'adId': currentId,
                        'image': ads[itemIndex]['image'] ?? '',
                        'imageKey': ads[itemIndex]['imageKey'] ?? '',
                        'advertsCategory': ads[itemIndex]['adsCategory'],
                      };
                      await _handleUpdateAdvert(
                        imageKey: imageKey,
                        currentId: currentId,
                        advertData: advertData,
                      );
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
                        advertBloc.add(DeleteAdvertEvent(
                            token: jWTToken, adId: ads[itemIndex]['adId']));
                        setState(() {
                          currentEvent = AdsEvents.delete;
                        });
                      } catch (e) {
                        if (kDebugMode) {
                          print(e);
                        }
                        debugPrint('On delete image error');
                        if (context.mounted) {
                          snackBar(
                            text: e.toString(),
                            context: context,
                            color: kRedColor,
                            duration: 300,
                          );
                        }
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
