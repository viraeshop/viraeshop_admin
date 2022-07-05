import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

import 'add_user.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<Tab> tabs = [
    Tab(text: 'General'),
    Tab(text: 'Agent'),
    Tab(text: 'Architect'),
  ];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              FontAwesomeIcons.chevronLeft,
              color: kSubMainColor,
            ),
            iconSize: 15.0,
          ),
          title: Text(
            'Customers',
            style: kProductNameStylePro,
          ),
          centerTitle: true,
          bottom: TabBar(
            tabs: tabs,
            indicatorColor: kMainColor,
            labelColor: kMainColor,
            unselectedLabelColor: kSubMainColor,
            labelStyle: TextStyle(
              color: kMainColor,
              fontSize: 15.0,
              letterSpacing: 1.3,
              fontFamily: 'Montserrat',
            ),
            unselectedLabelStyle: kProductNameStylePro,
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateUser(),
                  ),
                );
              },
              icon: Icon(Icons.add),
              iconSize: 20.0,
              color: kSubMainColor,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            Customers(
              role: 'general',
            ),
            Customers(
              role: 'agents',
            ),
            Customers(
              role: 'architect',
            ),
          ],
        ),
      ),
    );
  }
}

class Customers extends StatefulWidget {
  final String role;
  Customers({required this.role});
  @override
  _CustomersState createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  GeneralCrud generalCrud = GeneralCrud();
  bool showSearch = false;
  List customersList = [];
  List tempStore = [];
  initSearch(String value) {
    if (value.length == 0) {
      setState(
        () {
          customersList = tempStore;
        },
      );
    }
    final items = customersList.where((element) {
      final nameLower = element['name'].toLowerCase();
      final mobile = element['mobile'];
      final valueLower = value.toLowerCase();
      return nameLower.contains(valueLower) || mobile.contains(valueLower);
    }).toList();
    final List filtered = [];
    items.forEach((element) {
      filtered.add(element);
    });
    setState(() {
      this.customersList = filtered;
    });
  }

