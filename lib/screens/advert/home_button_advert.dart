import 'dart:io';
import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';
import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/image/image_picker_service.dart';
import 'package:viraeshop_admin/reusable_widgets/send_button.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';
import 'package:viraeshop_api/viraeshop_api.dart';
import 'package:viraeshop_bloc/adverts/home_adverts/home_adverts_bloc.dart';
import 'package:viraeshop_bloc/adverts/home_adverts/home_adverts_events.dart';
import 'package:viraeshop_bloc/adverts/home_adverts/home_adverts_state.dart';

class HomeButtonAdvert extends StatefulWidget {
  const HomeButtonAdvert({Key? key}) : super(key: key);

  @override
  State<HomeButtonAdvert> createState() => _HomeButtonAdvertState();
}

class _HomeButtonAdvertState extends State<HomeButtonAdvert> {
  bool isLoading = false;
  final String folder = 'home_ads';
  final token = Hive.box('adminInfo').get('token');
  final ImagePickerService imagePickerService = ImagePickerService();
  List<HomeAdsModel> adverts = [];
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(
        color: kMainColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left,
              color: kSubMainColor,
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Navigate back to the home screen
            },
          ),
          title: const Text(
            'Home Button Advert',
            style: kProductNameStylePro,
          ),
        ),
        body: BlocListener<HomeAdsBloc, HomeAdvertsState>(
          listener: (context, state) {
            if (state is HomeAdvertsLoadingState) {
              // Show loading indicator
              setState(() {
                isLoading = true;
              });
            } else if (state is HomeAdvertsFetchedState) {
              final advertsList = state.adverts.toList();
              setState(() {
                isLoading = false;
                adverts = advertsList;
              });
            } else if (state is HomeAdRequestFinishedState) {
              setState(() {
                isLoading = false;
              });
              showToast(state.message,
                  context: context,
                  backgroundColor: Colors.green,
                  textStyle: const TextStyle(color: Colors.white));
              // Optionally, you can refresh the adverts list here
              BlocProvider.of<HomeAdsBloc>(context).add(GetHomeAdvertsEvent());
            } else if (state is HomeAdvertsErrorState) {
              setState(() {
                isLoading = false;
              });
              showToast(state.message,
                  context: context,
                  backgroundColor: Colors.red,
                  textStyle: const TextStyle(color: Colors.white));
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeAdsWidget(
                adId: adverts.isNotEmpty
                    ? adverts
                        .firstWhere((ad) => ad.adImageType == 'homeButton')
                        .id
                    : null,
                imagePickerService: imagePickerService,
                title: 'Home Button Advert',
                imagePath: adverts.isNotEmpty
                    ? adverts
                        .firstWhere((ad) => ad.adImageType == 'homeButton')
                        .adImage
                    : 'https://via.placeholder.com/150',
                isPlaceHolder: adverts.isEmpty,
                onAction: () {
                  setState(() {
                    isLoading = true;
                  });
                },
                onActionError: () {
                  setState(() {
                    isLoading = false;
                  });
                },
                adImageType: 'homeButton',
              ),
              const SizedBox(height: 20),
              HomeAdsWidget(
                adId: adverts.isNotEmpty
                    ? adverts
                        .firstWhere((ad) => ad.adImageType == 'productCampaign')
                        .id
                    : null,
                imagePickerService: imagePickerService,
                title: 'Free Shipping Advert',
                imagePath: adverts.isNotEmpty
                    ? adverts
                        .firstWhere((ad) => ad.adImageType == 'productCampaign')
                        .adImage
                    : 'https://via.placeholder.com/150',
                isPlaceHolder: adverts.isEmpty,
                onAction: () {
                  setState(() {
                    isLoading = true;
                  });
                },
                onActionError: () {
                  setState(() {
                    isLoading = false;
                  });
                },
                adImageType: 'productCampaign',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeAdsWidget extends StatelessWidget {
  const HomeAdsWidget({
    super.key,
    this.adId,
    required this.imagePickerService,
    required this.title,
    required this.imagePath,
    required this.adImageType,
    required this.isPlaceHolder,
    required this.onAction,
    required this.onActionError,
  });
  final ImagePickerService imagePickerService;
  final String title;
  final String imagePath;
  final String adImageType;
  final int? adId;
  final bool isPlaceHolder;
  final VoidCallback onAction;
  final VoidCallback onActionError;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: kProductNameStylePro.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: returnImageWidget(
            isPlaceHolder: isPlaceHolder,
            imagePath: imagePath,
          ),
        ),
        const SizedBox(height: 10),
        SendButton(
          title: 'Add Advert',
          onTap: () async {
            final bloc = BlocProvider.of<HomeAdsBloc>(context);
            final token = Hive.box('adminInfo').get('token');
            Map<String, dynamic> imageResult;
            try {
              final pickedImage = await imagePickerService.pickImage(context);
              if (pickedImage != null) {
                onAction.call();
                imageResult = await NetworkUtility.uploadImageFromNative(
                    file: pickedImage, folder: 'home_ads');
                if(isPlaceHolder){
                  bloc.add(
                  CreateHomeAdvertEvent(
                    advertData: {
                      'adImage': imageResult['url'],
                      'adImageKey': imageResult['key'],
                      'adImageType': adImageType,
                    },
                    token: token,
                  ),
                );
                } else {
                  bloc.add(
                    UpdateHomeAdvertEvent(
                      advertData: {
                        'adImage': imageResult['url'],
                        'adImageKey': imageResult['key'],
                        'adImageType': adImageType,
                      },
                      advertId: adId!,
                      token: token,
                    ),
                  );
                }
              }
            } catch (e) {
              onActionError.call();
              showToast(
                'Error: $e',
                context: context,
                backgroundColor: Colors.red,
                textStyle: const TextStyle(color: Colors.white),
              );
            }
          },
          width: 150,
          color: kNewMainColor,
        ),
      ],
    );
  }
}

Widget returnImageWidget({
  required bool isPlaceHolder,
  required String imagePath,
}) {
  if (isPlaceHolder) {
    return Image.asset(
      'assets/default.jpg', // Replace with your placeholder image path
      fit: BoxFit.cover,
      height: 150,
      width: 100,
    );
  } else {
    return CachedNetworkImage(
      imageUrl: imagePath,
      fit: BoxFit.cover,
      height: 150,
      width: 100,
    );
  }
}
