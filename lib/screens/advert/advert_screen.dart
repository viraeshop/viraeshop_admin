import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
    final advertBloc = BlocProvider.of<AdvertsBloc>(context);
    advertBloc.add(GetAdvertsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
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
                    child: Consumer<AdsProvider>(
                      builder: (context, ads, childs) {
                        return const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: AdvertListWidget(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdvertListWidget extends StatefulWidget {
  const AdvertListWidget({Key? key}) : super(key: key);

  @override
  State<AdvertListWidget> createState() => _AdvertListWidgetState();
}

class _AdvertListWidgetState extends State<AdvertListWidget> {
  bool onUpdate = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdvertsBloc, AdvertState>(buildWhen: (context, state) {
      if (state is FetchedAdvertsState || state is OnGetAdvertsErrorState) {
        return true;
      } else {
        return false;
      }
    }, builder: (context, state) {
      if (kDebugMode) {
        print(state);
      }
      debugPrint('Listener called');
      if (state is OnGetAdvertsErrorState) {
        return Center(
          child: Text(
            state.message,
            style: kDueCellStyle,
            textAlign: TextAlign.center,
          ),
        );
      } else if (state is FetchedAdvertsState) {
        List<AdvertCategories> data = state.advertList;
        if (kDebugMode) {
          print('Adverts from Database: $data');
        }
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          for (var ad in data) {
            for (var element in ad.adverts!) {
              Map advert = {
                'image': element.image,
                'imageKey': element.imageKey,
                'adId': element.adId,
                'adsCategory': element.advertsCategory,
                'adCategoryId': element.adCategoryId,
                'isEdit': false,
                'imageBytes': null,
              };
              Provider.of<AdsProvider>(context, listen: false)
                  .addAdCard(element.adId ?? '', advert);
            }
          }
        });
        return ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'App Bar Banners',
              style: kTableCellStyle,
            ),
            SizedBox(
              height: 10.0,
            ),
            AdsCarousel(
              advertsCategoryName: 'App Bar Banners',
            ),
            Text(
              'Top Discount',
              style: kTableCellStyle,
            ),
            SizedBox(
              height: 10.0,
            ),
            AdsCarousel(
              advertsCategoryName: 'Top Discount',
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              'Top Sales',
              style: kTableCellStyle,
            ),
            SizedBox(
              height: 10.0,
            ),
            AdsCarousel(
              advertsCategoryName: 'Top Sales',
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              'New Arrivals',
              style: kTableCellStyle,
            ),
            SizedBox(
              height: 10.0,
            ),
            AdsCarousel(
              advertsCategoryName: 'New Arrivals',
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              'Vira Shop',
              style: kTableCellStyle,
            ),
            SizedBox(
              height: 10.0,
            ),
            AdsCarousel(
              advertsCategoryName: 'Vira Shop',
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        );
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
