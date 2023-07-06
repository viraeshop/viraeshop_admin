// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:viraeshop_admin/settings/general_crud.dart';
// import 'package:viraeshop_api/apiCalls/migration.dart';
// import 'package:viraeshop_api/apiCalls/category.dart';
// import 'package:viraeshop_api/apiCalls/suppliers.dart';
//
// import 'package:viraeshop_admin/utils/network_utilities.dart';
// import 'package:viraeshop_api/models/products/product_category.dart';
// import 'package:viraeshop_api/models/suppliers/suppliers.dart';
// import 'package:viraeshop_api/utils/utils.dart';
//
// class TestingScreen extends StatefulWidget {
//   const TestingScreen({Key? key}) : super(key: key);
//
//   @override
//   State<TestingScreen> createState() => _TestingScreenState();
// }
//
// class _TestingScreenState extends State<TestingScreen> {
//   Migrate api = Migrate();
//   CategoryCalls catCalls = CategoryCalls();
//   SupplierCalls supCalls = SupplierCalls();
//   GeneralCrud generalCrud = GeneralCrud();
//   List<Map<String, dynamic>> customers = [];
//   List<Map<String, dynamic>> affected = [];
//   List<Map<String, dynamic>> admins = [];
//   List<Map<String, dynamic>> suppliers = [];
//   List<Map<String, dynamic>> categories = [];
//   List<ProductCategory> savedCategories = [];
//   List<Suppliers> savedSuppliers = [];
//   List<Map<String, dynamic>> products = [];
//   List<Map<String, dynamic>> transactions = [];
//   List<Map<String, dynamic>> supplierInvoices = [];
//   List payList = [];
//   List receiptImages = [];
//   List userIds = [
//     'R5um1O50uaW6SWNUlxxUt4Ser0n2',
//     'mC2LOOGPGEQ6oqq4VjQhyov6XIO2',
//   ];
//   bool isLoading = false;
//   @override
//   Widget build(BuildContext context) {
//     return ModalProgressHUD(
//       inAsyncCall: isLoading,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Testing Screen'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               ElevatedButton(
//                 child: const Text("Migrate Customers"),
//                 onPressed: () async {
//                   try {
//                     final response = await api.migrateCustomers(customers);
//                     debugPrint(response.toString());
//                   } catch (error) {
//                     debugPrint(error.toString());
//                   }
//                 },
//               ),
//               ElevatedButton(
//                 child: const Text("Get Customers"),
//                 onPressed: () async {
//                   setState(() {
//                     isLoading = true;
//                   });
//                   try {
//                     final result = await generalCrud.getCustomerList('All');
//                     for (var element in result.docs) {
//                       if (kDebugMode) {
//                         print(element.data());
//                       }
//                       final customer = element.data() as Map<String, dynamic>;
//                       if (customer.containsKey('userId')) {
//                         customers.add({
//                           'businessName': customer['business_name'] ?? '',
//                           'address': customer['address'],
//                           'role': customer['role'],
//                           'mobile': customer['mobile'],
//                           'name': customer['name'],
//                           'customerId': customer['userId'],
//                           'email': customer['email'],
//                           'wallet': customer['wallet'] ?? 0,
//                           'active': true,
//                           'profileImage': customer['profileImage'] ?? '',
//                           'isNewRequest': false,
//                         });
//                       } else {
//                         customers.add({
//                           'businessName': customer['business_name'] ?? '',
//                           'address': customer['address'],
//                           'role': customer['role'],
//                           'mobile': customer['mobile'],
//                           'name': customer['name'],
//                           'customerId':
//                               customer['email'] == 'rajibhossenraju5@gmail.com'
//                                   ? userIds[0]
//                                   : userIds[1],
//                           'email': customer['email'],
//                           'wallet': customer['wallet'] ?? 0,
//                           'active': true,
//                           'profileImage': customer['profileImage'] ?? '',
//                           'isNewRequest': false,
//                         });
//                       }
//                     }
//                     print('Fresh data: $customers');
//                     print('Affected data: $affected');
//                   } catch (error, trace) {
//                     debugPrint(error.toString());
//                     debugPrint(trace.toString());
//                   } finally {
//                     setState(() {
//                       isLoading = false;
//                     });
//                   }
//                 },
//               ),
//               ElevatedButton(
//                 child: const Text("Get Admins"),
//                 onPressed: () async {
//                   setState(() {
//                     isLoading = true;
//                     admins.clear();
//                   });
//                   try {
//                     final result = await generalCrud.getUsers('users');
//                     for (var element in result.docs) {
//                       final admin = element.data() as Map<String, dynamic>;
//                       admin['active'] = true;
//                       admins.add(admin);
//                     }
//                     print(admins);
//                   } catch (error) {
//                     print(error);
//                   } finally {
//                     setState(() {
//                       isLoading = false;
//                     });
//                   }
//                 },
//               ),
//               ElevatedButton(
//                 child: const Text("Migrate Admins"),
//                 onPressed: () async {
//                   try {
//                     final response = await api.migrateAdmins(admins);
//                     debugPrint(response.toString());
//                   } catch (error) {
//                     debugPrint(error.toString());
//                   }
//                 },
//               ),
//               ElevatedButton(
//                 child: const Text("Get Suppliers"),
//                 onPressed: () async {
//                   setState(() {
//                     isLoading = true;
//                     suppliers.clear();
//                   });
//                   try {
//                     final result = await generalCrud.getUsers('suppliers');
//                     for (var element in result.docs) {
//                       final supplier = element.data() as Map<String, dynamic>;
//                       suppliers.add({
//                         'businessName': supplier['business_name'],
//                         'address': supplier['address'],
//                         'mobile': supplier['mobile'],
//                         'profileImage': supplier['profileImage'],
//                         'optionalPhone': supplier['optional_phone'],
//                         'supplierName': supplier['supplier_name'],
//                         'email': supplier['email'],
//                         'active': true,
//                       });
//                     }
//                     print(suppliers);
//                   } catch (error) {
//                     print(error);
//                   } finally {
//                     setState(() {
//                       isLoading = false;
//                     });
//                   }
//                 },
//               ),
//               ElevatedButton(
//                 child: const Text("Migrate Suppliers"),
//                 onPressed: () async {
//                   try {
//                     final response = await api.migrateSuppliers(suppliers);
//                     debugPrint(response.toString());
//                   } catch (error) {
//                     debugPrint(error.toString());
//                   }
//                 },
//               ),
//               ElevatedButton(
//                 child: const Text("Get Categories"),
//                 onPressed: () async {
//                   setState(() {
//                     isLoading = true;
//                   });
//                   categories.clear();
//                   try {
//                     final result = await generalCrud.getCategories();
//                     for (var element in result.docs) {
//                       final category = element.data() as Map<String, dynamic>;
//                       categories.add({
//                         'image': category['image'],
//                         'category': category['category_name'],
//                       });
//                     }
//                     print(categories);
//                   } catch (error) {
//                     print(error);
//                   } finally {
//                     setState(() {
//                       isLoading = false;
//                     });
//                   }
//                 },
//               ),
//               ElevatedButton(
//                 child: const Text("Migrate Categories"),
//                 onPressed: () async {
//                   try {
//                     final response = await api.migrateCategories(categories);
//                     debugPrint(response.toString());
//                   } catch (error) {
//                     debugPrint(error.toString());
//                   }
//                 },
//               ),
//               ElevatedButton(
//                 child: const Text("Get Products"),
//                 onPressed: () async {
//                   setState(() {
//                     isLoading = true;
//                   });
//                   savedCategories.clear();
//                   savedSuppliers.clear();
//                   products.clear();
//                   try {
//                     final catResult = await catCalls.getCategories();
//                     final suppliersResult = await supCalls.getSuppliers('');
//                     savedCategories = catResult.result;
//                     savedSuppliers = suppliersResult.result;
//                     final result = await generalCrud.getProducts();
//                     for (var element in result.docs) {
//                       final product = element.data() as Map<String, dynamic>;
//                       List images = [];
//                       if (product['image'].isNotEmpty) {
//                         images = product['image']
//                             .map((e) => {
//                                   'imageLink': e,
//                                   //'productId': product['productId'],
//                                 })
//                             .toList();
//                       }
//                       for (var category in savedCategories) {
//                         if (category.category == product['category']) {
//                           product['categoryId'] = idToJson(category.categoryId);
//                         }
//                       }
//                       for (var supplier in savedSuppliers) {
//                         if (product['supplier'].isNotEmpty) {
//                           if (supplier.businessName ==
//                               product['supplier']['business_name']) {
//                             product['supplierId'] = supplier.supplierId;
//                           }
//                         } else {
//                           product['supplierId'] = 6;
//                         }
//                       }
//                       products.add({
//                         'images': images,
//                         'isGeneralDiscount': product['isGeneralDiscount'],
//                         'quantity': product['quantity'],
//                         'productCode': product['productId'],
//                         'description': product['description'],
//                         'agentsDiscount': product['agentsDiscount'],
//                         'generalPrice': product['generalPrice'],
//                         'sellBy': product['sell_by'],
//                         'isAgentDiscount': product['isAgentDiscount'],
//                         'generalDiscount': product['generalDiscount'],
//                         'isInfinity': product['isInfinity'],
//                         'name': product['name'],
//                         'agentsPrice': product['agentsPrice'],
//                         'architectPrice': product['architectPrice'],
//                         'isArchitectDiscount': product['isArchitectDiscount'],
//                         'category': product['category'],
//                         'minimum': product['minimum'],
//                         'architectDiscount': product['architectDiscount'],
//                         'costPrice': product['cost_price'],
//                         'categoryId': product['categoryId'],
//                         'supplierId': product['supplierId']
//                       });
//                     }
//                     print(products);
//                   } catch (error) {
//                     print(error);
//                   } finally {
//                     setState(() {
//                       isLoading = false;
//                     });
//                   }
//                 },
//               ),
//               ElevatedButton(
//                 child: const Text("Migrate Categories"),
//                 onPressed: () async {
//                   try {
//                     final response = await api.migrateProducts(products);
//                     debugPrint(response.toString());
//                   } catch (error) {
//                     debugPrint(error.toString());
//                   }
//                 },
//               ),
//               ElevatedButton(
//                 child: const Text("Get Transactions"),
//                 onPressed: () async {
//                   setState(() {
//                     isLoading = true;
//                   });
//                   transactions.clear();
//                   supplierInvoices.clear();
//                   try {
//                     final result = await generalCrud.getTransaction();
//                     final suppliersResult = await supCalls.getSuppliers('');
//                     savedSuppliers = suppliersResult.result;
//                     for (var element in result.docs) {
//                       final transaction =
//                           element.data() as Map<String, dynamic>;
//                       if (!transaction.containsKey('isSupplierInvoice')) {
//                         transaction['invoice_id'] =
//                             int.parse(transaction['invoice_id']) + 1;
//                         transaction['date'] = dateToJson(transaction['date']);
//                         List customerPayList = [];
//                         List shops = [];
//                         List soldItems = transaction['items']
//                             .map((item) => {
//                                   'productId': item['product_id'],
//                                   'buyPrice': item['buy_price'],
//                                   'isInventory': item['isInventory'],
//                                   'productName': item['product_name'],
//                                   'productPrice': item['product_price'],
//                                   'unitPrice': item['unit_price'],
//                                   'quantity': item['quantity'],
//                                   'shopName': item['shopName'] ?? '',
//                                   'invoiceNo': transaction['invoice_id'],
//                                 })
//                             .toList();
//                         if (transaction.containsKey('pay_list')) {
//                           customerPayList = transaction['pay_list']
//                               .map((e) => {
//                                     'createdAt': dateToJson(e['date']),
//                                     'paid': e['paid'],
//                                     'invoiceNo': transaction['invoice_id'],
//                                   })
//                               .toList();
//                         }
//                         if (transaction['isWithNonInventory']) {
//                           for (var shop in transaction['shop']) {
//                             for (var supplier in savedSuppliers) {
//                               if (supplier.businessName ==
//                                   shop['business_name']) {
//                                 shop['supplierId'] = supplier.supplierId;
//                               }
//                             }
//                             // if (shop.containsKey('pay_list')) {
//                             //   print('Paylist: ${shop['pay_list']}');
//                             //   payList = shop['pay_list'].map((e) => '').toList();
//                             // }
//                             // if (shop.containsKey('images')) {
//                             //   receiptImages = shop['images'].map((e) => {
//                             //     'imageLink': e,
//                             //     'invoiceNo': transaction['invoice_id'],
//                             //   }).toList();
//                             //   print('ReceiptImages: $receiptImages');
//                             // }
//                             shops.add({
//                               'buyPrice': shop['buyPrice'],
//                               'description': shop['description'],
//                               'due': shop['due'],
//                               'paid': shop['paid'],
//                               'price': shop['price'],
//                               'profit': shop['profit'],
//                               'supplierId': shop['supplierId'],
//                               'invoiceNo': transaction['invoice_id'],
//                             });
//                           }
//                         }
//                         transactions.add({
//                           'createdAt': transaction['date'],
//                           'quantity': transaction['quantity'],
//                           'discount': transaction['discount'],
//                           'role': transaction['customer_role'],
//                           'advance': transaction['advance'],
//                           'isWithNonInventory':
//                               transaction['isWithNonInventory'],
//                           'due': transaction['due'],
//                           'price': transaction['price'],
//                           'adminId': transaction['employee_id'],
//                           'paid': transaction['paid'],
//                           'invoiceNo': transaction['invoice_id'],
//                           'customerId': transaction['customer_id'],
//                           'profit': transaction['profit'],
//                           'shops': shops,
//                           'items': soldItems,
//                           'payList': customerPayList,
//                         });
//                       } else {
//                         List images = transaction['images'].map((e) => {
//                               'imageLink': e,
//                               'invoiceNo': transaction['invoice_id'],
//                             }).toList();
//                         List payList = transaction['pay_list'].map((e) => {
//                               'createdAt': dateToJson(e['date']),
//                               'paid': e['paid'],
//                             }).toList();
//                           for (var supplier in savedSuppliers) {
//                             if (supplier.businessName ==
//                                 transaction['business_name']) {
//                               transaction['supplierId'] = supplier.supplierId;
//                             }
//                           }
//                         supplierInvoices.add({
//                           'buyPrice': transaction['buy_price'],
//                           'description': transaction['description'],
//                           'due': transaction['due'],
//                           'invoiceNo': transaction['invoice_id'],
//                           'paid': transaction['paid'],
//                           'refNo': transaction['ref_no'],
//                           'payList': payList,
//                           'images': images,
//                           'supplierId': transaction['supplierId']
//                         });
//                       }
//                     }
//                     print(supplierInvoices);
//                   } catch (error, trace) {
//                     print(error);
//                     print(trace);
//                   } finally {
//                     setState(() {
//                       isLoading = false;
//                     });
//                   }
//                 },
//               ),
//               ElevatedButton(
//                 child: const Text("Migrate Transactions"),
//                 onPressed: () async {
//                   setState(() {
//                     isLoading = true;
//                   });
//                   try {
//                     final response =
//                         await api.migrateTransactions(transactions);
//                     debugPrint(response.toString());
//                   } catch (error) {
//                     debugPrint(error.toString());
//                   } finally {
//                     setState(() {
//                       isLoading = false;
//                     });
//                   }
//                 },
//               ),
//               ElevatedButton(
//                 child: const Text("Migrate Supplier Invoices"),
//                 onPressed: () async {
//                   setState(() {
//                     isLoading = true;
//                   });
//                   try {
//                     final response =
//                     await api.migrateSupplierInvoices(supplierInvoices);
//                     debugPrint(response.toString());
//                   } catch (error) {
//                     debugPrint(error.toString());
//                   } finally {
//                     setState(() {
//                       isLoading = false;
//                     });
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