  bool isLoaded = false;
  String statusMessage = 'Fetching customers please wait...';
  @override
  void initState() {
    // TODO: implement initState
    generalCrud.getCustomerList(widget.role).then((snapshot) {
      final data = snapshot.docs;
      data.forEach((element) {
        setState(() {
          customersList.add(element.data());
        });
      });
      setState(() {
        isLoaded = true;
      });
    }).catchError((error) {
      print(error);
      setState(() {
        statusMessage = 'Failed to fetch customers';
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoaded
        ? Container(
            child: ListView.builder(
              itemCount: customersList.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Container(
                    height: 70.0,
                    width: double.infinity,
                    color: kspareColor,
                    padding: EdgeInsets.all(10.0),
                    child: showSearch == false
                        ? Row(
                            children: [
                              InkWell(
                                child: Icon(
                                  Icons.search,
                                  color: kSubMainColor,
                                  size: 25.0,
                                ),
                                onTap: () {
                                  setState(
                                    () {
                                      showSearch = true;
                                      tempStore = customersList;
                                    },
                                  );
                                },
                              ),
                              SizedBox(width: 6.0),
                              Text(
                                'Search by name or phone number',
                                style: kProductNameStylePro,
                              ),
                            ],
                          )
                        : Container(
                            // width: double.infinity,
                            child: Center(
                              child: TextFormField(
                                textAlignVertical: TextAlignVertical.bottom,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  hintText: 'Search user',
                                  hintStyle: TextStyle(
                                    color: kSubMainColor,
                                    fontSize: 15.0,
                                  ),
                                  prefixIcon: IconButton(
                                    onPressed: () {
                                      setState(
                                        () {
                                          showSearch = false;
                                          // print(showSearch);
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      size: 25.0,
                                      color: kSubMainColor,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  // print(value.length);
                                  initSearch(value);
                                },
                              ),
                            ),
                          ),
                  );
                }
                return InkWell(
                  onTap: () {
                    var info = {
                      'id': customersList[i - 1]['userId'],
                      'role': customersList[i - 1]['role'],
                      'name': customersList[i - 1]['name'],
                      'address': customersList[i - 1]['address'],
                      'mobile': customersList[i - 1]['mobile'],
                      'email': customersList[i -1]['email'],
                    };
                    Hive.box('customer').putAll(info).whenComplete(
                          () {
                            Navigator.pop(context);
                            snackBar(text: 'Customer info added', context: context, duration: 30,
                            color: kNewMainColor,
                            );
                          },
                        );
                  },
                  child: Container(
                    height: 80.0,
                    width: double.infinity,
                    padding: EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: kBackgroundColor,
                      border: Border(
                        bottom: BorderSide(color: Colors.black12),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${customersList[i - 1]['name']}',
                                style: kProductNameStylePro,
                              ),
                              Text(
                                widget.role == 'agents'
                                    ? 'Wallet: BDT ${customersList[i - 1]['wallet'].toString()}'
                                    : '${customersList[i - 1]['role']}',
                                style: TextStyle(
                                  color: kSubMainColor,
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  letterSpacing: 1.3,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${customersList[i - 1]['mobile']}',
                                style: kProductNameStylePro,
                              ),
                              Icon(
                                FontAwesomeIcons.chevronRight,
                                color: kSubMainColor,
                                size: 15.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        : Center(
            child: Text(
              statusMessage,
              style: kProductNameStylePro,
            ),
          );
  }
}

// Widget agents() {
//   return FutureBuilder<QuerySnapshot>(
//       future: FirebaseFirestore.instance.collection('agents').get(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: Text(
//               'Loading Plaese wait.....',
//               style: kProductNameStylePro,
//             ),
//           );
//         } else if (snapshot.hasData) {
//           final data = snapshot.data!.docs;
//           List agents = [];
//           data.forEach((element) {
//             agents.add(element.data());
//           });
//           return Container(
//               child: ListView.builder(
//                   itemCount: data.length + 1,
//                   itemBuilder: (context, i) {
//                     if (i == 0) {
//                       return Container(
//                         height: 50.0,
//                         width: double.infinity,
//                         color: kspareColor,
//                         padding: EdgeInsets.all(10.0),
//                         child: showSearch ? Row(                          
//                           children: [
//                             InkWell(
//                               child: Icon(Icons.search,
//                               color: kSubMainColor, size: 25.0,
//                               ),
//                               onTap: () {
//                             setState(
//                               () {
//                                 showSearch = true;
//                                 tempStore = customersList;
//                               },
//                             );
//                           },
//                             ),
//                             SizedBox(
//                               width: 6.0
//                             ),
//                             Text(
//                                 'Search by name',
//                                 style: kProductNameStylePro,
//                               ),
//                           ],
//                         ) : Container(
//                      // width: double.infinity,
//                       child: Center(
//                         child: TextFormField(
//                           textAlignVertical: TextAlignVertical.bottom,
//                           decoration: InputDecoration(
//                             border: InputBorder.none,
//                             focusedBorder: InputBorder.none,
//                             enabledBorder: InputBorder.none,
//                             hintText: 'Search products',
//                             hintStyle: TextStyle(
//                               color: kSubMainColor,
//                               fontSize: 15.0,
//                             ),
//                             prefixIcon: IconButton(
//                               onPressed: () {
//                                 setState(
//                                   () {
//                                     showSearch = false;
//                                     // print(showSearch);
//                                   },
//                                 );
//                               },
//                               icon: Icon(
//                                 Icons.close,
//                                 size: 25.0,
//                                 color: kSubMainColor,
//                               ),
//                             ),
//                           ),
//                           onChanged: (value) {
//                             // print(value.length);
//                             initSearch(value);
//                           },
//                         ),
//                       ),
//                     ),
//                       );
//                     }
//                     return InkWell(
//                       onTap: () {
//                         var info = {
//                           'id': agents[i-1]['id'],
//                           'role': agents[i-1]['role'],
//                           'name': agents[i-1]['name'],
//                         };
//                         Hive.box('customer').putAll(info).whenComplete(() => Navigator.pop(context),);
//                       },
//                       child: Container(
//                         height: 80.0,
//                         width: double.infinity,
//                         padding: EdgeInsets.all(15.0),
//                         decoration: BoxDecoration(
//                           color: kBackgroundColor,
//                           border: Border(
//                             bottom: BorderSide(color: Colors.black12),
//                           ),
//                         ),
//                         child: Center(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     '${agents[i-1]['name']}',
//                                     style: kProductNameStylePro,
//                                   ),
//                                   Text(
//                                     'Wallet: BDT ${agents[i-1]['wallet'].toString()}',
//                                     style: TextStyle(
//                                       color: kSubMainColor,
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 15,
//                                       letterSpacing: 1.3,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     '${agents[i-1]['id']}',
//                                     style: kProductNameStylePro,
//                                   ),
//                                   Icon(
//                                     FontAwesomeIcons.chevronRight,
//                                     color: kSubMainColor,
//                                     size: 15.0,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   }));
//         } else {
//           return Center(
//             child: Text(
//               'Failed to fetch customers',
//               style: kProductNameStylePro,
//             ),
//           );
//         }
//       });
// }

// Widget general() {
//   return FutureBuilder<QuerySnapshot>(
//       future: FirebaseFirestore.instance.collection('general').get(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: Text(
//               'Loading Plaese wait.....',
//               style: kProductNameStylePro,
//             ),
//           );
//         } else if (snapshot.hasData) {
//           final data = snapshot.data!.docs;
//           List agents = [];
//           data.forEach((element) {
//             agents.add(element.data());
//           });
//           return Container(
//               child: ListView.builder(
//                   itemCount: data.length,
//                   itemBuilder: (context, i) {
//                     return InkWell(
//                       onTap: () {
//                         var info = {
//                           'id': agents[i]['id'],
//                           'role': agents[i]['role'],
//                           'name': agents[i]['name'],
//                         };
//                         Hive.box('customer').putAll(info).whenComplete(() => Navigator.pop(context),);                        
//                       },
//                       child: Container(
//                         height: 80.0,
//                         width: double.infinity,
//                         padding: EdgeInsets.all(15.0),
//                         decoration: BoxDecoration(
//                           color: kBackgroundColor,
//                           border: Border(
//                             bottom: BorderSide(color: Colors.black26),
//                           ),
//                         ),
//                         child: Center(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     '${agents[i]['name']}',
//                                     style: kProductNameStylePro,
//                                   ),
//                                   Text(
//                                     '${agents[i]['role']}',
//                                     style: TextStyle(
//                                       color: kSubMainColor,
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 15,
//                                       letterSpacing: 1.3,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     '${agents[i]['id']}',
//                                     style: kProductNameStylePro,
//                                   ),
//                                   Icon(
//                                     FontAwesomeIcons.chevronRight,
//                                     color: kSubMainColor,
//                                     size: 15.0,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   }));
//         } else {
//           return Center(
//             child: Text(
//               'Failed to fetch customers',
//               style: kProductNameStylePro,
//             ),
//           );
//         }
//       });
// }

// Widget architect() {
//   return FutureBuilder<QuerySnapshot>(
//       future: FirebaseFirestore.instance.collection('architect').get(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: Text(
//               'Loading Plaese wait.....',
//               style: kProductNameStylePro,
//             ),
//           );
//         } else if (snapshot.hasData) {
//           final data = snapshot.data!.docs;
//           List agents = [];
//           data.forEach((element) {
//             agents.add(element.data());
//           });
//           return Container(
//               child: ListView.builder(
//                   itemCount: data.length,
//                   itemBuilder: (context, i) {
//                     return InkWell(
//                       onTap: () {
//                         var info = {
//                           'id': agents[i]['id'],
//                           'role': agents[i]['role'],
//                           'name': agents[i]['name'],
//                         };
//                         Hive.box('customer').putAll(info).whenComplete(() => Navigator.pop(context),);
//                       },
//                       child: Container(
//                         height: 80.0,
//                         width: double.infinity,
//                         padding: EdgeInsets.all(15.0),
//                         decoration: BoxDecoration(
//                           color: kBackgroundColor,
//                           border: Border(
//                             bottom: BorderSide(color: Colors.black26),
//                           ),
//                         ),
//                         child: Center(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     '${agents[i]['name']}',
//                                     style: kProductNameStylePro,
//                                   ),
//                                   Text(
//                                     '${agents[i]['role']}',
//                                     style: TextStyle(
//                                       color: kSubMainColor,
//                                       fontFamily: 'Montserrat',
//                                       fontSize: 15,
//                                       letterSpacing: 1.3,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     '${agents[i]['id']}',
//                                     style: kProductNameStylePro,
//                                   ),
//                                   Icon(
//                                     FontAwesomeIcons.chevronRight,
//                                     color: kSubMainColor,
//                                     size: 15.0,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   }));
//         } else {
//           return Center(
//             child: Text(
//               'Failed to fetch customers',
//               style: kProductNameStylePro,
//             ),
//           );
//         }
//       });
// }
