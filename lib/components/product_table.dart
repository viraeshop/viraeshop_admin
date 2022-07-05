import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class Product extends StatefulWidget {
  final String image;
  final String productName;
  final String productDesc;
  final String productPrice;
  Product({
    required this.image,
    required this.productDesc,
    required this.productName,
    required this.productPrice,
  });

  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: kBackgroundColor,
      child: Container(
        padding: EdgeInsets.all(10.0),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: CachedNetworkImage(
                      width: 50.0,
                      height: 50.0,
                      imageUrl: widget.image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return Image(
                          image: AssetImage('assets/default.jpg'),
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.productName,
                      style: kTextStyle1,
                    ),

                    /// TODO: change this to category
                    Text(
                      widget.productDesc,
                      style: kTextStyle1,
                    ),
                  ],
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  widget.productPrice,
                  style: kTextStyle1,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
