import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/screens/transactions/user_transaction_screen.dart';
import 'package:viraeshop_api/models/suppliers/suppliers.dart';
import 'package:viraeshop_api/utils/utils.dart';

import '../photoslide_show.dart';

class NonInventoryInfo extends StatefulWidget {
  final Map data;
  final String invoiceId;
  final Timestamp date;
  final bool isSupplierPay;
  const NonInventoryInfo(
      {required this.data,
      required this.invoiceId,
      required this.date,
      this.isSupplierPay = false,
      Key? key})
      : super(key: key);

  @override
  _NonInventoryInfoState createState() => _NonInventoryInfoState();
}

class _NonInventoryInfoState extends State<NonInventoryInfo> {
  String date = '';
  List images = [];
  List payList = [];
  Suppliers? supplier;
  int imageIndex = 0;
  final formatter = DateFormat('MM/dd/yyyy');
  @override
  void initState() {
    // TODO: implement initState
    Timestamp timestamp = widget.date;
    date = formatter.format(timestamp.toDate());
    images = widget.data['images'] ?? [];
    payList = widget.isSupplierPay
        ? widget.data['payList']
        : widget.data['paylist'] ?? [];
    supplier = widget.isSupplierPay
        ? Suppliers.fromJson(widget.data['supplierInfos'])
        : widget.data['supplierInfo'] is! Suppliers
            ? Suppliers.fromJson(widget.data['supplierInfo'])
            : widget.data['supplierInfo'];
    print(images);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(FontAwesomeIcons.chevronLeft),
          color: kSubMainColor,
          iconSize: 20.0,
        ),
        title: const Text(
          'Non Inventory',
          style: kAppBarTitleTextStyle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// name
                  Text(
                    '${supplier?.businessName}',
                    style: kTotalSalesStyle,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// mobile
                      Text(
                        '${supplier?.mobile}',
                        style: kProductNameStylePro,
                      ),
                      textContainer(date),
                    ],
                  ),
        
                  /// email
                  Text(
                    'Email: ${supplier?.email}',
                    style: kProductNameStylePro,
                  ),
        
                  /// address
                  Text(
                    '${supplier?.address}',
                    style: kProductNameStylePro,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      textContainer('Invoice No.'),
                      const SizedBox(
                        width: 5.0,
                      ),
        
                      /// Invoice no
                      Text(
                        widget.invoiceId,
                        style: kTotalSalesStyle,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  images.isEmpty
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.45,
                          width: MediaQuery.of(context).size.width * 0.7,
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              clipBehavior: Clip.hardEdge,
                              child: CachedNetworkImage(
                                imageUrl: images[imageIndex]['imageLink'],
                                errorWidget: (context, url, childs) {
                                  return Image.asset('assets/default.jpg');
                                },
                                height: MediaQuery.of(context).size.height * 0.45,
                                width: MediaQuery.of(context).size.width * 0.7,
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
                                      builder: (context) => PhotoSlideShow(
                                        images: images,
                                        initialPage: imageIndex,
                                      ),
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
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    buttons(
                        title: 'Previous',
                        onTap: () {
                          if (imageIndex > 0) {
                            setState(() {
                              imageIndex--;
                              Timestamp timestamp =
                                  dateFromJson(payList[imageIndex]['createdAt']);
                              date = formatter.format(timestamp.toDate());
                            });
                          }
                        }),
                    const SizedBox(
                      width: 10.0,
                    ),
                    buttons(
                        title: 'Next',
                        onTap: () {
                          if (imageIndex < images.length - 1) {
                            setState(() {
                              imageIndex++;
                              Timestamp timestamp =
                                  dateFromJson(payList[imageIndex]['createdAt']);
                              date = formatter.format(timestamp.toDate());
                            });
                          }
                        }),
                  ]),
                  const SizedBox(
                    height: 7.0,
                  ),
                  Text(
                    'Total Buying Price: ${widget.data['buyPrice']}$bdtSign',
                    style: kTableCellStyle,
                  ),
                  const SizedBox(
                    height: 7.0,
                  ),
                  Column(
                    children: payList.isEmpty
                        ? [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                textContainer('Pay'),
                                const SizedBox(
                                  width: 3.0,
                                ),
                                textContainer('        '),
                                const SizedBox(
                                  width: 3.0,
                                ),
                                textContainer('        '),
                              ],
                            )
                          ]
                        : List.generate(payList.length, (index) {
                            Timestamp timestamp =
                                dateFromJson(payList[index]['createdAt']);
                            final formatter = DateFormat('MM/dd/yyyy');
                            String dateTime = formatter.format(
                              timestamp.toDate(),
                            );
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                textContainer('Pay'),
                                const SizedBox(
                                  width: 3.0,
                                ),
                                textContainer(dateTime),
                                const SizedBox(
                                  width: 3.0,
                                ),
                                textContainer(payList[index]['paid'].toString()),
                              ],
                            );
                          }),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget textContainer(String text, [bool isSelected = false]) {
  return Container(
    padding: const EdgeInsets.all(3.0),
    decoration: BoxDecoration(
      border: Border.all(
        color: isSelected ? kBlackColor : Colors.transparent,
      ),
      borderRadius: BorderRadius.circular(7.0),
      color: isSelected ? kNewMainColor : kBackgroundColor,
    ),
    child: Text(
      text,
      style: kCustomerCellStyle.copyWith(
        color: isSelected ? Colors.white : kBlackColor,
      ),
    ),
  );
}
