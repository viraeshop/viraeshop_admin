import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_bloc/category/category_state.dart';
import 'package:viraeshop_bloc/suppliers/barrel.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/supplier/shops.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_api/models/suppliers/suppliers.dart';

class SupplierList extends StatefulWidget {
  const SupplierList({Key? key}) : super(key: key);

  @override
  _SupplierListState createState() => _SupplierListState();
}

class _SupplierListState extends State<SupplierList> {
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    final supplierBloc = BlocProvider.of<SuppliersBloc>(context);
    supplierBloc.add(GetSuppliersEvent(token: jWTToken));
    super.initState();
  }

  final jWTToken = Hive.box('adminInfo').get('token');
  bool isLoaded = false;
  bool loading = false;
  bool onDelete = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      progressIndicator: const CircularProgressIndicator(
        color: kNewMainColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: kSelectedTileColor),
          elevation: 0.0,
          backgroundColor: kBackgroundColor,
          title: const Text(
            'Suppliers',
            style: kAppBarTitleTextStyle,
          ),
          centerTitle: true,
          titleTextStyle: kTextStyle1,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Shops(),
                      ),
                    );
                  },
                  child: const Icon(Icons.add)),
            )
          ],
        ),
        body: BlocConsumer<SuppliersBloc, SupplierState>(
            listenWhen: (context, state) {
          if ((state is OnErrorSupplierState && isLoaded) ||
              (state is RequestFinishedSupplierState) ||
              (state is LoadingSupplierState && isLoaded)) {
            return true;
          } else {
            return false;
          }
        }, listener: (context, state) {
          if (state is LoadingSupplierState) {
            setState(() {
              loading = true;
            });
          } else if (state is RequestFinishedSupplierState) {
            setState(() {
              loading = false;
            });
            if (onDelete) {
              final supplierBloc = BlocProvider.of<SuppliersBloc>(context);
              supplierBloc.add(GetSuppliersEvent(token: jWTToken));
            } else {
              toast(
                context: context,
                title: 'Operation completed successfully',
              );
            }
          } else if (state is OnErrorCategoryState) {
            setState(() {
              loading = false;
            });
            snackBar(
              context: context,
              text: 'Operation completed successfully',
              color: kRedColor,
              duration: 600,
            );
          }
        }, buildWhen: (context, state) {
          if (state is FetchedSuppliersState ||
              (state is OnErrorSupplierState && !isLoaded)) {
            return true;
          } else {
            return false;
          }
        }, builder: (context, state) {
          if (state is FetchedSuppliersState) {
            List<Suppliers> suppliers = state.supplierList;
            List supplierList = [];
            for (var element in suppliers) {
              supplierList.add(element.toJson());
            }
            if (kDebugMode) {
              print(supplierList);
            }
            isLoaded = true;
            if(loading){
              SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                setState(() {
                  loading = false;
                });
              });
            }
            //print(isLoaded);
            return ListView.builder(
              itemCount: suppliers.length,
              itemBuilder: (BuildContext context, int i) {
                return Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    color: kBackgroundColor,
                    border: Border(
                      bottom: BorderSide(color: kStrokeColor),
                    ),
                  ),
                  padding: const EdgeInsets.all(15.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: kCategoryBackgroundColor,
                              backgroundImage: CachedNetworkImageProvider(
                                  '${supplierList[i]['profileImage']}'),
                              radius: 50.0,
                            ),
                            const SizedBox(
                              width: 5.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${supplierList[i]['businessName']}',
                                  style: kProductNameStyle,
                                  overflow: TextOverflow.fade,
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                Text(
                                  '${supplierList[i]['supplierName']}',
                                  style: kProductNameStyle,
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    ///TODO: Add edit supplier here
                                    builder: (context) => Shops(
                                      isUpdate: true,
                                      data: supplierList[i],
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                              color: kSubMainColor,
                              iconSize: 20.0,
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog<void>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Delete Supplier'),
                                      content: const Text(
                                        'Are you sure you want to remove this Supplier?',
                                        softWrap: true,
                                        style: kSourceSansStyle,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              onDelete = true;
                                            });
                                            final supplierBloc =
                                                BlocProvider.of<SuppliersBloc>(
                                                    context);
                                            supplierBloc.add(
                                              DeleteSupplierEvent(
                                                token: jWTToken,
                                                supplierId: supplierList[i]
                                                        ['supplierId']
                                                    .toString(),
                                              ),
                                            );
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'Yes',
                                            softWrap: true,
                                            style: kSourceSansStyle,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'No',
                                            softWrap: true,
                                            style: kSourceSansStyle,
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.delete),
                              color: kSubMainColor,
                              iconSize: 20.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is OnErrorSupplierState) {
            return Center(
              child: Text(
                state.message,
                style: kProductNameStylePro,
              ),
            );
          } else {
            if (isLoaded) {
              return const SizedBox();
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  //color: kNewMainColor,
                ),
              );
            }
          }
        }),
      ),
    );
  }
}
