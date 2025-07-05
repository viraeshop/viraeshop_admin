import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:viraeshop_api/models/adverts/advert_categories.dart';
import 'package:viraeshop_bloc/adverts/adverts_event.dart';
import 'package:viraeshop_bloc/adverts/adverts_state.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/reusable_widgets/category/categories.dart';
import 'package:viraeshop_admin/screens/advert/ads_carousel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_bloc/adverts/adverts_bloc.dart';
import 'ads_provider.dart';

class AdvertScreen extends StatefulWidget {
  const AdvertScreen({Key? key}) : super(key: key);

  @override
  State<AdvertScreen> createState() => _AdvertScreenState();
}

class _AdvertScreenState extends State<AdvertScreen> {
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder(
              valueListenable: Hive.box(productsBox).listenable(),
              builder: (context, Box box, widgets) {
                List catgs = box.get(catKey);
                return Categories(
                  catLength: catgs.length + 1,
                  categories: catgs,
                  isAdvert: true,
                );
              },
            ),
            LimitedBox(
              maxHeight: size.height * 0.68,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FractionallySizedBox(
                    alignment: Alignment.topCenter,
                    heightFactor: 1,
                    child: LimitedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AdvertListWidget(
                          onAction: (){
                            setState(() {
                              isLoading = true;
                            });
                          },
                          onActionDone: (){
                            setState(() {
                              isLoading = false;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdvertListWidget extends StatefulWidget {
  const AdvertListWidget({super.key, required this.onAction, required this.onActionDone,});
  final VoidCallback onAction;
  final VoidCallback onActionDone;
  @override
  State<AdvertListWidget> createState() => _AdvertListWidgetState();
}

class _AdvertListWidgetState extends State<AdvertListWidget> {
  @override
  initState() {
    final advertBloc = BlocProvider.of<AdvertsBloc>(context);
    advertBloc.add(GetAdvertsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdvertsBloc, AdvertState>(buildWhen: (context, state) {
      if (state is FetchedAdvertsState ||
          state is OnGetAdvertsErrorState ||
          state is LoadingAdvertState) {
        return true;
      } else {
        return false;
      }
    }, builder: (context, state) {
      if (kDebugMode) {
        print(state);
      }
      if (state is OnGetAdvertsErrorState) {
        return Center(
          child: Text(
            state.message,
            style: kDueCellStyle,
            textAlign: TextAlign.center,
          ),
        );
      } else if (state is FetchedAdvertsState) {
        List<AdvertCategories> data = state.advertList.toList();
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          final adsProvider = Provider.of<AdsProvider>(context, listen: false);
          if (adsProvider.adCards.isNotEmpty) {
            print('I am going to clear you Mr AdsCards hahh!');
            adsProvider.clearAdCards();
          }
          for (var ad in data) {
            for (var element in ad.adverts!) {
              Map advert = {
                'image': element.image,
                'imageKey': element.imageKey,
                'adId': element.adId,
                'adsCategory': element.advertsCategory,
                'adCategoryId': element.adCategoryId,
                'categoryId': element.categoryId,
                'isEdit': false,
                'imagePath': '',
                'searchTermController': TextEditingController(text: element.searchTerm),
                'searchTerm': element.searchTerm,
              };
              Provider.of<AdsProvider>(context, listen: false)
                  .addAdCard(element.adId ?? '', advert);
            }
          }
        });
        return Consumer<AdsProvider>(builder: (context, ads, childs) {
          return ListView(
            children: [
              const Text(
                'App Bar Banners',
                style: kTableCellStyle,
              ),
              const SizedBox(
                height: 10.0,
              ),
              AdsCarousel(
                onAction: widget.onAction,
                onActionDone: widget.onActionDone,
                categoryId: ads.categoryId,
                ads: ads.adCards.where((element) {
                  return element['adsCategory'] == 'App Bar Banners';
                }).toList(),
                advertsCategoryName: 'App Bar Banners',
              ),
              const Text(
                'Top Discount',
                style: kTableCellStyle,
              ),
              const SizedBox(
                height: 10.0,
              ),
              AdsCarousel(
                onAction: widget.onAction,
                onActionDone: widget.onActionDone,
                categoryId: ads.categoryId,
                ads: ads.adCards.where((element) {
                  return element['adsCategory'] == 'Top Discount';
                }).toList(),
                advertsCategoryName: 'Top Discount',
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
                onAction: widget.onAction,
                onActionDone: widget.onActionDone,
                categoryId: ads.categoryId,
                ads: ads.adCards.where((element) {
                  return element['adsCategory'] == 'Top Sales';
                }).toList(),
                advertsCategoryName: 'Top Sales',
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
                onAction: widget.onAction,
                onActionDone: widget.onActionDone,
                categoryId: ads.categoryId,
                ads: ads.adCards.where((element) {
                  return element['adsCategory'] == 'New Arrivals';
                }).toList(),
                advertsCategoryName: 'New Arrivals',
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
                onAction: widget.onAction,
                onActionDone: widget.onActionDone,
                categoryId: ads.categoryId,
                ads: ads.adCards.where((element) {
                  return element['adsCategory'] == 'Vira Shop';
                }).toList(),
                advertsCategoryName: 'Vira Shop',
              ),
              const SizedBox(
                height: 10.0,
              ),
            ],
          );
        });
      }
      return const Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
              children: [
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
              children: [
                Shimmers(),
                Shimmers(),
                Shimmers(),
              ],
            ),
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
