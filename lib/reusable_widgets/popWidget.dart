import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/new_product_screen.dart';
import 'package:viraeshop_admin/screens/photoslide_show.dart';
import 'iconWidget.dart';

Widget popWidget(
        {required List image,
        productName,
        quantity,
        category,
        price,
        description,
        info,
        routeName,
        required bool isDiscount,
        sellBy,
        discountPrice,
        required BuildContext context}) =>
    AlertDialog(
      // shape: RoundedRectangleBorder().,
      backgroundColor: Colors.black12.withOpacity(0.1),
      contentPadding: EdgeInsets.all(0.0),
      titlePadding: EdgeInsets.all(20.0),
      title: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.close_sharp,
          color: kBackgroundColor,
          size: 35.0,
        ),
      ),
      content: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 200,
                // width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: image.isNotEmpty ? image[0] : '',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PhotoSlideShow(images: image),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.crop_free_outlined,
                          size: 20.0,
                          color: kBackgroundColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                // heightFactor: 0.45,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        productName,
                        style: kProductNameStyle,
                      ),
                      Text(
                        category,
                        style: kProductNameStylePro,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        isDiscount ? '$price৳' : '$price৳/ $sellBy',
                        style: TextStyle(
                          decoration: isDiscount
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color:
                              isDiscount ? kIconColor2 : Colors.teal[100],
                          fontSize: 12.0,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      isDiscount
                          ? Text(
                              '${discountPrice.toString()}৳/ $sellBy',
                              style: TextStyle(
                                color: Colors.teal[100],
                                fontSize: 20.0,
                                fontFamily: 'Montserrat',
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        description,
                        style: kProductNameStylePro,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: EdgeInsets.all(25.0),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewProduct(
                        info: info,
                        routeName: routeName,
                        isUpdateProduct: true,
                      )),
            );
          },
          child: IconWidget(icon: Icons.edit_outlined),
        ),
        IconWidget(
          icon: Icons.share,
        ),
        Container(
          height: quantity.length <= 6 ? 50.0 : null,
          width: quantity.length <= 6 ? null : 100.0,
          padding: EdgeInsets.only(top: 8.0, left: 3.0, right: 3.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: kMainColor,
            border: Border.all(color: kBackgroundColor, width: 3),
          ),
          child: Text(
            quantity,
            softWrap: true,
            style: TextStyle(
              fontSize: 20.0,
              color: kBackgroundColor,
              fontFamily: 'Montserrat',
              // fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
