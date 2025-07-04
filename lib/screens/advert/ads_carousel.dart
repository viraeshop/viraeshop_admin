import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/reusable_widgets/image/image_picker_service.dart';
import 'package:viraeshop_admin/screens/supplier/shops.dart';
import 'package:viraeshop_bloc/adverts/adverts_event.dart';
import 'package:viraeshop_bloc/adverts/adverts_state.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/gradients.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_bloc/adverts/adverts_bloc.dart';
import 'package:viraeshop_api/apiCalls/adverts.dart';
import 'package:viraeshop_api/models/adverts/adverts.dart';

import '../../utils/advert_enums.dart';
import 'ads_card.dart';
import 'ads_provider.dart';
import 'package:viraeshop_bloc/adverts/advert_cubit.dart';

class AdsCarousel extends StatefulWidget {
  final String advertsCategoryName;
  final int? categoryId;
  final List ads;
  final VoidCallback onAction;
  final VoidCallback onActionDone;
  const AdsCarousel({
    super.key,
    this.categoryId,
    required this.ads,
    required this.onAction,
    required this.onActionDone,
    required this.advertsCategoryName,
  });

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  AdsEvents currentEvent = AdsEvents.initial;
  String deletedAdId = '';
  late String adIdInAction;
  final ImagePickerService _imagePickerService = ImagePickerService();
  Map<String, dynamic> imageResult = {};
  PlatformFile? pickedUpdatingImage;
  // ...existing code...

// Add this helper method inside _AdsCarouselState:
  Future<void> _handleAddAdvert(int? adCategoryId) async {
    Map<String, dynamic> imageData = {};
    final advertCubit = BlocProvider.of<AdvertCubit>(context);
    final pickedImage = await _imagePickerService.pickImage(context);
    if (pickedImage == null) return;

    try {
      imageData = await NetworkUtility.uploadImageFromNative(
        file: pickedImage,
        folder: 'ads_banners',
      );
      final searchTerm = await showSearchTermBox(
        context: context,
      );
      widget.onAction.call();
      final advert = AdvertsModel(
        image: imageData['url'],
        imageKey: imageData['key'],
        adCategoryId: adCategoryId,
        categoryId: widget.categoryId,
        advertsCategory: widget.advertsCategoryName,
        searchTerm: searchTerm,
      );
      final jWTToken = Hive.box('adminInfo').get('token');
      advertCubit.addAdvert(
        token: jWTToken,
        advertModel: advert,
      );
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
    final advertCubit = BlocProvider.of<AdvertCubit>(context);
    // snackBar(
    //   text: 'Updating.......',
    //   context: context,
    //   duration: 100,
    //   color: kNewMainColor,
    // );
    widget.onAction.call();
    final jWTToken = Hive.box('adminInfo').get('token');
    advertCubit.updateAdvert(
      token: jWTToken,
      adId: currentId,
      advertModel: advertData,
    );
    setState(() {
      currentEvent = AdsEvents.update;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdvertsBloc(advertCalls: AdvertCalls()),
      child: BlocListener<AdvertCubit, AdvertState>(
        listener: (context, state) {
          //debugPrint('listener called');
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
                'searchTerm': details['searchTerm'],
                'isEdit': false,
                'searchTermController':
                    TextEditingController(text: details['searchTerm'] ?? ''),
              });
            } else if (currentEvent == AdsEvents.update) {
              Provider.of<AdsProvider>(context, listen: false)
                  .onEdit(details['adId'].toString(), false);
              Provider.of<AdsProvider>(context, listen: false).updateAdCard(
                  details['adId'].toString(), details['searchTerm']);
            } else if (currentEvent == AdsEvents.delete) {
              ///Todo: Add delete here
              Provider.of<AdsProvider>(context, listen: false)
                  .deleteAdCard(deletedAdId);
            }
            widget.onActionDone.call();
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
            widget.onActionDone.call();
            snackBar(
              text: state.message,
              context: context,
              duration: 200,
            );
          }
        },
        child: SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.ads.length + 1,
            itemBuilder: (context, int itemIndex) {
              if (itemIndex == widget.ads.length) {
                return InkWell(
                  onTap: () => _handleAddAdvert(widget.ads.isNotEmpty ? widget.ads.first['adCategoryId'] : null),
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
              String imageKey = widget.ads[itemIndex]['imageKey'] ?? '';
              String currentId = widget.ads[itemIndex]['adId'];
              return AdsCard(
                isEdit: widget.ads[itemIndex]['isEdit'],
                image: widget.ads[itemIndex]['image'] ?? '',
                imagePath: widget.ads[itemIndex]['imagePath'],
                textController: widget.ads[itemIndex]['searchTermController'],
                searchTerm: widget.ads[itemIndex]['searchTerm'].isNotEmpty
                    ? widget.ads[itemIndex]['searchTerm']
                    : 'Search Term',
                onEdit: () async {
                  Provider.of<AdsProvider>(context, listen: false)
                      .onEdit(widget.ads[itemIndex]['adId'], true);
                },
                onUpdateImage: () async {
                  try {
                    pickedUpdatingImage =
                    await _imagePickerService.pickImage(context);
                    if (pickedUpdatingImage == null) return;
                    imageResult = await NetworkUtility.uploadImageFromNative(
                      file: pickedUpdatingImage!,
                      folder: 'ads_banners',
                    );
                    Provider.of<AdsProvider>(context, listen: false)
                        .saveImages(
                      adId: widget.ads[itemIndex]['adId'],
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
                    'image': widget.ads[itemIndex]['image'] ?? '',
                    'imageKey': widget.ads[itemIndex]['imageKey'] ?? '',
                    'advertsCategory': widget.ads[itemIndex]['adsCategory'],
                    'searchTerm': widget.ads[itemIndex]['searchTermController'].text,
                  };
                  await _handleUpdateAdvert(
                    imageKey: imageKey,
                    currentId: currentId,
                    advertData: advertData,
                  );
                },
                onDelete: () async {
                  final advertBloc = BlocProvider.of<AdvertCubit>(context);
                  widget.onAction.call();
                  // snackBar(
                  //   text: 'Deleting.......',
                  //   context: context,
                  //   duration: 300,
                  //   color: kNewMainColor,
                  // );
                  try {
                    await NetworkUtility.deleteImage(key: imageKey);
                  } catch (e) {
                    if (kDebugMode) {
                      print(e);
                    }
                    //widget.onActionDone.call();
                    // debugPrint('On delete image error');
                    // if (context.mounted) {
                    //   snackBar(
                    //     text: e.toString(),
                    //     context: context,
                    //     color: kRedColor,
                    //     duration: 300,
                    //   );
                    // }
                  }
                  final jWTToken = Hive.box('adminInfo').get('token');
                  advertBloc.deleteAdvert(
                      token: jWTToken, adId: widget.ads[itemIndex]['adId']);
                  setState(() {
                    currentEvent = AdsEvents.delete;
                    deletedAdId = widget.ads[itemIndex]['adId'];
                  });
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

Future<String> showSearchTermBox({required BuildContext context}) async {
  TextEditingController searchTerm = TextEditingController();
  final value = await showDialog(
      context: context,
      builder: (BuildContext bc) {
        return AlertDialog(
          backgroundColor: kBackgroundColor,
          title: const Text(
            'Enter Search Term',
            style: kProductNameStylePro,
          ),
          content: Container(
            height: 200,
            width: MediaQuery.of(bc).size.width * 0.7,
            decoration: BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                TextField(
                  controller: searchTerm,
                  style: kProductNameStylePro,
                  decoration: InputDecoration(
                    hintText: 'Please enter the search term here...',
                    hintStyle: kProductNameStylePro.copyWith(
                      color: Colors.black12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                sendButton(
                  onTap: () {
                    Navigator.pop(context, searchTerm.text);
                  },
                  title: 'Create',
                  width: 250,
                  color: kNewMainColor,
                ),
              ],
            ),
          ),
        );
      });
  return value;
}
