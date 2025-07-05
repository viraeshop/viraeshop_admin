import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

Widget MyIcons({icon = Icons.add, onClick}) {
  return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: onClick,
        child: CircleAvatar(
            backgroundColor: kSelectedTileColor,
            child: Icon(
              icon,
              color: Colors.white,
            )),
      ));
}

Widget myLoader({text = 'Loading..', visibility = false}) {
  return Visibility(
    visible: visibility,
    child: Center(
        child: Card(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
            Text(text)
          ],
        ),
      ),
    )),
  );
}

Future<void> showMyDialog(String text, BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(12.0),
        title: const Text('Notice', style: kSourceSansStyle,),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(text),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'OK',
              style: kSourceSansStyle,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

//
myField(
    {myController,
    hint = "",
    input_type = "text",
    Color color = Colors.transparent,
    border_radius = 15.0, bool obscure = false}) {
  return TextField(
    obscureText: obscure,
    controller: myController,
    keyboardType: input_type == "number"
        ? TextInputType.number
        : input_type == "email"
            ? TextInputType.emailAddress
            : input_type == "password"
                ? TextInputType.visiblePassword
                : TextInputType.text,
    decoration: InputDecoration(
      fillColor: color,
      filled: true,
      // prefixIcon: const Icon(
      //   Icons.person,
      //   color: Colors.grey,
      // ),
      // hintText: hint,
      labelText: hint,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(border_radius)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: kMainColor),
      ),
      // focusedBorder: new OutlineInputBorder(
      //   borderRadius: new BorderRadius.circular(25.0),
      //   borderSide: BorderSide(color: Colors.green),
      // ),
    ),
  );
}

// Chats
Widget myChat({text = ''}) {
  return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const CircleAvatar(
            backgroundImage: AssetImage('assets/default.jpg'),
          ),
          Container(
            width: 150.0,
            padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: kMainColor,
                ),
                child: Center(child: Text('$text'),
                ),
                ),         
        ],
      ));
}
//

// Guest Message
Widget guestChat({text = ''}) {
  return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.red[300],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('$text'),
                )),
          ),
          const CircleAvatar(
            backgroundImage: AssetImage('assets/default.jpg'),
          ),
        ],
      ));
}

// Product
Widget ProductWidget(
    {name = 'Product Name',
    category = 'Tech',
    price = 110,
    description = 'Short description goes Here',
    required String image}) {
  Widget imageWidget = image.isNotEmpty
      ? Container(
          // color: kMainColor,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
            image: DecorationImage(
              image: NetworkImage(image),
            ),
          ),
        )
      : Container(
          // color: kMainColor,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18)),
            color: Colors.red,
            image: DecorationImage(
                image: AssetImage('assets/default.jpg'), fit: BoxFit.cover),
          ),
        );
  double boxHeigth = 110;
  return Padding(
    padding: const EdgeInsets.all(3.0),
    child: SizedBox(
      height: boxHeigth,
      width: double.infinity,
      child: Card(
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) {
                    return const Image(
                      image: AssetImage('assets/default.jpg'),
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                  child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 10, 5, 5),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$category',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      '\$$price',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$description',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              )),
            )
          ],
        ),
      ),
    ),
  );
}

// New
Widget OrderWidget(
    {name = 'Product Name',
    count = '00',
    price = 00,
    description = 'Short description goes Here',
    image = ''}) {
  double boxHeigth = 90;
  // Define image container if url is or not empty
  Widget imWidget = image == ''
      ? Container(
          // color: kMainColor,
          decoration: BoxDecoration(
              color: kMainColor, //Theme.of(context).accentColor,
              image: const DecorationImage(
                  image: AssetImage('assets/default.jpg'), fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(15)),
        )
      : Container(
          // color: kMainColor,
          decoration: BoxDecoration(
              color: kMainColor, //Theme.of(context).accentColor,
              image: DecorationImage(
                  image: NetworkImage(image), fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(15)),
        );
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
    child: SizedBox(
      height: boxHeigth,
      width: double.infinity,
      child: Card(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: imWidget,
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                  child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name',
                      style: const TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 20),
                    ),
                    // Text(
                    //   '$category',
                    //   style: TextStyle(fontSize: 12),
                    // ),
                    Text('\$$price',
                        style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black54)),
                    // Text(
                    //   '$description',
                    //   style: TextStyle(fontSize: 12),
                    // ),
                  ],
                ),
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('$count'),
            )
          ],
        ),
      ),
    ),
  );
}

Future<void> popDialog({widget, context, title = ''}) async {
  StateSetter setState;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: StatefulBuilder(
          // You need this, notice the parameters below:
          builder: (BuildContext context, StateSetter setState) {
            setState = setState;
            return widget;
          },
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
        ),
        // actions: <Widget>[
        //   InkWell(
        //     child: Text('OK   '),
        //     onTap: () {
        //       // if (_formKey.currentState.validate()) {
        //       //   // Do something like updating SharedPreferences or User Settings etc.
        //       //   Navigator.of(context).pop();
        //       // }
        //       Navigator.of(context).pop();
        //     },
        //   ),
        // ],
      );
    },
  );
}

Widget bottomCard({context, text = 'Click Me', onTap}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: 53,
      decoration: BoxDecoration(
          // border: Border.all(color: kMainColor, width: 1),
          color: kSubMainColor, //Theme.of(context).accentColor,
          borderRadius: BorderRadius.circular(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
                fontSize: 20,
                color: kBackgroundColor,
                fontFamily: 'Montserrat',
                letterSpacing: 1.3),
          )
        ],
      ),
    ),
  );
}

TransBtn({context, text = 'Click Me', onTap}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: 60, //MediaQuery.of(context).size.width,
      height: 33,
      decoration: BoxDecoration(
          border: Border.all(color: kMainColor, width: 1),
          color: Colors.white, //Theme.of(context).accentColor,
          borderRadius: BorderRadius.circular(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 20, color: kMainColor),
          )
        ],
      ),
    ),
  );
}
