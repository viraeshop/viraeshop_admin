import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class SupplierInfo extends StatelessWidget {
  const SupplierInfo(
      {Key? key,
      required this.supplierName,
      required this.address,
      required this.mobile,
      required this.businessName,
      required this.optionalMobile,
      required this.onAnimate, required this.isAnimate,
      })
      : super(key: key);
  final String supplierName;
  final String businessName;
  final String mobile;
  final String optionalMobile;
  final String address;
  final void Function()? onAnimate;
  final bool isAnimate;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Supplier',
              style: kProductNameStylePro,
            ),
            IconButton(
              onPressed: onAnimate,
              icon: Icon(
                isAnimate
                    ? FontAwesomeIcons.chevronUp
                    : FontAwesomeIcons.chevronDown,
              ),
              color: kSubMainColor,
              iconSize: 20.0,
            ),
          ],
        ),
        AnimatedContainer(
          height: isAnimate ? 200.0 : 0.0,
          curve: Curves.fastOutSlowIn,
          duration: const Duration(milliseconds: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: kSubMainColor,
                    size: 40.0,
                    // ),
                  ),
                  title: Text(
                    businessName,
                    style: kProductNameStylePro,
                  ),
                  subtitle: Text(
                    supplierName,
                    style: kProductNameStylePro,
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.call,
                    color: kSubMainColor,
                    size: 20.0,
                  ),
                  title: TextButton(
                    onPressed: () async{
                      final url = Uri.parse('tel:+880$mobile');
                      if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                      }
                    },
                    child: Text(
                      '+880$mobile',
                      style: kProductNameStylePro,
                    ),
                  ),
                  subtitle: TextButton(
                    onPressed: () async{
                      if(optionalMobile.isNotEmpty){
                        final url = Uri.parse('tel:+880$optionalMobile');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      }
                    },
                    child: Text(
                      '+880$optionalMobile',
                      style: kProductNameStylePro,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.storefront,
                    color: kSubMainColor,
                    size: 20.0,
                  ),
                  title: Text(
                    address,
                    style: kProductNameStylePro,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
