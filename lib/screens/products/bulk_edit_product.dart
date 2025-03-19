import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_api/models/products/products.dart';
import 'package:viraeshop_bloc/products/products_bloc.dart';
import 'package:viraeshop_bloc/products/products_event.dart';
import 'package:viraeshop_bloc/products/products_state.dart';

class BulkEditProduct extends StatefulWidget {
  const BulkEditProduct({super.key, required this.categoryId});
  final String categoryId;
  @override
  State<BulkEditProduct> createState() => _BulkEditProductState();
}

class _BulkEditProductState extends State<BulkEditProduct> {
  List<ProductEntity> products = [];
  @override
  void initState() {
    // TODO: implement initState
    getCategoryProducts(context: context, categoryId: widget.categoryId);
    super.initState();
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
      ));
    }
    return entities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Bulk Edit Products'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<ProductsBloc, ProductState>(
          builder: (context, state) {
            if (state is FetchedProductsState) {
              products = getProductEntities(state.productList);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    DataTable(
                      columns: const [
                        DataColumn(label: Text("Select")),
                        DataColumn(label: Text("ID")),
                        DataColumn(label: Text("Name")),
                        DataColumn(label: Text("Code")),
                        DataColumn(label: Text("Agents Discount")),
                        DataColumn(label: Text("Architect Discount")),
                        DataColumn(label: Text("General Discount")),
                        DataColumn(label: Text("Agents Price")),
                        DataColumn(label: Text("Architect Price")),
                        DataColumn(label: Text("General Price")),
                      ],
                      rows: products.map((product) {
                        return DataRow(
                          selected: product.isSelected,
                          onSelectChanged: (bool? selected) {
                            setState(() {
                              product.isSelected = selected ?? false;
                            });
                          },
                          cells: [
                            DataCell(Checkbox(
                              value: product.isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  product.isSelected = value ?? false;
                                });
                              },
                            )),
                            DataCell(Text(product.productId.toString())),
                            DataCell(Text(product.name)),
                            DataCell(Text(product.productCode)),
                            DataCell(Text(product.agentsDiscount.toString())),
                            DataCell(
                                Text(product.architectDiscount.toString())),
                            DataCell(Text(product.generalDiscount.toString())),
                            DataCell(Text(product.agentsPrice.toString())),
                            DataCell(Text(product.architectPrice.toString())),
                            DataCell(Text(product.generalPrice.toString())),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            } else if (state is LoadingProductsState) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is OnErrorProductsState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.error,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  IconButton(
                    onPressed: () {
                      getCategoryProducts(
                        context: context,
                        categoryId: widget.categoryId,
                      );
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}

class ProductEntity {
  final String productId;
  final String name;
  final String productCode;
  final num agentsDiscount;
  final num architectDiscount;
  final num generalDiscount;
  final num agentsPrice;
  final num architectPrice;
  final num generalPrice;
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
    this.isSelected = false,
  });
}

void getCategoryProducts({
  required BuildContext context,
  required String? categoryId,
}) {
  final blocInstance = BlocProvider.of<ProductsBloc>(context);
  blocInstance.add(GetProductsEvent(queryParameters: {
    'queryType': 'customer',
    'filterType': 'byCategory',
    'categoryId': categoryId,
    'page': 0,
  }));
}
