import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class OrderTranzCard extends StatelessWidget {
  final String price, employeeName, date, desc, customerName;
  final String? invoiceId;
  final Function()? onTap;
  const OrderTranzCard(
      {required this.price,
      required this.employeeName,
      required this.desc,
      required this.date,
      required this.customerName,
      required this.onTap,
      this.invoiceId,
      }
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          color: kBackgroundColor,
          border: Border(
            bottom: BorderSide(color: kStrokeColor),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.payments,
                        size: 30.0,
                        color: kSubMainColor,
                      ),
                      const SizedBox(
                        width: 15.0,
                      ),
                      Text(
                        '$price৳',
                        style: const TextStyle(
                          color: kSubMainColor,
                          fontSize: 15.0,
                          fontFamily: 'Montserrat',
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'by $employeeName',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: kProductCardColor,
                                fontSize: 15.0,
                                fontFamily: 'Montserrat',
                                letterSpacing: 1.3,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  date,
                  style: kProductNameStylePro,
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                const SizedBox(
              width: 10.0,
            ),
                Expanded(
                  child: Text(
                    desc,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: kProductNameStylePro,
                  ),
                ),
              ],
            ),
            const SizedBox(
             height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: kSubMainColor,
                        size: 30,
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Text(
                          customerName,
                          overflow: TextOverflow.ellipsis,
                          style: kProductNameStylePro,

                        ),
                      ),
                    ],
                  ),
                ),
                invoiceId != null ? Text(
                  'Invoice No: $invoiceId',
                  overflow: TextOverflow.ellipsis,
                  style: kTableCellStyle,
                ) : const SizedBox()
              ],
            ),
          ],
        ),
      ),
    );
  }
}
