import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';

class AboutUsPage extends StatelessWidget {
  AboutUsPage({Key? key}) : super(key: key);
  static const String path = 'https://viraeshopprivacypolicy.web.app/';
  final Uri _url = Uri.parse(path);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(FontAwesomeIcons.chevronLeft),
          iconSize: 20.0,
          color: kSubMainColor,
        ),
      ),
      backgroundColor: kBackgroundColor,
      body: Container(
        padding: EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/vira_shop.png',
                height: 150.0,
                width: 150.0,
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                'About Us',
                style: TextStyle(
                  color: kSubMainColor,
                  fontFamily: 'Montserrat',
                  fontSize: 30,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                'Viraeshop is a subsidiary of Modernarc, a company that specializes in offering Architectural services. We sells different kinds of building materials such as Wall-panels, Interior designs, chairs and much more...',
                softWrap: true,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: kSubMainColor,
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  letterSpacing: 1.3,
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
          Linkify(
            onOpen: (link) async {
              if (await canLaunchUrl(_url)) {
                await launchUrl(_url);
              } else {
                throw 'Could not launch $link';
              }
            },
            text: "Privacy Policy: $path",
            style: TextStyle(
              color: kSubMainColor,
              fontFamily: 'Montserrat',
              fontSize: 15,
              letterSpacing: 1.3,
            ),
            linkStyle: TextStyle(
              color: Colors.lightBlueAccent,
              fontFamily: 'Montserrat',
              fontSize: 12,
              letterSpacing: 1.3,
              fontWeight: FontWeight.bold,
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}
