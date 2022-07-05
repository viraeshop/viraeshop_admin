// var trash = popDialog(
//                                   context: context,
//                                   widget: SingleChildScrollView(
//                                     padding: EdgeInsets.all(10.0),
//                                     child: Column(
//                                       children: [
//                                         ValueListenableBuilder(
//                                           valueListenable:
//                                               Hive.box('cartDetails')
//                                                   .listenable(),
//                                           builder: (context, Box box, childs) {
//                                             var totalPrice =
//                                                 box.get('totalPrice');
//                                             return Text(
//                                               Hive.box('UserType')
//                                                           .get('userType')
//                                                           .toLowerCase() ==
//                                                       'agents'
//                                                   ? '${totalPrice.toString()} will be deducted, new balance will be ${userInfo['wallet'] - totalPrice}'
//                                                   : 'Click the button below to continue',
//                                               textAlign: TextAlign.center,
//                                             );
//                                           },
//                                         ),
//                                         SizedBox(height: 20),
//                                         InkWell(
//                                             child: Container(
//                                               padding: EdgeInsets.all(15),
//                                               decoration: BoxDecoration(
//                                                   color:
//                                                       kMainColor, //Theme.of(context).accentColor,
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           15)),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.center,
//                                                 children: [
//                                                   Text(
//                                                     // Hive.box('UserType')
//                                                     //             .get('userType')
//                                                     //             .toLowerCase() ==
//                                                     //         'agents'
//                                                     //     ? "Pay Now" :
//                                                     'Order Now',
//                                                     style: TextStyle(
//                                                         fontSize: 20,
//                                                         color: Colors.white),
//                                                   )
//                                                 ],
//                                               ),
//                                             ),
//                                             onTap: () {
//                                               setState(
//                                                 () {
//                                                   isProcessing = true;
//                                                 },
//                                               );
//                                               // This loop will be inside popup's submit button for Pay after clicking submit
//                                               // for (int i = 0;
//                                               //     i < cartItems.length;
//                                               //     i++) {
//                                               //   totalPrice += double.parse(
//                                               //       cartItems[i]['price']);
//                                               // }
//                                               // print(totalPrice);
//                                               // //check  if is agent, use wallet
//                                               List<Map<String, dynamic>>
//                                                   cartItem = [];
//                                               carts.forEach((element) {
//                                                 setState(() {
//                                                   cartItem.add(
//                                                     {
//                                                       'product_name':
//                                                           element.productName,
//                                                       'productId':
//                                                           element.productId,
//                                                       'quantity':
//                                                           element.quantity,
//                                                       'price': element.price,
//                                                     },
//                                                   );
//                                                 });
//                                               });
//                                               print(cartItem);
//                                               String userType =
//                                                   Hive.box('userType').get(
//                                                       'userType',
//                                                       defaultValue: 'general');
//                                               var totalPrice =
//                                                   Hive.box('cartDetails')
//                                                       .get('totalPrice');
//                                               if (userType == 'agents') {
//                                                 if (totalPrice <
//                                                     userInfo['wallet']) {
//                                                   // First deduct from wallet, if successfull, add to order
//                                                   var orderInfo = {
//                                                     'role': userInfo['role'],
//                                                     'customerId':
//                                                         userInfo['userId'],
//                                                     'orderId': orderCode,
//                                                     'quantity':
//                                                         Hive.box('cartDetails')
//                                                             .get('totalItems'),
//                                                     'price':
//                                                         Hive.box('cartDetails')
//                                                             .get('totalPrice'),
//                                                     'payment_status': 'pending',
//                                                     'items': cartItem,
//                                                     'delivery_status':
//                                                         'pending',
//                                                     'order_status': 'pending',
//                                                     'date': Timestamp.now(),
//                                                   };
//                                                   generalCrud
//                                                       .makeOrder(
//                                                           orderInfo, orderCode)
//                                                       .then((success) {
//                                                     //If successfull, add to order items
//                                                     if (success) {
//                                                       // Add to order items here then clear cart
//                                                       setState(() {
//                                                         isProcessing = false;
//                                                       });
//                                                       // ?if order items is inserted
//                                                       showDialogBox(
//                                                         buildContext: context,
//                                                         msg:
//                                                             'Order Successfull',
//                                                       );
//                                                       Navigator.pop(context);
//                                                       // setState(() {
//                                                       //   userInfo['wallet'] =
//                                                       //       userInfo['wallet'] -
//                                                       //           total_price;
//                                                       // });
//                                                       // Clear cart                                                    
//                                                         Hive.box<Cart>('cart')
//                                                             .clear();
//                                                         Hive.box('cartDetails')
//                                                             .clear();                                                      
//                                                     } else {
//                                                       setState(() {
//                                                         isProcessing = false;
//                                                       });
//                                                       Navigator.pop(context);
//                                                     }
//                                                   });
//                                                   // Deduct money First
//                                                   //   adminCrud
//                                                   //       .updateWallet(
//                                                   //           userInfo, total_price)
//                                                   //       .then((res) {
//                                                   //     // Make order after deduct

