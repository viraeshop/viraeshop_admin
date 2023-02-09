import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop/adverts/adverts_bloc.dart';
import 'package:viraeshop/adverts/adverts_event.dart';
import 'package:viraeshop/products/barrel.dart';
import 'package:viraeshop/products/products_bloc.dart';
import 'package:viraeshop/suppliers/barrel.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/baxes.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/product_price.dart';
import 'package:viraeshop_admin/reusable_widgets/desktop_product_cards2.dart';
import 'package:viraeshop_admin/reusable_widgets/form_field.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/general_provider.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';
import 'package:random_string/random_string.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';

import '../configs/image_picker.dart';
import 'advert/ads_provider.dart';
import 'home_screen.dart';
import 'image_carousel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewProduct extends StatefulWidget {
  static String path = 'newProductPath';
  final bool isUpdateProduct;
  final Map<String, dynamic> info;
  final String routeName;
  const NewProduct({
    this.isUpdateProduct = false,
    required this.info,
    this.routeName = '',
    Key? key,
  }) : super(key: key);

  @override
  _NewProductState createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  List images = Hive.box('images').get('imagesBytes', defaultValue: []) ?? [];
  List productImage =
      Hive.box('images').get('productImages', defaultValue: []) ?? [];
  AdminCrud adminCrud = AdminCrud();
  GeneralCrud generalCrud = GeneralCrud();
  final String _uniqueCode = randomAlphaNumeric(10);
  bool showFields = true;
  bool loading = false;
  var currdate = DateTime.now();
  late TabController _tabController;
  var selected_pruser = '';
  String selectedSellby = 'Unit';
  bool isGeneralDiscount = false;
  bool isAgentDiscount = false;
  bool isArchitectDiscount = false;
  bool isGeneral = true;
  bool isAgent = true;
  bool isArchitect = true;
  bool isInfinity = false;
  var selected_category = '';
  final List _pr_user_List = ['general', 'agents', 'architect'];
  final List _category_List = [];
  final List<String> _sell_by = [
    'Unit',
    'Sft',
    'Rft',
    'Kilo',
    'Kg',
    'CM',
    'Pisce'
  ];
  TextEditingController descController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _productCodeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _minimumController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _adsController = TextEditingController();
  final TextEditingController _generalController = TextEditingController();
  final TextEditingController _agentController = TextEditingController();
  final TextEditingController _architectController = TextEditingController();
  final TextEditingController _generalDiscountCont = TextEditingController();
  final TextEditingController _architectDiscountCont = TextEditingController();
  final TextEditingController _agentsDiscountCont = TextEditingController();
  final List<Widget> _tabs = const <Tab>[
    Tab(
      text: 'Product',
    ),
    Tab(
      text: 'Stock',
    ),
  ];
  List adverts = [];
  List existingAdverts = [];
  List deletedAdverts = [];
  Map<String, dynamic> fields = {};
  bool onDelete = false;
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: 2, vsync: this);
    if (widget.isUpdateProduct == true) {
      descController.text = widget.info['description'];
      _nameController.text = widget.info['name'];
      _generalController.text = widget.info['generalPrice'].toString();
      _agentController.text = widget.info['agentsPrice'].toString();
      _architectController.text = widget.info['architectPrice'].toString();
      _generalDiscountCont.text = widget.info['generalDiscount'].toString();
      _agentsDiscountCont.text = widget.info['agentsDiscount'].toString();
      _productCodeController.text = widget.info['productCode'];
      _architectDiscountCont.text = widget.info['architectDiscount'].toString();
      _costController.text = widget.info['costPrice'].toString();
      _quantityController.text = widget.info['quantity'].toString();
      widget.info['minimum'] != null
          ? _minimumController.text = widget.info['minimum'].toString()
          : '0';
      isGeneralDiscount = widget.info['isGeneralDiscount'];
      isAgentDiscount = widget.info['isAgentDiscount'];
      isArchitectDiscount = widget.info['isArchitectDiscount'];
      selectedSellby = widget.info['sellBy'];
      isInfinity = widget.info['isInfinity'];
      List productPics = widget.info['images'] ?? [];
      Hive.box('images').put('productImages', productPics.map((e) => e['imageLink']).toList());
      Hive.box('suppliers').putAll(widget.info['supplier']);
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        Provider.of<GeneralProvider>(context, listen: false)
            .updateAdList(widget.info['adverts'] ?? []);
        Provider.of<GeneralProvider>(context, listen: false)
        .updateExistingAdverts(widget.info['adverts'] ?? []);
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  DecorationImage _imageBG() {
    return images == null || images.isEmpty
        ? const DecorationImage(
            image: AssetImage('assets/default.jpg'), fit: BoxFit.cover)
        : DecorationImage(image: MemoryImage(images[0]), fit: BoxFit.cover);
  }

  Widget imageProduct(List urls) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageCarousel(
            isUpdate: true,
            images: urls,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: CachedNetworkImage(
          height: 150.0,
          width: 150.0,
          fit: BoxFit.cover,
          imageUrl: urls.isNotEmpty ? urls[0] : '',
          errorWidget: (context, url, childs) {
            return Image.asset(
              'assets/default.jpg',
              height: 100.0,
              width: 100.0,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productBloc = BlocProvider.of<ProductsBloc>(context);
    return BlocListener<ProductsBloc, ProductState>(
      listener: (context, state) {
        if (state is OnErrorProductsState) {
          setState(() {
            loading = false;
            showFields = true;
          });
          snackBar(
            text: state.error,
            context: context,
            color: kRedColor,
            duration: 600,
          );
        } else if (state is RequestFinishedProductsState) {
          setState(() {
            loading = false;
            showFields = true;
          });
          List products = Hive.box(productsBox).get(productsKey);
          Map supplier = Hive.box('suppliers').toMap();
          if (widget.isUpdateProduct) {
            List deletedImages =
                Hive.box('images').get('deletedImages') ?? [];
            List img = widget.info['images'] ?? [];
            if(deletedImages.isNotEmpty && img.isNotEmpty){
              for(var image in deletedImages){
                img.removeWhere((element) => element['imageLink'] == image);
              }
            }
            for (int i = 0; i < products.length; i++) {
              if (widget.info['productId'] == products[i]['productId']) {
                Map supplier = Hive.box('suppliers').toMap();
                fields['productId'] = widget.info['productId'];
                fields['supplier'] = supplier;
                fields['adverts'] = adverts;
                fields['images'] += img;
                products[i] = fields;
              }
            }
            Provider.of<GeneralProvider>(context, listen: false)
                .clearLists();
            ///todo: check here
          } else if (onDelete) {
            for (int i = 0; i < products.length; i++) {
              if (widget.info['productId'] == products[i]['productId']) {
                products.removeAt(i);
              }
            }
          } else {
            fields['supplier'] = supplier;
            fields['productId'] = state.response.result!['productId'];
            products.add(fields);
          }
          Provider.of<AdsProvider>(context, listen: false).updateProductList(products);
          Hive.box(productsBox).put(productsKey, products);
          Hive.box('images').clear();
          Hive.box('category').clear();
          Navigator.pushNamedAndRemoveUntil(
              context, HomeScreen.path, (route) => false);
          toast(context: context, title: 'Operation completed successfully');
        }
      },
      child: ModalProgressHUD(
        inAsyncCall: loading,
        progressIndicator: const CircularProgressIndicator(
          color: kMainColor,
        ),
        child: SafeArea(
          child: DefaultTabController(
            length: _tabs.length,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: true,
                iconTheme: const IconThemeData(color: kSelectedTileColor),
                elevation: 0.0,
                backgroundColor: kBackgroundColor,
                title: Text(
                  widget.isUpdateProduct == true
                      ? widget.info['name']
                      : 'New Product',
                  style: kAppBarTitleTextStyle,
                ),
                centerTitle: false,
                titleTextStyle: kAppBarTitleTextStyle,
                actions: [
                  widget.isUpdateProduct == true
                      ? IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: const Text('Delete Product'),
                                  content: const Text(
                                    'Are you sure you want to remove this Product?',
                                    softWrap: true,
                                    style: kSourceSansStyle,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        setState(() {
                                          loading = true;
                                          onDelete = true;
                                        });
                                        Navigator.pop(dialogContext);
                                        List productImageUrls =
                                            Hive.box('images').get(
                                                'productImages',
                                                defaultValue: []);
                                        try {
                                          String deleteOperationResponse =
                                              await NetworkUtility
                                                  .deleteProductImages(
                                                      productImageUrls
                                                              .isNotEmpty
                                                          ? productImageUrls
                                                          : widget
                                                              .info['image'])!;
                                          if (deleteOperationResponse ==
                                              'No image') {
                                            snackBar(
                                              text: 'No image found',
                                              context: context,
                                              duration: 40,
                                              color: kRedColor,
                                            );
                                          }

                                          ///Todo: Delete Product here...
                                          productBloc.add(DeleteProductEvent(
                                              token: jWTToken,
                                              productId:
                                                  widget.info['productId']));
                                        } on FirebaseException catch (e) {
                                          if (kDebugMode) {
                                            print(e.message);
                                          }
                                        } finally {
                                          setState(() {
                                            loading = false;
                                          });
                                        }
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
                          icon: const Icon(
                            Icons.delete,
                          ),
                          color: kSubMainColor,
                          iconSize: 20.0,
                        )
                      : const SizedBox(),
                ],
                bottom: TabBar(
                  tabs: _tabs,
                  indicatorColor: kMainColor,
                  labelColor: kTextColor1,
                ),
              ),
              body: ChangeNotifierProvider(
                create: (context) => Configs(),
                child: TabBarView(
                  children: [addProduct(), stockPage()],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Products and stock
  addProduct() {
    bool isProducts = Hive.box('adminInfo').get('isProducts');
    return Stack(
      children: [
        Visibility(
            visible: showFields,
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder(
                        valueListenable: Hive.box('images').listenable(),
                        builder: (context, Box box, childs) {
                          List imagesByte =
                              box.get('imagesBytes', defaultValue: []);
                          List imagesPath =
                              box.get('imagesPath', defaultValue: []);
                          if (widget.isUpdateProduct == true &&
                              imagesByte.isEmpty) {
                            List images = box.get('productImages');
                            return imageProduct(images ?? []);
                          } else {
                            return SizedBox(
                              height: 100,
                              width: 120,
                              child: GestureDetector(
                                onTap: isProducts == false
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ImageCarousel(),
                                          ),
                                        );
                                      },
                                child: Container(
                                  height: 100.0,
                                  width: 100.0,
                                  decoration: BoxDecoration(
                                    color: kProductCardColor,
                                    image: imageBG(
                                      imagesByte.isEmpty
                                          ? Uint8List(0)
                                          : imagesByte[0],
                                      imagesPath.isEmpty ? '' : imagesPath[0],
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                          color: kSubMainColor,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: const [
                                              Text('Upload Image',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: kBackgroundColor,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                '+',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: kBackgroundColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                ),
                              ),
                            );
                          }
                        }),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 0,
                  child: Column(
                    children: [
                      textFieldWidget(
                        controller: _nameController,
                        labelText: 'Product Name',
                      ),
                      textFieldWidget(
                        controller: _productCodeController,
                        labelText: 'Product code',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  margin: const EdgeInsets.symmetric(vertical: 20.0),
                  color: kBackgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prices',
                        style: kProductNameStyle,
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      ProductPrice(
                        title: 'General Price',
                        isSelected: isGeneral,
                        controller: _generalController,
                        onChanged: (value) {
                          setState(() {
                            isGeneral = value!;
                          });
                        },
                      ),
                      ProductPrice(
                        title: 'Agent Price',
                        isSelected: isAgent,
                        controller: _agentController,
                        onChanged: (value) {
                          setState(() {
                            isAgent = value!;
                          });
                        },
                      ),
                      ProductPrice(
                        title: 'Architect Price',
                        isSelected: isArchitect,
                        controller: _architectController,
                        onChanged: (value) {
                          isArchitect = value!;
                        },
                      ),
                      const Text(
                        'Discounts',
                        style: kTotalSalesStyle,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      ProductPrice(
                        title: 'General Discount',
                        isSelected: isGeneralDiscount,
                        controller: _generalDiscountCont,
                        onChanged: (value) {
                          setState(() {
                            isGeneralDiscount = value!;
                          });
                        },
                      ),
                      ProductPrice(
                        title: 'Agent Discount',
                        isSelected: isAgentDiscount,
                        controller: _agentsDiscountCont,
                        onChanged: (value) {
                          setState(() {
                            isAgentDiscount = value!;
                          });
                        },
                      ),
                      ProductPrice(
                        title: 'Architect Discount',
                        isSelected: isArchitectDiscount,
                        controller: _architectDiscountCont,
                        onChanged: (value) {
                          setState(() {
                            isArchitectDiscount = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // shrinkWrap: true,
                        children: [
                          const ListTile(
                            title: Text(
                              'Details',
                              style: kProductNameStyle,
                            ),
                            // trailing: Icon(Icons.arrow_drop_up),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // Category
                          ValueListenableBuilder(
                              valueListenable:
                                  Hive.box('category').listenable(),
                              builder: (context, Box box, childs) {
                                String category = box.get('name',
                                    defaultValue: widget.isUpdateProduct
                                        ? widget.info['category']
                                        : 'Category');
                                _categoryController.text = category;
                                return TextFormField(
                                  readOnly: true,
                                  controller: _categoryController,
                                  style: kTableCellStyle,
                                  onTap: isProducts == false
                                      ? null
                                      : () {
                                          getCategoryDialog(
                                              buildContext: context);
                                        },
                                  decoration: const InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: kBlackColor,
                                      ),
                                    ),
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: kBlackColor,
                                      ),
                                    ),
                                    focusColor: kBlackColor,
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: kBlackColor,
                                      ),
                                    ),
                                  ),
                                  onChanged: (dynamic value) {},
                                );
                              }),
                          const SizedBox(
                            height: 20,
                          ),
                          Consumer<GeneralProvider>(
                              builder: (context, provider, childs) {
                            List advert =
                                Set.from(provider.advertSelected).toList();
                            print('Already advert: $advert');
                            adverts = advert;
                            existingAdverts = provider.existingAdverts;
                            deletedAdverts = provider.deletedAdverts;
                            _adsController.clear();
                            for (var element in adverts) {
                              _adsController.text += '$element, ';
                            }
                            return TextFormField(
                              readOnly: true,
                              controller: _adsController,
                              style: kTableCellStyle,
                              onTap: isProducts == false
                                  ? null
                                  : () {
                                      final advertBloc =
                                          BlocProvider.of<AdvertsBloc>(context);
                                      advertBloc.add(GetAdvertsEvent());
                                      getAdvertsDialog(buildContext: context, isUpdate: widget.isUpdateProduct,
                                      );
                                    },
                              decoration: const InputDecoration(
                                hintText: 'Adverts',
                                hintStyle: kProductNameStylePro,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: kBlackColor,
                                  ),
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: kBlackColor,
                                  ),
                                ),
                                focusColor: kBlackColor,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: kBlackColor,
                                  ),
                                ),
                              ),
                              onChanged: (dynamic value) {},
                            );
                          }),
                          const SizedBox(
                            height: 20,
                          ),
                          TextField(
                            style: kTableCellStyle,
                            controller: _costController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: "Cost",
                                labelStyle: kProductNameStylePro,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: kBlackColor),
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: kBlackColor),
                                ),
                                focusColor: kBlackColor,
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: kBlackColor))

                                // border: OutlineInputBorder(
                                //     borderRadius: BorderRadius.circular(15))
                                ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextField(
                            style: kTableCellStyle,
                            controller: descController,
                            maxLines: 2,
                            keyboardType: isProducts == true
                                ? TextInputType.text
                                : TextInputType.none,
                            decoration: const InputDecoration(
                              labelText: "Description",
                              labelStyle: kProductNameStylePro,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: kBlackColor),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: kBlackColor),
                              ),
                              focusColor: kBlackColor,
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: kBlackColor)),

                              // border: OutlineInputBorder(
                              //     borderRadius: BorderRadius.circular(15))
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ValueListenableBuilder(
                              valueListenable: Hive.box('suppliers').listenable(),
                              builder: (context, Box box, childs) {
                                String shopName = box.get('businessName',
                                    defaultValue: 'Suppliers');
                                return InkWell(
                                  onTap: () {
                                    final supplierBloc =
                                        BlocProvider.of<SuppliersBloc>(context);
                                    supplierBloc.add(
                                        GetSuppliersEvent(token: jWTToken ?? ''));
                                    getNonInventoryDialog(
                                        buildContext: context,
                                        box: 'suppliers',
                                    );
                                  },
                                  child: Container(
                                    height: 45,
                                    width: double.infinity,
                                    //padding: const EdgeInsets.all(10.0),
                                    decoration: const BoxDecoration(
                                        color: kBackgroundColor,
                                        //borderRadius: BorderRadius.circular(10.0),
                                        border: Border(
                                            bottom: BorderSide(
                                          color: kSubMainColor,
                                        ))),
                                    child: Text(
                                      shopName,
                                      style: kTotalTextStyle,
                                    ),
                                  ),
                                );
                              }),
                          DropdownButtonFormField(
                            value: selectedSellby,
                            decoration: const InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: kBlackColor),
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: kBlackColor),
                                ),
                                focusColor: kBlackColor,
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: kBlackColor)),
                                hintStyle: TextStyle(color: Colors.black87)),
                            hint: const Text(
                                'Sell By'), // Not necessary for Option 1
                            // value: default_pruser,
                            onChanged: isProducts == false
                                ? null
                                : (String? changedValue) {
                                    setState(() {
                                      selectedSellby = changedValue!;
                                    });
                                  },
                            items: _sell_by.map((itm) {
                              return DropdownMenuItem(
                                value: itm,
                                child: Text(itm),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    )),
                const SizedBox(
                  height: 20,
                ),
              ],
            )),
      ],
    );
  }

  Widget textFieldWidget(
      {required TextEditingController controller,
      void Function(String?)? onChanged,
      labelText}) {
    bool isProducts = Hive.box('adminInfo').get('isProducts');
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: TextField(
        style: kTableCellStyle,
        controller: controller,
        onChanged: onChanged,
        keyboardType:
            isProducts == true ? TextInputType.text : TextInputType.none,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: kTableCellStyle,
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: kBlackColor,
            ),
          ),
          border: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: kBlackColor,
            ),
          ),
          focusColor: kBlackColor,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: kBlackColor,
            ),
          ),
        ),
      ),
    );
  }

  stockPage() {
    bool isInventory = Hive.box('adminInfo').get('isInventory');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        SwitchListTile(
          activeColor: kNewMainColor,
          tileColor: kBackgroundColor,
          title: const Text(
            'Infinity Stock',
            style: kTableCellStyle,
          ),
          value: isInfinity,
          onChanged: (value) {
            setState(() {
              isInfinity = value;
            });
          },
        ),
        const Expanded(
          flex: 1,
          child: Text('-'),
        ),
        Expanded(
          flex: 1,
          child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  // shrinkWrap: true,
                  children: [
                    const Text(
                      'On hand',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                    TextField(
                      enabled: !isInfinity,
                      style: TextStyle(
                        color: isInfinity == false
                            ? kBlackColor
                            : Colors.grey[200],
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: _quantityController,
                      keyboardType: widget.isUpdateProduct == true
                          ? isInventory == true
                              ? TextInputType.number
                              : TextInputType.none
                          : TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Quantity",
                        // labelStyle: TextStyle(fontSize: 40),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isInfinity == false
                                ? kBlackColor
                                : Colors.grey[200]!,
                          ),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isInfinity == false
                                ? kBlackColor
                                : Colors.grey[200]!,
                          ),
                        ),
                        focusColor: kBlackColor,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isInfinity == false
                                ? kBlackColor
                                : Colors.grey[200]!,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    TextField(
                      enabled: !isInfinity,
                      style: TextStyle(
                        color: isInfinity == false
                            ? kBlackColor
                            : Colors.grey[200],
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: _minimumController,
                      keyboardType: widget.isUpdateProduct == true
                          ? isInventory == true
                              ? TextInputType.number
                              : TextInputType.none
                          : TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Minimum",
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isInfinity == false
                                ? kBlackColor
                                : Colors.grey[200]!,
                          ),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isInfinity == false
                                ? kBlackColor
                                : Colors.grey[200]!,
                          ),
                        ),
                        focusColor: kBlackColor,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isInfinity == false
                                ? kBlackColor
                                : Colors.grey[200]!,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    bottomCard(
                      context: context,
                      onTap: () async {
                        setState(() {
                          loading = true;
                          showFields = false;
                        });
                        final productBloc =
                            BlocProvider.of<ProductsBloc>(context);
                        bool isNotEmpty() {
                          if (_nameController.text != null &&
                              _categoryController.text != null &&
                              _generalController.text != null &&
                              _agentController.text != null &&
                              _architectController.text != null &&
                              _costController.text != null &&
                              _productCodeController.text != null &&
                              _quantityController.text != null) {
                            return true;
                          } else {
                            return false;
                          }
                        }

                        if (isNotEmpty()) {
                          List imagesList =
                              Hive.box('images').get('productImages') ?? [];
                          if (imagesList.isNotEmpty) {
                            List newList = [];
                            for (var image in imagesList) {
                              newList.add({
                               if(widget.isUpdateProduct) 'productId': widget.info['productId'],
                                'imageLink': image
                              });
                            }
                            imagesList = newList;
                          }
                          List deletedImages =
                              Hive.box('images').get('deletedImages') ?? [];
                          if (deletedImages.isNotEmpty) {
                            List newList = [];
                            for (var image in deletedImages) {
                              newList.add({
                                'productId': num.parse(widget.info['productId']),
                                'imageLink': image
                              });
                            }
                            deletedImages = newList;
                          }
                          List updatedAdverts = adverts.toList();
                          if (kDebugMode) {
                            print('AdvertsBeforeFilter: $adverts');
                          }
                          if (kDebugMode) {
                            print('UpdatedAdvertsBeforeFilter: $updatedAdverts');
                          }
                          if (widget.isUpdateProduct && existingAdverts.isNotEmpty) {
                            for (var advert in existingAdverts) {
                              if (updatedAdverts.contains(advert)) {
                                updatedAdverts.remove(advert);
                              }
                            }
                          }
                          if (updatedAdverts.isNotEmpty) {
                            List newList = [];
                            for (var advert in updatedAdverts) {
                              if (kDebugMode) {
                                print(advert);
                              }
                              newList.add({
                                'advert': advert,
                                if(widget.isUpdateProduct) 'productId': widget.info['productId'],
                              });
                            }
                            updatedAdverts = newList;
                          }
                          if (kDebugMode) {
                            print('AdvertsAfterFilter: $adverts');
                          }
                          if (kDebugMode) {
                            print('UpdatedAdvertsAfterFilter: $updatedAdverts');
                          }
                          Map supplier = Hive.box('suppliers').toMap();
                          setState(() {
                            fields = {
                              'supplierId': supplier['supplierId'],
                              'category': _categoryController.text,
                              'categoryId':
                                  Hive.box('category').get('categoryId'),
                              'sellBy': selectedSellby,
                              'minimum': isInfinity
                                  ? 0
                                  : num.tryParse(_minimumController.text),
                              'name': _nameController.text,
                              'quantity': isInfinity
                                  ? 0
                                  : num.parse(_quantityController.text),
                              'costPrice': _costController.text,
                              'generalPrice': isGeneral
                                  ? num.parse(_generalController.text)
                                  : 0,
                              'agentsPrice': isAgent
                                  ? num.parse(_agentController.text)
                                  : 0,
                              'architectPrice': isArchitect
                                  ? num.parse(_architectController.text)
                                  : 0,
                              'description': descController.text,
                              'productCode': _productCodeController.text,
                              'images': imagesList,
                              'generalDiscount': isGeneralDiscount
                                  ? num.tryParse(_generalDiscountCont.text)
                                  : 0,
                              'agentsDiscount': isAgentDiscount
                                  ? num.tryParse(_agentsDiscountCont.text)
                                  : 0,
                              'architectDiscount': isArchitectDiscount
                                  ? num.tryParse(_architectDiscountCont.text)
                                  : 0,
                              'isGeneralDiscount': isGeneralDiscount,
                              'isAgentDiscount': isAgentDiscount,
                              'isArchitectDiscount': isArchitectDiscount,
                              'isInfinity': isInfinity,
                              'adverts': updatedAdverts,
                              if (widget.isUpdateProduct)
                                'deletedAdverts': deletedAdverts,
                              if (widget.isUpdateProduct)
                                'deletedImages': deletedImages,
                            };
                          });
                          if (widget.isUpdateProduct) {
                            productBloc.add(
                              UpdateProductEvent(
                                  token: jWTToken ?? '',
                                  productId: widget.info['productId'],
                                  productModel: fields,
                              ),
                            );
                          } else {
                            productBloc.add(
                              AddProductEvent(
                                token: jWTToken ?? '',
                                productModel: fields,
                              ),
                            );
                          }
                        } else {
                          setState(() {
                            loading = false;
                            showFields = true;
                          });
                          showDialogBox(
                            buildContext: context,
                            msg: 'Fields can\'t be empty!',
                          );
                        }
                      },
                      text: widget.isUpdateProduct ? 'Update' : 'Add products',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

// DESKTOP BODY
  desktopBody() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(40.0),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                DesktopProductCard2(
                  costController: _costController,
                  nameController: _nameController,
                  priceController: _priceController,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  // margin: EdgeInsets.all(10.0),
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 15.0, top: 15.0),
                        child: Text(
                          'Stocks',
                          style: kCategoryNameStyle,
                        ),
                      ),
                      const SizedBox(
                        width: double.infinity,
                        child: Divider(
                          color: kScaffoldBackgroundColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          children: [
                            HeadingTextField(
                              onMaxLine: false,
                              controller: _quantityController,
                              heading: 'Quantity: ',
                            ),
                            HeadingTextField(
                              onMaxLine: false,
                              controller: _minimumController,
                              heading: 'Minimum: ',
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Category: ',
                                  style: kProductPriceStylePro,
                                ),
                                Center(
                                  child: Container(
                                    height: 46.0,
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    margin: const EdgeInsets.all(10.0),
                                    child: ValueListenableBuilder(
                                        valueListenable:
                                            Hive.box('category').listenable(),
                                        builder: (context, Box box, childs) {
                                          String category = box.get('name',
                                              defaultValue: 'Category');
                                          _categoryController.text = category;
                                          return TextFormField(
                                            readOnly: true,
                                            controller: _categoryController,
                                            style: kCategoryNameStyle,
                                            onTap: () {
                                              getCategoryDialog(
                                                  buildContext: context);
                                            },
                                            decoration: const InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: kMainColor),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: kMainColor),
                                              ),
                                              focusColor: kMainColor,
                                            ),
                                            onChanged: (dynamic value) {
                                              Provider.of<Configs>(context)
                                                  .updateCategory(value);
                                            },
                                          );
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 30.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                imagePickerContainer(context),
                const SizedBox(height: 10.0),
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width * 0.25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: kBackgroundColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 15.0, left: 15.0),
                        child: Text(
                          'Description',
                          style: kCategoryNameStyle,
                        ),
                      ),
                      const SizedBox(
                        width: double.infinity,
                        child: Divider(
                          color: kScaffoldBackgroundColor,
                        ),
                      ),
                      // SizedBox(
                      //   height: 10.0,
                      // ),
                      Container(
                        margin: const EdgeInsets.all(10.0),
                        decoration: const BoxDecoration(
                            // border: Border.all(
                            //   color: kScaffoldBackgroundColor,
                            // ),
                            ),
                        height: MediaQuery.of(context).size.height * 0.20,
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Center(
                          child: TextFormField(
                            controller: descController,
                            cursorColor: kMainColor,
                            style: kProductNameStylePro,
                            textInputAction: TextInputAction.done,
                            maxLines: 10,
                            decoration: const InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: kMainColor),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: kMainColor),
                              ),
                              focusColor: kMainColor,
                            ),
                            // onFieldSubmitted: (value) {
                            //   setState(() => {isEditable = false, title = value});
                            // }
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Consumer<Configs>(
                      builder: (context, configs, childs) => InkWell(
                        child: Container(
                          // padding: EdgeInsets.all(15),
                          // margin: EdgeInsets.all(15.0),
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: 30.0,
                          decoration: BoxDecoration(
                              color:
                                  kMainColor, //Theme.of(context).accentColor,
                              borderRadius: BorderRadius.circular(5)),
                          child: const Center(
                            child: Text(
                              "Save",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                        onTap: () {
                          bool isNotEmpty() {
                            if (configs.sellBy != null &&
                                _nameController.text != null &&
                                _categoryController != null &&
                                _priceController.text != null &&
                                descController.text != null &&
                                _costController.text != null &&
                                _quantityController.text != null &&
                                configs.productFor != null &&
                                _minimumController != null) {
                              return true;
                            } else {
                              return false;
                            }
                          }

                          bool isClear = true;
                          print('bool: $isClear');
                          final progress = ProgressHUD.of(context);
                          if (isNotEmpty()) {
                            if (productImage != null) {
                              progress!.show();
                              Map<String, dynamic> fields = {
                                'name': _nameController.text,
                                'description': descController.text,
                                'category': _categoryController,
                                'selling_price': _priceController.text,
                                'costPrice': _costController.text,
                                'quantity': _quantityController.text,
                                'sellBy': configs.sellBy,
                                'minimum': _minimumController.text,
                                'product_for': configs.productFor,
                                'image': productImage,
                              };
                              adminCrud
                                  .addProduct(fields, _nameController.text)
                                  .then((added) {
                                if (added) {
                                  progress.dismiss();
                                  showDialogBox(
                                    buildContext: context,
                                    msg: 'Product Created',
                                  );
                                } else {
                                  progress.dismiss();
                                  showDialogBox(
                                    buildContext: context,
                                    msg: 'An error occured please try again',
                                  );
                                }
                              });
                            } else {
                              progress!.dismiss();
                              showDialogBox(
                                buildContext: context,
                                msg: 'Sorry Product Image is Missing',
                              );
                            }
                            // ignore: dead_code
                          } else {
                            progress!.dismiss();
                            showDialogBox(
                              buildContext: context,
                              msg: 'Fields can\'t be empty!',
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container imagePickerContainer(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: kBackgroundColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 15.0),
                    child: Text(
                      'Pick Product Image',
                      style: kCategoryNameStyle,
                    ),
                  ),
                  const SizedBox(
                    width: double.infinity,
                    child: Divider(
                      color: kScaffoldBackgroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.all(10.0),
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: _imageBG(),
                borderRadius: BorderRadius.circular(3.0),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: () {
                if (kIsWeb) {
                  getImageWeb();
                } else {
                  selectImage();
                }
              },
              child: const Icon(Icons.add_a_photo, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Future selectImage() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 50,
          maxHeight: 480,
          maxWidth: 640);
      if (image != null) {
        var fullImage = 'images/product_$_uniqueCode.jpg';
        adminCrud
            .uploadImage(filePath: File(image.path), imageName: fullImage)
            .then((imageUrl) {
          setState(() {
            this._imageFile = File(image.path);
            productImage = imageUrl;
          });
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void getImageWeb() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Uint8List imageBytes = result.files.first.bytes ?? Uint8List(0);
      List<PlatformFile> filePath = result.files.toList();
      setState(() {
        loading = true;
      });
      filePath.forEach((fileName) async {
        await adminCrud
            .uploadWebImage(imageBytes, fileName.path!, '')
            .then((imageUrl) {
          setState(() {
            images.add(result.files.first.bytes);
            productImage.add(imageUrl);
            loading = false;
          });
        }).catchError((error) {
          setState(() {
            loading = false;
          });
        });
      });
    }
  } //
}
