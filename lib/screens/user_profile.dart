import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final tabPages = <Widget>[
    ListView(
      shrinkWrap: true,
      children: [
        const SizedBox(height: 20),
        SizedBox(
            height: 170,
            width: 170,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Container(
                    // color: Colors.red,
                    width: 200,
                    height: 200,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage('assets/default.jpg'),
                            fit: BoxFit.contain)),
                  ),
                ),
                const SizedBox(
                  height: 30,
                  width: 30,
                  child: CircleAvatar(
                    backgroundColor: kSelectedTileColor,
                    child: Icon(
                      Icons.add,
                      size: 30,
                    ),
                  ),
                )
              ],
            )),
        // Second item
        SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => print('Add wallet'),
                  child: Container(
                    width: 150.0,
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    decoration: BoxDecoration(
                        color: kMainColor,
                        borderRadius: BorderRadius.circular(30.0)),
                    child: const Center(
                      child: Text(
                        '\$1000',
                        style: kDrawerTextStyle2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Row(children: [
            MyIcons(icon: Icons.call),
            MyIcons(icon: Icons.sms),
            MyIcons(icon: Icons.email),
            MyIcons(
                icon: Icons.location_city, onClick: () => print('Hello World'))
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: TextField(
            autocorrect: true,
            decoration: InputDecoration(
                labelText: "Full Name",
                hintText: "",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: TextField(
            autocorrect: true,
            decoration: InputDecoration(
                labelText: "Email",
                hintText: "",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: TextField(
            autocorrect: true,
            decoration: InputDecoration(
                labelText: "Phone",
                hintText: "",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: InkWell(
            child: Container(
              width: double.infinity, //MediaQuery.of(context).size.width,
              height: 58,
              decoration: BoxDecoration(
                  color: kSelectedTileColor, //Theme.of(context).accentColor,
                  borderRadius: BorderRadius.circular(15)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Update Profile",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  )
                ],
              ),
            ),
            onTap: () {
              // addProduct();
            },
          ),
        ),
      ],
    ),
    // Second tab
    Center(
        child: Container(
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (BuildContext context, int i) {
          return OrderWidget(name: 'Product Name ${i + 1}', count: i, price: i);
        },
      ),
    ))
  ];
  final _tabs = <Tab>[
    const Tab(
      text: 'Personal Info',
    ),
    const Tab(
      text: 'Order History',
    )
  ];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: kSelectedTileColor),
            elevation: 0.0,
            backgroundColor: kBackgroundColor,
            title: const Text(
              'User Profile',
              style: kAppBarTitleTextStyle,
            ),
            centerTitle: true,
            titleTextStyle: kTextStyle1,
            bottom: TabBar(
              indicatorColor: kMainColor,
              labelColor: kTextColor1,
              tabs: _tabs,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: GestureDetector(
                    onTap: () {
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => NewProduct()));
                    },
                    child: const Icon(Icons.add)),
              )
            ],
          ),
          body: TabBarView(children: tabPages)),
    );
  }
}