//                                                   //     // End pay
//                                                   //   });
//                                                   // } else {
//                                                   //
//                                                   // }
//                                                 } else {
//                                                   // no enough funds
//                                                   setState(() {
//                                                     isProcessing = false;
//                                                   });
//                                                   print('Insufficient Funds');
//                                                   showMyDialog(
//                                                       'Insufficient Funds',
//                                                       context);
//                                                 }
//                                               } else {
//                                                 print('Ready to go..');
//                                                 print(
//                                                     'cart ${cartItems.toList()}');
//                                                 var orderInfo = {
//                                                   'role': userInfo['role'],
//                                                   'customerId':
//                                                       userInfo['userId'],
//                                                   'orderId': orderCode,
//                                                   'quantity':
//                                                       Hive.box('cartDetails')
//                                                           .get('totalItems'),
//                                                   'price':
//                                                       Hive.box('cartDetails')
//                                                           .get('totalPrice'),
//                                                   'payment_status': 'pending',
//                                                   'items': cartItem,
//                                                   'delivery_status': 'pending',
//                                                   'order_status': 'pending',
//                                                   'date': Timestamp.now(),
//                                                 };
//                                                 generalCrud
//                                                     .makeOrder(
//                                                         orderInfo, orderCode)
//                                                     .then((success) {
//                                                   //If successfull, add to order items
//                                                   if (success) {
//                                                     // Add to order items here then clear cart
//                                                     setState(() {
//                                                       isProcessing = false;
//                                                     });
//                                                     // ?if order items is inserted
//                                                     showDialogBox(
//                                                         buildContext: context,
//                                                         msg:
//                                                             'Order Successfull');

//                                                     //   userInfo['wallet'] =
//                                                     //       userInfo['wallet'] -
//                                                     //           total_price;
//                                                     // });
//                                                     // Clear cart
//                                                     Hive.box<Cart>('cart')
//                                                         .clear();
//                                                     Hive.box('cartDetails')
//                                                         .clear();
//                                                   } else {
//                                                     setState(() {
//                                                       isProcessing = false;
//                                                     });
//                                                   }
//                                                 });
//                                               }
//                                             }),
//                                       ],
//                                     ),
//                                   ),
//                                   title: 'Order Info');

//                               // Navigator.pop(context);

// else {
//                               Box<Cart> cart = Hive.box<Cart>('cart');
//                               cart
//                                   .put(
//                                     productsList[index]['id'],
//                                     Cart(
//                                       productName: productsList[index]['name'],
//                                       productId: productsList[index]['id'],
//                                       price: price,
//                                       quantity: 1,
//                                     ),
//                                   )
//                                   .whenComplete(() => print('completed'))
//                                   .onError(
//                                     (error, stackTrace) => print(error),
//                                   );
//                             }