import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/screens/advert/ads_provider.dart';

import 'category_tab.dart';

class Categories extends StatelessWidget {
  const Categories({
    required this.catLength,
    required this.categories,
    Key? key,
  }) : super(key: key);
  final int catLength;
  final List categories;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kBackgroundColor,
      ),
      child: LimitedBox(
        maxHeight: 110.0,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: catLength,
            itemBuilder: (context, i) {
              return Consumer<AdsProvider>(builder: (context, ads, childs) {
                if(i == 0){
                  return Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: CategoryCard(
                    title: 'All',
                    imageUrl: 'https://firebasestorage.googleapis.com/v0/b/vira-eshop.appspot.com/o/categories%2FOriginal%20Style%20-%20Something%20Yellow%20(3).jpeg?alt=media&token=f109e833-6e5c-43a1-b60d-6f848798b1f6',
                    isSelected: ads.currentCatg == 'All',
                    onTap: () {
                      Provider.of<AdsProvider>(context, listen: false).updateCatg('All');
                    },
                ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: CategoryCard(
                    title: categories[i-1]['category'],
                    imageUrl: categories[i-1]['image'],
                    isSelected: ads.currentCatg == categories[i-1]['category'],
                    onTap: () {
                      Provider.of<AdsProvider>(context, listen: false).updateCatg(categories[i-1]['category']);
                    },
                  ),
                );
              });
            }),
      ),
    );
  }
}
