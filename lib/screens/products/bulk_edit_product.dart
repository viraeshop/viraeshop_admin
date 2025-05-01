import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/products/bulk_edit_provider.dart';
import 'package:viraeshop_api/models/products/products.dart';
import 'package:viraeshop_bloc/products/products_bloc.dart';
import 'package:viraeshop_bloc/products/products_event.dart';
import 'package:viraeshop_bloc/products/products_state.dart';

enum PriceEditOperation { percent, percentMinus, plus, minus }

class BulkEditProduct extends StatefulWidget {
  const BulkEditProduct({
    super.key,
    required this.categoryId,
    required this.isSubCategory,
    required this.subCategoryId,
  });

  final String categoryId;
  final String subCategoryId;
  final bool isSubCategory;

  @override
  State<BulkEditProduct> createState() => _BulkEditProductState();
}

class _BulkEditProductState extends State<BulkEditProduct> {
  Widget selectedIcon = const Icon(FontAwesomeIcons.percent);
  Widget discountSelectedIcon = const Icon(FontAwesomeIcons.plus);
  PriceEditOperation operation = PriceEditOperation.percent;
  PriceEditOperation discountOperation = PriceEditOperation.plus;
  List icons = [
    {
      'icon': const Icon(FontAwesomeIcons.percent),
      'operation': PriceEditOperation.percent,
    },
    {
      'icon': const Row(
        children: [
          Icon(FontAwesomeIcons.percent),
          Icon(FontAwesomeIcons.minus),
        ],
      ),
      'operation': PriceEditOperation.percentMinus,
    },
    {
      'icon': const Icon(FontAwesomeIcons.plus),
      'operation': PriceEditOperation.plus,
    },
    {
      'icon': const Icon(FontAwesomeIcons.minus),
      'operation': PriceEditOperation.minus,
    }
  ];
  List discountIcons = [
    {
      'icon': const Icon(FontAwesomeIcons.plus),
      'operation': PriceEditOperation.plus,
    },
    {
      'icon': const Icon(FontAwesomeIcons.minus),
      'operation': PriceEditOperation.minus,
    }
  ];
  TextEditingController general = TextEditingController();
  TextEditingController agent = TextEditingController();
  TextEditingController architect = TextEditingController();
  TextEditingController generalDiscount = TextEditingController();
  TextEditingController agentDiscount = TextEditingController();
  TextEditingController architectDiscount = TextEditingController();
  TextEditingController cost = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    getCategoryProducts(
      context: context,
      categoryId: widget.categoryId,
      subCategoryId: widget.subCategoryId,
      isSubCategory: widget.isSubCategory,
    );
    super.initState();
  }

  @override
  dispose() {
    general.dispose();
    agent.dispose();
    architect.dispose();
    agentDiscount.dispose();
    agentDiscount.dispose();
    architectDiscount.dispose();
    cost.dispose();
    super.dispose();
  }

  List<ProductEntity> getProductEntities(List<Products> products) {
    List<ProductEntity> entities = [];
    for (var element in products) {
      entities.add(ProductEntity(
        productId: element.productId!,
        name: element.name,
        productCode: element.productCode,
        agentsDiscount: element.agentsDiscount ?? 0.0,
        architectDiscount: element.architectDiscount ?? 0.0,
        generalDiscount: element.generalDiscount ?? 0.0,
        agentsPrice: element.agentsPrice,
        architectPrice: element.architectPrice,
        generalPrice: element.generalPrice,
        cost: element.costPrice,
      ));
    }
    return entities;
  }

  bool isLoading = false;
  bool isProductsLoading = true;
  bool isProductsLoadingError = false;
  List<Map<String, dynamic>> editedProducts = [];
  final _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(
        color: kNewMainColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 2.0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Bulk Edit Products'),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          color: kBackgroundColor,
          child: BlocListener<ProductsBloc, ProductState>(
            listener: (context, state) {
              if (state is FetchedProductsState) {
                setState(() {
                  isProductsLoading = false;
                });
                context
                    .read<BulkEditProvider>()
                    .setProducts(getProductEntities(state.productList));
              } else if (state is RequestFinishedProductsState) {
                setState(() {
                  isLoading = false;
                });
                if (editedProducts.isNotEmpty) {
                  context
                      .read<BulkEditProvider>()
                      .updateProduct(editedProducts);
                }
                if (isLoading) {
                  snackBar(
                    text: state.response.message,
                    context: context,
                    duration: 400,
                  );
                }
              } else if (state is OnErrorProductsState) {
                if (isLoading) {
                  snackBar(
                      text: state.error,
                      context: context,
                      duration: 400,
                      color: kNewTextColor2);
                }
                setState(() {
                  if (isLoading) {
                    isLoading = false;
                  } else {
                    isProductsLoading = false;
                    isProductsLoadingError = true;
                  }
                });
              }
            },
            child: isProductsLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: kNewMainColor,
                    ),
                  )
                : isProductsLoadingError
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Failed to get products please try again',
                            style: kBigErrorTextStyle,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          IconButton(
                            onPressed: () {
                              getCategoryProducts(
                                context: context,
                                categoryId: widget.categoryId,
                                subCategoryId: widget.subCategoryId,
                                isSubCategory: widget.isSubCategory,
                              );
                              setState(() {
                                isProductsLoadingError = false;
                                isProductsLoading = true;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        //scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Form(
                              key: _key,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Edit Product Prices',
                                      style: kProductNameStylePro,
                                    ),
                                    PriceEditingWidget(
                                      icon: selectedIcon,
                                      icons: icons,
                                      general: general,
                                      agent: agent,
                                      architect: architect,
                                      // validator: (value) {
                                      //   if (value == null || value.isEmpty) {
                                      //     return 'Please enter val';
                                      //   }
                                      //   return null;
                                      // },
                                      onSelected: (value) {
                                        setState(() {
                                          selectedIcon = value['icon'];
                                          operation = value['operation'];
                                        });
                                      },
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      'Edit Product Discounts',
                                      style: kProductNameStylePro,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    PriceEditingWidget(
                                      icon: discountSelectedIcon,
                                      icons: discountIcons,
                                      general: generalDiscount,
                                      agent: agentDiscount,
                                      architect: architectDiscount,
                                      onSelected: (value) {
                                        setState(() {
                                          discountSelectedIcon = value['icon'];
                                          discountOperation =
                                              value['operation'];
                                        });
                                      },
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 250,
                                          child: ListTile(
                                            leading: const Text(
                                              'Cost',
                                              style: kProductNameStylePro,
                                            ),
                                            title: SizedBox(
                                              width: 100.0,
                                              height: 40.0,
                                              child: Center(
                                                child: TextFormField(
                                                  style: kTableCellStyle,
                                                  controller: cost,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: "Change cost",
                                                    hintStyle:
                                                        kProductNameStylePro,
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: kBlackColor,
                                                      ),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: kBlackColor,
                                                      ),
                                                    ),
                                                    focusColor: kBlackColor,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: kBlackColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            final bulk = context
                                                .read<BulkEditProvider>();
                                            if (bulk.bulkEdit.isNotEmpty) {
                                              //&& _key.currentState!.validate()
                                              print(bulk.bulkEdit);
                                              final token =
                                                  Hive.box('adminInfo')
                                                      .get('token');
                                              editedProducts = bulk.bulkEdit
                                                  .map((pr) => {
                                                        'id': pr.keys.first,
                                                        if (agentDiscount
                                                            .text.isNotEmpty)
                                                          "agentsDiscount":
                                                              handleMathOperation(
                                                            value: num.parse(
                                                                agentDiscount
                                                                    .text),
                                                            amount: pr[pr.keys
                                                                    .first][
                                                                'agentsDiscount'],
                                                            operation:
                                                                discountOperation,
                                                          ),
                                                        if (architectDiscount
                                                            .text.isNotEmpty)
                                                          "architectDiscount":
                                                              handleMathOperation(
                                                            value: num.parse(
                                                                architectDiscount
                                                                    .text),
                                                            amount: pr[pr.keys
                                                                    .first][
                                                                'architectDiscount'],
                                                            operation:
                                                                discountOperation,
                                                          ),
                                                        if (generalDiscount
                                                            .text.isNotEmpty)
                                                          "generalDiscount":
                                                              handleMathOperation(
                                                            value: num.parse(
                                                                generalDiscount
                                                                    .text),
                                                            amount: pr[pr.keys
                                                                    .first][
                                                                'generalDiscount'],
                                                            operation:
                                                                discountOperation,
                                                          ),
                                                        if (agent
                                                            .text.isNotEmpty)
                                                          "agentsPrice":
                                                              handleMathOperation(
                                                            value: num.parse(
                                                                agent.text),
                                                            amount: pr[pr
                                                                    .keys.first]
                                                                ['agentsPrice'],
                                                            operation:
                                                                operation,
                                                          ),
                                                        if (architect
                                                            .text.isNotEmpty)
                                                          "architectPrice":
                                                              handleMathOperation(
                                                            value: num.parse(
                                                                architect.text),
                                                            amount: pr[pr.keys
                                                                    .first][
                                                                'architectPrice'],
                                                            operation:
                                                                operation,
                                                          ),
                                                        if (general
                                                            .text.isNotEmpty)
                                                          "generalPrice":
                                                              handleMathOperation(
                                                            value: num.parse(
                                                                general.text),
                                                            amount: pr[pr.keys
                                                                    .first][
                                                                'generalPrice'],
                                                            operation:
                                                                operation,
                                                          ),
                                                        if (cost
                                                            .text.isNotEmpty)
                                                          'cost': num.parse(
                                                              cost.text),
                                                      })
                                                  .toList();
                                              if (kDebugMode) {
                                                print(editedProducts);
                                              }
                                              setState(() {
                                                isLoading = true;
                                              });
                                              BlocProvider.of<ProductsBloc>(
                                                      context)
                                                  .add(
                                                BulkUpdate(
                                                  data: {
                                                    'products': editedProducts,
                                                  },
                                                  token: token,
                                                ),
                                              );
                                            } else {
                                              snackBar(
                                                text:
                                                    'Please fill in the necessary information before updating',
                                                context: context,
                                                duration: 500,
                                                color: kNewTextColor2,
                                              );
                                            }
                                          },
                                          child: Container(
                                            width: 150,
                                            height: 50,
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: kNewMainColor,
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'Update',
                                                style: kDrawerTextStyle2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Consumer<BulkEditProvider>(
                                builder: (context, bulk, any) {
                              List<ProductEntity> products = bulk.products;
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columns: const [
                                            //DataColumn(label: Text("Select")),
                                            DataColumn(label: Text("ID")),
                                            DataColumn(label: Text("Code")),
                                            DataColumn(label: Text("Name")),
                                            DataColumn(
                                                label: Text("Agents Discount")),
                                            DataColumn(
                                                label:
                                                    Text("Architect Discount")),
                                            DataColumn(
                                                label:
                                                    Text("General Discount")),
                                            DataColumn(
                                                label: Text("Agents Price")),
                                            DataColumn(
                                                label: Text("Architect Price")),
                                            DataColumn(
                                                label: Text("General Price")),
                                            DataColumn(label: Text("Cost")),
                                          ],
                                          rows: products.map((product) {
                                            return DataRow(
                                              selected: product.isSelected,
                                              onSelectChanged:
                                                  (bool? selected) {
                                                bulk.selectProduct(
                                                    product.productId);
                                              },
                                              cells: [
                                                DataCell(
                                                  Text(
                                                    product.productId
                                                        .toString(),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(product.productCode),
                                                ),
                                                DataCell(
                                                  Text(product.name),
                                                ),
                                                DataCell(
                                                  Text(
                                                    product.agentsDiscount
                                                        .toString(),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    product.architectDiscount
                                                        .toString(),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    product.generalDiscount
                                                        .toString(),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    product.agentsPrice
                                                        .toString(),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    product.architectPrice
                                                        .toString(),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    product.generalPrice
                                                        .toString(),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    product.cost.toString(),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const Divider(
                              height: 1,
                              color: Colors.black12,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}

class ProductEntity {
  final String productId;
  final String name;
  final String productCode;
  num agentsDiscount;
  num architectDiscount;
  num generalDiscount;
  num agentsPrice;
  num architectPrice;
  num generalPrice;
  num cost;
  bool isSelected;

  ProductEntity({
    required this.productId,
    required this.name,
    required this.productCode,
    required this.agentsDiscount,
    required this.architectDiscount,
    required this.generalDiscount,
    required this.agentsPrice,
    required this.architectPrice,
    required this.generalPrice,
    required this.cost,
    this.isSelected = false,
  });
}

void getCategoryProducts({
  required BuildContext context,
  required String? categoryId,
  required bool isSubCategory,
  required String? subCategoryId,
}) {
  final blocInstance = BlocProvider.of<ProductsBloc>(context);
  blocInstance.add(GetProductsEvent(queryParameters: {
    'queryType': 'customer',
    'filterType': isSubCategory ? 'bySubCategory' : 'byCategory',
    if (!isSubCategory) 'categoryId': categoryId,
    if (isSubCategory) 'subCategoryId': subCategoryId,
    'page': 0,
  }));
}

class PriceEditingWidget extends StatelessWidget {
  const PriceEditingWidget({
    super.key,
    this.onSelected,
    this.validator,
    required this.icon,
    required this.icons,
    required this.general,
    required this.agent,
    required this.architect,
  });
  final List icons;
  final Widget icon;
  final TextEditingController general;
  final TextEditingController agent;
  final TextEditingController architect;
  final void Function(dynamic value)? onSelected;
  final String? Function(String? value)? validator;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        PopupMenuButton(
          icon: icon,
          itemBuilder: (context) {
            return icons
                .map(
                  (icon) => PopupMenuItem(
                    value: icon,
                    child: icon['icon'],
                  ),
                )
                .toList();
          },
          onSelected: onSelected,
        ),
        SizedBox(
          width: 100.0,
          height: 40.0,
          child: Center(
            child: TextFormField(
              style: kTableCellStyle,
              controller: general,
              validator: validator,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "General",
                hintStyle: kProductNameStylePro,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: kBlackColor,
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: kBlackColor,
                  ),
                ),
                focusColor: kBlackColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: kBlackColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 100.0,
          height: 40.0,
          child: Center(
            child: TextFormField(
              style: kTableCellStyle,
              controller: agent,
              keyboardType: TextInputType.number,
              validator: validator,
              decoration: const InputDecoration(
                hintText: "Agents",
                hintStyle: kProductNameStylePro,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: kBlackColor,
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: kBlackColor,
                  ),
                ),
                focusColor: kBlackColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: kBlackColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 100.0,
          height: 40.0,
          child: Center(
            child: TextFormField(
              style: kTableCellStyle,
              controller: architect,
              validator: validator,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Architect",
                hintStyle: kProductNameStylePro,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: kBlackColor,
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: kBlackColor,
                  ),
                ),
                focusColor: kBlackColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: kBlackColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

num handleMathOperation({
  required num value,
  required num amount,
  required PriceEditOperation operation,
}) {
  print('$operation: $amount');
  switch (operation) {
    case PriceEditOperation.percent:
      return (value * (amount / 100)) + amount;
    case PriceEditOperation.percentMinus:
      return amount - (value * (amount / 100));
    case PriceEditOperation.plus:
      return value + amount;
    case PriceEditOperation.minus:
      return amount - value;
    default:
      throw ArgumentError('Invalid operation');
  }
}
