import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/screens/advert/ads_provider.dart';

import 'category_tab.dart';

class Categories extends StatelessWidget {
  const Categories({
    required this.catLength,
    required this.categories,
    this.isSecondRow = false,
    Key? key,
  }) : super(key: key);
  final int catLength;
  final List categories;
  final bool isSecondRow;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kBackgroundColor,
      ),
      child: LimitedBox(
        maxHeight: 90.0,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: catLength,
            itemBuilder: (context, i) {
              return Consumer<AdsProvider>(builder: (context, ads, childs) {
                if (i == 0 && !isSecondRow) {
                  return CategoryCard(
                    title: 'All',
                    imageUrl:
                        'https://firebasestorage.googleapis.com/v0/b/vira-eshop.appspot.com/o/categories%2FOriginal%20Style%20-%20Something%20Yellow%20(3).jpeg?alt=media&token=f109e833-6e5c-43a1-b60d-6f848798b1f6',
                    isSelected: ads.currentCatg == 'All',
                    onTap: () {
                      Provider.of<AdsProvider>(context, listen: false)
                          .updateCatg('All');
                      Provider.of<AdsProvider>(context, listen: false)
                          .updateHasSubCatg(false);
                      Provider.of<AdsProvider>(context, listen: false)
                          .updateCurrentSubCategory('');
                    },
                  );
                }
                return CategoryCard(
                  title: categories[isSecondRow ? i : i - 1]['category'],
                  imageUrl:
                      categories[isSecondRow ? i : i - 1]['image'] ?? '',
                  isSelected: ads.currentCatg ==
                          categories[isSecondRow ? i : i - 1]['category'] ||
                      ads.subCategory ==
                          categories[isSecondRow ? i : i - 1]['category'],
                  isAssetImage: isSecondRow && !ads.hasSubCatg,
                  isSubCategory: isSecondRow,
                  onTap: () {
                    List subCategories = categories[isSecondRow ? i : i - 1]
                            ['subCategories'] ??
                        [];
                    /**
                     * This will check if the main category doesn't have
                     * a sub-category, then it will update th category
                     * classifying method/function
                     */
                    if (!isSecondRow && subCategories.isEmpty) {
                      Provider.of<AdsProvider>(context, listen: false)
                          .updateCatg(categories[i - 1]['category']);
                      Provider.of<AdsProvider>(context, listen: false)
                          .updateHasSubCatg(false);
                      Provider.of<AdsProvider>(context, listen: false)
                          .updateCurrentSubCategory('');
                    } else if (!isSecondRow && subCategories.isNotEmpty) {
                      Provider.of<AdsProvider>(context, listen: false)
                          .updateSubCategories(
                              categories[i - 1]['subCategories']);
                      Provider.of<AdsProvider>(context, listen: false)
                          .updateCatg(categories[i - 1]['category']);
                      if(ads.currentCatg != categories[i-1]['category']){
                        Provider.of<AdsProvider>(context, listen: false)
                            .updateHasSubCatg(true);
                      }else {
                        Provider.of<AdsProvider>(context, listen: false)
                            .updateHasSubCatg(!ads.hasSubCatg);
                      }
                    } else if (isSecondRow && ads.hasSubCatg) {
                      Provider.of<AdsProvider>(context, listen: false)
                          .updateCurrentSubCategory(
                              (categories[i]['category']));
                    } else {
                      Provider.of<AdsProvider>(context, listen: false)
                          .updateCatg(categories[i]['category']);
                      Provider.of<AdsProvider>(context, listen: false)
                          .updateCurrentSubCategory('');
                      Provider.of<AdsProvider>(context, listen: false)
                          .updateHasSubCatg(false);
                    }
                  },
                );
              });
            }),
      ),
    );
  }
}
