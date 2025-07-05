import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/home_screen_components/product_pop_widget_supplier_info.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/products/new_product_screen.dart';
import 'package:viraeshop_admin/screens/photoslide_show.dart';
import 'iconWidget.dart';

class PopWidget extends StatefulWidget {
  const PopWidget({
    Key? key,
    required this.image,
    required this.info,
    required this.price,
    required this.description,
    required this.isDiscount,
    required this.category,
    required this.discountPrice,
    required this.productName,
    required this.quantity,
    required this.routeName,
    required this.sellBy,
    required this.productCode,
  }) : super(key: key);
  final List image;
  final String productName,
      quantity,
      category,
      price,
      description,
      routeName,
      sellBy,
      productCode;
  final Map<String, dynamic> info;
  final bool isDiscount;
  final num discountPrice;
  @override
  State<PopWidget> createState() => _PopWidgetState();
}

class _PopWidgetState extends State<PopWidget> {
  bool isAnimate = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      // shape: RoundedRectangleBorder().,
      backgroundColor: Colors.black12.withOpacity(0.1),
      contentPadding: const EdgeInsets.all(0.0),
      titlePadding: const EdgeInsets.all(20.0),
      title: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.close_sharp,
          color: kBackgroundColor,
          size: 35.0,
        ),
      ),
      content: Container(
        height: isAnimate ? size.height * 0.63 : size.height * 0.43,
        width: size.width,
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 200,
                // width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      child: CachedNetworkImage(
                        imageUrl:
                            widget.image.isNotEmpty ? widget.image[0] : '',
                        fit: BoxFit.contain,
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
                                  PhotoSlideShow(images: widget.image),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.crop_free_outlined,
                          size: 20.0,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                // heightFactor: 0.45,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.productName}(${widget.productCode})',
                        style: kProductNameStyle,
                      ),
                      Text(
                        widget.category,
                        style: kProductNameStylePro,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        widget.isDiscount
                            ? '${widget.price}৳'
                            : '${widget.price}৳/ ${widget.sellBy}',
                        style: TextStyle(
                          decoration: widget.isDiscount
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: widget.isDiscount
                              ? kIconColor2
                              : Colors.teal[100],
                          fontSize: 12.0,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      widget.isDiscount
                          ? Text(
                              '${widget.discountPrice.toString()}৳/ ${widget.sellBy}',
                              style: TextStyle(
                                color: Colors.teal[100],
                                fontSize: 20.0,
                                fontFamily: 'Montserrat',
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        widget.description,
                        style: kProductNameStylePro,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      SupplierInfo(
                        onAnimate: () {
                          setState(() {
                            isAnimate = !isAnimate;
                          });
                        },
                        isAnimate: isAnimate,
                        address: widget.info['supplier']['address'] ?? '',
                        optionalMobile:
                            widget.info['supplier']['optionalPhone'] ?? '',
                        businessName:
                            widget.info['supplier']['businessName'] ?? '',
                        supplierName:
                            widget.info['supplier']['supplierName'] ?? '',
                        mobile: widget.info['supplier']['mobile'] ?? '',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.all(25.0),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        InkWell(
          onTap: () {
            print(widget.info);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewProduct(
                        info: widget.info,
                        routeName: widget.routeName,
                        isUpdateProduct: true,
                      )),
            );
          },
          child: const IconWidget(icon: Icons.edit_outlined),
        ),
        const IconWidget(
          icon: Icons.share,
        ),
        Container(
          height: widget.quantity.length <= 6 ? 50.0 : null,
          width: widget.quantity.length <= 6 ? null : 100.0,
          padding: const EdgeInsets.only(top: 8.0, left: 3.0, right: 3.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: kMainColor,
            border: Border.all(color: kBackgroundColor, width: 3),
          ),
          child: Text(
            widget.quantity,
            softWrap: true,
            style: const TextStyle(
              fontSize: 20.0,
              color: kBackgroundColor,
              fontFamily: 'Montserrat',
              // fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
