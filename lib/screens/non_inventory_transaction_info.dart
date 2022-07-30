import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/user_transaction_screen.dart';

class NonInventoryInfo extends StatefulWidget {
  final Map data;
  final String invoiceId;
  final Timestamp date;
  final bool? isSupplierPay;
  NonInventoryInfo({required this.data, required this.invoiceId, required this.date, this.isSupplierPay});

  @override
  _NonInventoryInfoState createState() => _NonInventoryInfoState();
}

class _NonInventoryInfoState extends State<NonInventoryInfo> {
  String date = '';
  List images = [];
  List payList = [];
  int imageIndex = 0;
  final formatter = DateFormat('MM/dd/yyyy');
  @override
  void initState() {
    // TODO: implement initState
    Timestamp timestamp = widget.date;
      date = formatter.format(timestamp.toDate());
      images = widget.data['images'] ?? [];
      payList = widget.data['pay_list'] ?? [];
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
      body: Container(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// name
                  Text(
                    '${widget.data['name']}',
                    style: kTotalSalesStyle,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// mobile
                      Text(
                        '${widget.data['mobile']}',
                        style: kProductNameStylePro,
                      ),
                      textContainer(date),
                    ],
                  ),

                  /// email
                  Text(
                    'Email: ${widget.data['email']}',
                    style: kProductNameStylePro,
                  ),

                  /// address
                  Text(
                    '${widget.data['address']}',
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
                      ? Container(
                          height: MediaQuery.of(context).size.height * 0.45,
                          width: MediaQuery.of(context).size.width * 0.4,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: CachedNetworkImage(
                            imageUrl: images[imageIndex],
                            errorWidget: (context, url, childs) {
                              return Image.asset('assets/default.jpg');
                            },
                            height: MediaQuery.of(context).size.height * 0.45,
                            width: MediaQuery.of(context).size.width * 0.4,
                          ),
                        ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    buttons(
                        title: 'Previous',
                        onTap: () {
                          if (imageIndex > 0) {
                            setState(() {
                              imageIndex--;
                              Timestamp timestamp = widget.data['pay_list'][imageIndex]['date'] ?? Timestamp.now();
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
                              Timestamp timestamp = widget.data['pay_list'][imageIndex]['date'] ?? Timestamp.now();
                              date = formatter.format(timestamp.toDate());
                            });
                          }
                        }),
                  ]),
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
                            Timestamp timestamp = payList[index]['date'];
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
                                textContainer(
                                    payList[index]['paid'].toString()),
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

Widget textContainer(String text) {
  return Container(
    padding: const EdgeInsets.all(3.0),
    decoration: BoxDecoration(
      border: Border.all(
        color: kBlackColor,
      ),
      borderRadius: BorderRadius.circular(7.0),
      color: kBackgroundColor,
    ),
    child: Text(
      text,
      style: kCustomerCellStyle,
    ),
  );
}
