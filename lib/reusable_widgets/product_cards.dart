import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';

class ProductCards extends StatefulWidget {
  final String image;
  final String productName;
  final String productCategory;
  final String productPrice;
  final String productDescription;
  final String discountPrice;
  final String discountPercent;
  final bool isDiscount;
  final onTap;
  ProductCards({
    required this.image,
    required this.productName,
    required this.productCategory,
    required this.productPrice,
    required this.productDescription,
    required this.discountPercent,
    required this.discountPrice,
    required this.isDiscount,
    this.onTap,
  });

  @override
  State<ProductCards> createState() => _ProductCardsState();
}

class _ProductCardsState extends State<ProductCards> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (hovered) {
        setState(() {
          isHovered = hovered;
        });
        print(isHovered);
      },
      onTap: widget.onTap,
      child: LayoutBuilder(
        builder: (context, constraints) => Card(
          elevation: isHovered == true && constraints.maxWidth > 600 ||
                  constraints.maxWidth < 600
              ? 5.0
              : null,
          color: kBackgroundColor,
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(12.0),
          // ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: constraints.maxWidth > 600
                ? null
                : MediaQuery.of(context).size.width * 0.1,
            // decoration: BoxDecoration(
            //     // borderRadius: BorderRadius.circular(12.0),
            //     ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    // height: 130.0,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(7.0),
                        topRight: Radius.circular(7.0),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.image,
                        fit: BoxFit.fill,
                        width: double.infinity,
                        placeholder: (context, url) => LoadingIndicator(
                          indicatorType: Indicator.ballScale,
                          colors: [kIconColor1, kIconColor2],
                          strokeWidth: 2,
                          // backgroundColor: Colors.black,
                          // pathBackgroundColor: Colors.black
                        ),
                        errorWidget: (context, url, childs) {
                          return Image.asset(
                            'assets/default.jpg',
                            width: double.infinity,
                            fit: BoxFit.fill,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: widget.isDiscount
                      ? discountPercentWidget(widget.discountPercent)
                      : SizedBox(),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    height: 140.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kBackgroundColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.productName,
                          style: kProductNameStylePro,
                        ),
                        Text(
                          widget.productCategory.toString(),
                          style: kCategoryNameStyle,
                        ),
                        Text(
                          '${widget.productPrice.toString()} BDT',
                          style: TextStyle(
                            decoration: widget.isDiscount
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: kRedColor,
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            letterSpacing: 1.3,
                          ),
                        ),
                        widget.isDiscount
                            ? Text(
                                '${widget.discountPrice.toString()} BDT',
                                style: TextStyle(
                                  color: kNewTextColor,
                                  fontFamily: 'Montserrat',
                                  fontSize: 17,
                                  letterSpacing: 1.3,
                                ),
                              )
                            : SizedBox(),
                        Text(
                          widget.productDescription.toString(),
                          softWrap: true,
                          style: kProductDescStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
