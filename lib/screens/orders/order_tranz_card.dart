import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class OrderTranzCard extends StatelessWidget {
  final String price, employeeName, date, desc, customerName;
  final Function()? onTap;
  OrderTranzCard(
      {required this.price,
      required this.employeeName,
      required this.desc,
      required this.date,
      required this.customerName,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
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
                Row(
                  children: [
                    Icon(
                      Icons.payments,
                      size: 30.0,
                      color: kSubMainColor,
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Text(
                      '$price৳',
                      style: TextStyle(
                        color: kSubMainColor,
                        fontSize: 15.0,
                        fontFamily: 'Montserrat',
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Column(
                      children: [
                        Text(
                          'by $employeeName',
                          style: TextStyle(
                            color: kProductCardColor,
                            fontSize: 15.0,
                            fontFamily: 'Montserrat',
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '$date',
                  style: kProductNameStylePro,
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                SizedBox(
              width: 10.0,
            ),
                Text(
                  '$desc',
                  overflow: TextOverflow.ellipsis,
                  style: kProductNameStylePro,
                ),
              ],
            ),
            SizedBox(
              width: 10.0,
            ),
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: kSubMainColor,
                  size: 30,
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  '$customerName',
                  overflow: TextOverflow.ellipsis,
                  style: kProductNameStylePro,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
