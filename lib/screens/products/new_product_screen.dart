import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/utils/product_helper.dart';
import 'package:viraeshop_bloc/category/category_bloc.dart';
import 'package:viraeshop_bloc/category/category_event.dart';
import 'package:viraeshop_bloc/products/barrel.dart';
import 'package:viraeshop_bloc/suppliers/barrel.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/product_price.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/general_provider.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';
import 'package:random_string/random_string.dart';

import '../../components/category_component/category.dart';
import '../../components/category_component/sub-category.dart';
import '../../configs/image_picker.dart';
import '../advert/ads_provider.dart';
import '../home_screen.dart';
import '../image_carousel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum Events { onUpdate, onDelete, onCreate }

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
  //var currdate = DateTime.now();
  late TabController _tabController;
  //var selected_pruser = '';
  String selectedSellBy = 'Unit';
  bool isGeneralDiscount = false;
  bool isAgentDiscount = false;
  bool isArchitectDiscount = false;
  bool isGeneral = true;
  bool isAgent = true;
  bool isArchitect = true;
  bool isInfinity = false;
  bool isNonInventory = false;
  bool topDiscount = false;
  bool freeShipping = false;
  bool comingSoon = false;
  final List<String> sellBy = [
    'Unit',
    'Pcs',
    'Pair',
    'Set',
    'Sft',
    'Rft',
    'Kilo',
    'Kg',
    'CM',
  ];
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _productCodeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _minimumController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _subCategoryController = TextEditingController();
  final TextEditingController _generalController = TextEditingController();
  final TextEditingController _agentController = TextEditingController();
  final TextEditingController _architectController = TextEditingController();
  final TextEditingController _generalDiscountCont = TextEditingController();
  final TextEditingController _architectDiscountCont = TextEditingController();
  final TextEditingController _agentsDiscountCont = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final List<Widget> _tabs = const <Tab>[
    Tab(
      text: 'Product',
    ),
    Tab(
      text: 'Stock',
    ),
  ];
  Map<String, dynamic> fields = {};
  bool onDelete = false;
  final jWTToken = Hive.box('adminInfo').get('token');
  final _formKey = GlobalKey<FormState>();
  Events currentEvent = Events.onCreate;
  @override
  void initState() {
    // Initialize the tab controller with 2 tabs
    _tabController = TabController(length: 2, vsync: this);
    // Initialize fields map
    if (widget.isUpdateProduct) {
      // Initialize form fields with existing data
      currentEvent = Events.onUpdate;
      _initializeFormFields();
      // Initialize product images using ProductHelper
      ProductHelper.initializeProductForEditing(widget.info);
    }

    super.initState();
  }

  // Initialize form fields from product data
  void _initializeFormFields() {
    final info = widget.info;

    // Set text fields
    _nameController.text = info['name'] ?? '';
    _productCodeController.text = info['productCode'] ?? '';
    _descController.text = info['description'] ?? '';
    _costController.text = info['costPrice']?.toString() ?? '0';
    _quantityController.text = info['quantity']?.toString() ?? '0';
    _minimumController.text = info['minimum']?.toString() ?? '0';

    // Set price fields
    _generalController.text = info['generalPrice']?.toString() ?? '0';
    _agentController.text = info['agentsPrice']?.toString() ?? '0';
    _architectController.text = info['architectPrice']?.toString() ?? '0';

    // Set discount fields
    _generalDiscountCont.text = info['generalDiscount']?.toString() ?? '0';
    _agentsDiscountCont.text = info['agentsDiscount']?.toString() ?? '0';
    _architectDiscountCont.text = info['architectDiscount']?.toString() ?? '0';

    // Set boolean values
    isGeneralDiscount = info['isGeneralDiscount'] ?? false;
    isAgentDiscount = info['isAgentDiscount'] ?? false;
    isArchitectDiscount = info['isArchitectDiscount'] ?? false;
    isInfinity = info['isInfinity'] ?? false;
    isNonInventory = info['isNonInventory'] ?? false;
    topDiscount = info['topDiscount'] ?? false;
    freeShipping = info['freeShipping'] ?? false;
    comingSoon = info['comingSoon'] ?? false;

    // Set dropdown values
    selectedSellBy = info['sellBy'] ?? 'Unit';

    // Set category and subcategory
    Hive.box('category').putAll({
      'name': info['category'] ?? '',
      'categoryId': info['categoryId'] ?? '',
    });
    Hive.box('subCategory').putAll({
      'name': info['subCategory'] ?? '',
      'subCategoryId': info['subCategoryId'] ?? '',
      'categoryId': info['categoryId'] ?? '',
    });

    // Set supplier information
    Hive.box('suppliers').putAll(info['supplier'] ?? {});
    // Set fields map
  }

  @override
  void dispose() {
    _tabController.dispose();
    // TODO: implement dispose
    super.dispose();
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
          if (currentEvent == Events.onUpdate) {
            List deletedImages = Hive.box('images').get('deletedImages') ?? [];
            List img = widget.info['images'] ?? [];
            if (deletedImages.isNotEmpty && img.isNotEmpty) {
              for (var image in deletedImages) {
                img.removeWhere(
                    (element) => element['imageLink'] == image['imageLink']);
              }
            }
            for (int i = 0; i < products.length; i++) {
              if (widget.info['productId'] == products[i]['productId']) {
                Map supplier = Hive.box('suppliers').toMap();
                fields['productId'] = widget.info['productId'];
                fields['supplier'] = supplier;
                fields['images'] += img;
                products[i] = fields;
              }
            }
            Provider.of<GeneralProvider>(context, listen: false).clearLists();
          } else if (currentEvent == Events.onDelete) {
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
          Provider.of<AdsProvider>(context, listen: false)
              .updateProductList(products);
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
                //automaticallyImplyLeading: true,
                leading: IconButton(
                  onPressed: () {
                    Hive.box('images').clear();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  color: kSubMainColor,
                ),
                iconTheme: const IconThemeData(
                  color: kSelectedTileColor,
                ),
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
                  widget.isUpdateProduct
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
                                          currentEvent = Events.onDelete;
                                        });
                                        Navigator.pop(dialogContext);
                                        List productImageUrls =
                                            Hive.box('images').get(
                                                'productImages',
                                                defaultValue: []);
                                        print(productImageUrls);
                                        try {
                                          if (productImageUrls.isNotEmpty) {
                                            await NetworkUtility
                                                .deleteProductImages(
                                                    images: productImageUrls);
                                          }
                                          productBloc.add(
                                            DeleteProductEvent(
                                              token: jWTToken,
                                              productId:
                                                  widget.info['productId'],
                                            ),
                                          );
                                        } catch (e) {
                                          if (kDebugMode) {
                                            print(e);
                                          }
                                          setState(() {
                                            loading = false;
                                          });
                                          if (context.mounted) {
                                            snackBar(
                                              text: e.toString(),
                                              context: context,
                                              duration: 100,
                                              color: kRedColor,
                                            );
                                          }
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
                  controller: _tabController,
                  indicatorColor: kMainColor,
                  labelColor: kTextColor1,
                ),
              ),
              body: ChangeNotifierProvider(
                create: (context) => Configs(),
                child: TabBarView(
                  controller: _tabController,
                  children: [addProduct(), stockPage()],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

// Build the image section
  Widget _buildImageSection() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('images').listenable(),
      builder: (context, Box box, child) {
        // Get image data using our helper
        final imageData = ProductHelper.getProductImageData();

        return Column(
          children: [
            GestureDetector(
              onTap: () => ProductHelper.navigateToImageCarousel(context),
              child: Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  color: kProductCardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kMainColor.withOpacity(0.2)),
                  image: _buildBackgroundImage(imageData),
                ),
                child: imageData['thumbnail'].isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 40, color: kSubMainColor),
                            SizedBox(height: 8),
                            Text(
                              'Add Product Images',
                              style: TextStyle(
                                color: kSubMainColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 10),

            // Show image count if images exist
            if (imageData['images'].isNotEmpty)
              Text(
                '${imageData['images'].length} product image${imageData['images'].length != 1 ? 's' : ''}',
                style: const TextStyle(
                  color: kSubMainColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        );
      },
    );
  }

  // Build background image for the image container
  DecorationImage? _buildBackgroundImage(Map<String, dynamic> imageData) {
    if (imageData['thumbnail'].isEmpty) {
      return null;
    }

    // For network images
    if (imageData['thumbnail'].startsWith('http')) {
      return DecorationImage(
        image: NetworkImage(imageData['thumbnail']),
        fit: BoxFit.cover,
      );
    }

    // For data URLs (web)
    if (imageData['thumbnail'].startsWith('data:')) {
      return DecorationImage(
        image: NetworkImage(imageData['thumbnail']),
        fit: BoxFit.cover,
      );
    }
  }

  // Products and stock
  addProduct() {
    bool isProducts = Hive.box('adminInfo').get('isProducts');
    return Form(
      key: _formKey,
      child: Stack(
        children: [
          ListView(
            //shrinkWrap: true,
            children: [
              // Product image section (using our improved components)
              _buildImageSection(),
              const SizedBox(height: 20),
              Container(
                color: kBackgroundColor,
                child: Column(
                  children: [
                    TextFieldWidget(
                      onTap: () {
                        _formKey.currentState!.validate();
                      },
                      controller: _nameController,
                      labelText: 'Product Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product name';
                        }
                        return null;
                      },
                    ),
                    TextFieldWidget(
                      onTap: () {
                        _formKey.currentState!.validate();
                      },
                      controller: _productCodeController,
                      labelText: 'Product code',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product code';
                        }
                        return null;
                      },
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
                      validator: isGeneral
                          ? (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the price';
                              }
                              return null;
                            }
                          : null,
                      onChanged: (value) {
                        setState(() {
                          isGeneral = value!;
                        });
                        _formKey.currentState!.validate();
                      },
                    ),
                    ProductPrice(
                      title: 'Agent Price',
                      isSelected: isAgent,
                      controller: _agentController,
                      validator: isAgent
                          ? (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the price';
                              }
                              return null;
                            }
                          : null,
                      onChanged: (value) {
                        setState(() {
                          isAgent = value!;
                        });
                        _formKey.currentState!.validate();
                      },
                    ),
                    ProductPrice(
                      title: 'Architect Price',
                      isSelected: isArchitect,
                      controller: _architectController,
                      onChanged: (value) {
                        setState(() {
                          isArchitect = value!;
                        });
                        _formKey.currentState!.validate();
                      },
                      validator: isArchitect
                          ? (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the price';
                              }
                              return null;
                            }
                          : null,
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
                        _formKey.currentState!.validate();
                      },
                      validator: isGeneralDiscount
                          ? (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter discount amount';
                              }
                              return null;
                            }
                          : null,
                    ),
                    ProductPrice(
                      title: 'Agent Discount',
                      isSelected: isAgentDiscount,
                      controller: _agentsDiscountCont,
                      onChanged: (value) {
                        setState(() {
                          isAgentDiscount = value!;
                        });
                        _formKey.currentState!.validate();
                      },
                      validator: isAgentDiscount
                          ? (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter discount amount';
                              }
                              return null;
                            }
                          : null,
                    ),
                    ProductPrice(
                      title: 'Architect Discount',
                      isSelected: isArchitectDiscount,
                      controller: _architectDiscountCont,
                      onChanged: (value) {
                        setState(() {
                          isArchitectDiscount = value!;
                        });
                        _formKey.currentState!.validate();
                      },
                      validator: isArchitectDiscount
                          ? (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter discount amount';
                              }
                              return null;
                            }
                          : null,
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
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        // Category
                        ValueListenableBuilder(
                            valueListenable: Hive.box('category').listenable(),
                            builder: (context, Box box, childs) {
                              String category = box.get('name',
                                  defaultValue: widget.isUpdateProduct
                                      ? widget.info['category']
                                      : '');
                              if (category.isNotEmpty) {
                                SchedulerBinding.instance
                                    .addPostFrameCallback((timeStamp) {
                                  _categoryController.text = category;
                                });
                              }
                              return TextFieldWidget(
                                readOnly: true,
                                labelText: 'Category',
                                controller: _categoryController,
                                onTap: isProducts == false
                                    ? null
                                    : () {
                                        _formKey.currentState!.validate();
                                        final categoryBloc =
                                            BlocProvider.of<CategoryBloc>(
                                                context);
                                        categoryBloc.add(
                                          GetCategoriesEvent(),
                                        );
                                        getCategoryDialog(
                                            buildContext: context);
                                      },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please add category';
                                  }
                                  return null;
                                },
                              );
                            }),

                        ValueListenableBuilder(
                            valueListenable:
                                Hive.box('subCategory').listenable(),
                            builder: (context, Box box, childs) {
                              String subCategory = box.get('name',
                                  defaultValue: widget.isUpdateProduct
                                      ? widget.info['category']
                                      : '');
                              if (subCategory.isNotEmpty) {
                                SchedulerBinding.instance
                                    .addPostFrameCallback((timeStamp) {
                                  _subCategoryController.text = subCategory;
                                });
                              }
                              return TextFieldWidget(
                                readOnly: true,
                                controller: _subCategoryController,
                                labelText: 'Sub-Category',
                                onTap: isProducts == false
                                    ? null
                                    : () {
                                        _formKey.currentState!.validate();
                                        if (Hive.box('category').isEmpty) {
                                          showMyDialog(
                                            'Please select category first!',
                                            context,
                                          );
                                        } else {
                                          final categoryBloc =
                                              BlocProvider.of<CategoryBloc>(
                                                  context);
                                          categoryBloc.add(
                                            GetCategoriesEvent(
                                              isSubCategory: true,
                                              categoryId: Hive.box('category')
                                                  .get('categoryId'),
                                            ),
                                          );
                                          getSubCategoryDialog(
                                            buildContext: context,
                                            categoryId: Hive.box('category')
                                                .get('categoryId'),
                                          );
                                        }
                                      },
                                // validator: (value) {
                                //   if (value == null || value.isEmpty) {
                                //     return 'Please add category';
                                //   }
                                //   return null;
                                // },
                              );
                            }),
                        // const SizedBox(
                        //   height: 10,
                        // ),
                        TextFieldWidget(
                          labelText: 'Cost',
                          controller: _costController,
                          keyboardType: TextInputType.number,
                          onTap: () {
                            _formKey.currentState!.validate();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter product cost';
                            }
                            return null;
                          },
                        ),
                        TextFieldWidget(
                          maxLines: 2,
                          controller: _descController,
                          labelText: 'Description',
                          keyboardType: isProducts == true
                              ? TextInputType.text
                              : TextInputType.none,
                        ),
                        ValueListenableBuilder(
                            valueListenable: Hive.box('suppliers').listenable(),
                            builder: (context, Box box, childs) {
                              String shopName =
                                  box.get('businessName', defaultValue: '');
                              if (shopName.isNotEmpty) {
                                _supplierController.text = shopName;
                              }
                              return TextFieldWidget(
                                onTap: () {
                                  _formKey.currentState!.validate();
                                  final supplierBloc =
                                      BlocProvider.of<SuppliersBloc>(context);
                                  supplierBloc.add(
                                      GetSuppliersEvent(token: jWTToken ?? ''));
                                  getNonInventoryDialog(
                                    buildContext: context,
                                    box: 'suppliers',
                                  );
                                },
                                controller: _supplierController,
                                labelText: 'Suppliers',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please add supplier';
                                  }
                                  return null;
                                },
                              );
                            }),
                        ValueListenableBuilder(
                          valueListenable: Hive.box('suppliers').listenable(),
                          builder: (context, aBox, childs) {
                            String selectedSellBy =
                                aBox.get('sellBy', defaultValue: 'Unit');
                            return DropdownButtonFormField(
                              value: selectedSellBy,
                              decoration: const InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: kBlackColor),
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: kBlackColor),
                                ),
                                focusColor: kBlackColor,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: kBlackColor,
                                  ),
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.black87,
                                ),
                              ),
                              hint: const Text('Sell By'),
                              onChanged: isProducts == false
                                  ? null
                                  : (String? changedValue) {
                                      Hive.box('suppliers').put('sellBy', changedValue);
                                    },
                              items: sellBy.map((itm) {
                                return DropdownMenuItem(
                                  value: itm,
                                  child: Text(itm),
                                );
                              }).toList(),
                            );
                          }
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  )),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ],
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
        SwitchListTile(
          activeColor: kNewMainColor,
          tileColor: kBackgroundColor,
          title: const Text(
            'Non Inventory Product',
            style: kTableCellStyle,
          ),
          value: isNonInventory,
          onChanged: (value) {
            setState(() {
              isNonInventory = value;
            });
          },
        ),
        SwitchListTile(
          activeColor: kNewMainColor,
          tileColor: kBackgroundColor,
          title: const Text(
            'Free Shipping',
            style: kTableCellStyle,
          ),
          value: freeShipping,
          onChanged: (value) {
            setState(() {
              freeShipping = value;
            });
          },
        ),
        SwitchListTile(
          activeColor: kNewMainColor,
          tileColor: kBackgroundColor,
          title: const Text(
            'Coming soon',
            style: kTableCellStyle,
          ),
          value: comingSoon,
          onChanged: (value) {
            setState(() {
              comingSoon = value;
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
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10,),
                child: Column(
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
                      onTap: (){
                        _saveProduct();
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

  // Save the product
  Future<void> _saveProduct() async {
    // Validate form
    setState(() {
      loading = true;
      showFields = false;
    });
    bool isNotEmpty() {
      if (_nameController.text.isNotEmpty &&
          _categoryController.text.isNotEmpty &&
          _generalController.text.isNotEmpty &&
          _agentController.text.isNotEmpty &&
          _architectController.text.isNotEmpty &&
          _costController.text.isNotEmpty &&
          _productCodeController.text.isNotEmpty &&
          _supplierController.text.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    }

    if (isNotEmpty()) {
      Map<String, dynamic> productData = ProductHelper.collectProductFormData(
        name: _nameController.text,
        productCode: _productCodeController.text,
        description: _descController.text,
        generalPrice: _generalController.text,
        agentsPrice: _agentController.text,
        architectPrice: _architectController.text,
        costPrice: _costController.text,
        quantity: _quantityController.text,
        minimum: _minimumController.text,
        isGeneralDiscount: isGeneralDiscount,
        isAgentDiscount: isAgentDiscount,
        isArchitectDiscount: isArchitectDiscount,
        generalDiscount: _generalDiscountCont.text,
        agentsDiscount: _agentsDiscountCont.text,
        architectDiscount: _architectDiscountCont.text,
        isInfinity: isInfinity,
        isNonInventory: isNonInventory,
        freeShipping: freeShipping,
        comingSoon: comingSoon,
        sellBy: selectedSellBy,
      );

      // Prepare images
      final imageData = await ProductHelper.prepareProductImagesForSaving();

      // Combine data
      productData = {
        ...productData,
        'images': imageData['allImages'],
        'thumbnail': imageData['thumbnail'],
        'thumbnailKey': imageData['thumbnailKey'],
        if (widget.isUpdateProduct) 'deletedImages': imageData['deletedImages'],
      };

      setState(() {
        fields = productData;
      });
      // Save product
      final productBloc = BlocProvider.of<ProductsBloc>(context);

      if (widget.isUpdateProduct) {
        productBloc.add(UpdateProductEvent(
          token: jWTToken ?? '',
          productId: widget.info['productId'],
          productModel: productData,
        ));
      } else {
        productBloc.add(AddProductEvent(
          token: jWTToken ?? '',
          productModel: productData,
        ));
      }
    } else {
      setState(() {
        loading = false;
        showFields = true;
      });
      showDialogBox(
        buildContext: context,
        msg: 'Fields can\'t be empty!, please check and add any missing field',
      );
    }
  }
}

class TextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String?)? onChanged;
  final String labelText;
  final String? Function(String?)? validator;
  final bool readOnly;
  final void Function()? onTap;
  final TextInputType keyboardType;
  final int? maxLines;
  const TextFieldWidget({
    Key? key,
    required this.controller,
    this.onChanged,
    this.labelText = '',
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.maxLines,
  }) : super(key: key);

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool isProducts = Hive.box('adminInfo').get('isProducts');
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: TextFormField(
        maxLines: widget.maxLines,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        style: kTableCellStyle,
        controller: widget.controller,
        onChanged: widget.onChanged,
        keyboardType:
            isProducts == true ? widget.keyboardType : TextInputType.none,
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.labelText,
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
}
