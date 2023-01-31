import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/screens/advert/ads_provider.dart';

import '../../configs/baxes.dart';

class SearchBar extends StatelessWidget {
  SearchBar({this.onChange});
  final void Function(String value)? onChange;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250.0,
      height: 45.0,
      padding: EdgeInsets.all(10.0),
      //margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13.0),
        color: kBackgroundColor,
      ),
      child: Center(
        child: Consumer<AdsProvider>(builder: (consumerContext, ads, childs) {
          return TextField(            
            cursorColor: kNewMainColor,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10.0),
              hintText: 'Enter your search here...',
              hintStyle: kProductNameStylePro,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: kBackgroundColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: kBackgroundColor),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: kBackgroundColor),
              ),
            ),
            onTap: (){
              ads.switchSearch(true);
            },
            onChanged: (value) {
              // initSearch(value: value, context: context, temps: ads.products);
              print(value.length);
              List products = Hive.box(productsBox).get(productsKey);
              List tempStore = ads.products;
              if (value.length == 0) {
                ads.switchSearch(false);
                ads.updateProductList(tempStore);                
              }
              if(value.length == 1 && !ads.isSearch){
                ads.switchSearch(true);
              }
              final filteredList = products.where((element) {
                final String nameLower = element['name'].toLowerCase();
                final idLower = element['productCode'].toLowerCase();
                final valueLower = value.toLowerCase();
                return nameLower.contains(valueLower) ||
                    idLower.contains(valueLower);
              }).toList();
              ads.updateProductList(filteredList);
            },
          );
        }),
      ),
    );
  }
}
