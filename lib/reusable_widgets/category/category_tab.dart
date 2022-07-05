import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.imageUrl,
    required this.title,
    this.onTap,
    required this.isSelected,
  });
  final String title;
  final String imageUrl;
  final bool isSelected;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10.0),
            height: 50.0,
            width: 60.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  imageUrl,
                ),
                fit: BoxFit.cover,
              ),
              color: kCategoryBackgroundColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          // SizedBox(height: 3.0),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? kNewMainColor : kSubMainColor,
              fontSize: 15.0,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
            ),
          ),          
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
