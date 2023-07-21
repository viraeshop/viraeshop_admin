import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({Key? key,
    required this.imageUrl,
    required this.title,
    this.onTap,
    required this.isSelected,
    this.isAssetImage = false,
    this.isSubCategory = false,
  }) : super(key: key);
  final String title;
  final String imageUrl;
  final bool isSelected;
  final bool isAssetImage;
  final bool isSubCategory;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(7.0),
            padding: const EdgeInsets.all(3.0),
            height: 75.0,
            width: isSubCategory ? 100.0 : 150.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: image(isAssetImage, imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.srcOver,
                ),
              ),
              color: kCategoryBackgroundColor,
              borderRadius: BorderRadius.circular(12.0),
              // border: Border.all(
              //   color: isSelected ? kNewMainColor : kSubMainColor,
              //   width: 3.0,
              // ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? kNewMainColor : kBackgroundColor,
                  //backgroundColor: Colors.white24,
                  fontSize: 13.0,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // SizedBox(height: 3.0),
          // isSelected
          //     ? Column(
          //       children: [
          //         SizedBox(height: 3.0),
          //         Container(
          //             height: 8.0,
          //             width: 30.0,
          //             decoration: BoxDecoration(
          //               color: kNewMainColor,
          //               borderRadius: BorderRadius.circular(20.0),
          //             ),
          //           ),
          //       ],
          //     )
          //     : SizedBox(),
        ],
      ),
    );
  }
}

ImageProvider image(bool isAssetImage, String path) {
  if (isAssetImage) {
    return AssetImage(path);
  } else {
    return CachedNetworkImageProvider(
      path,
    );
  }
}
