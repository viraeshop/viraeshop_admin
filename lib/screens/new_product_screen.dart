import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
// import 'package:viraeshop_admin/components/styles/decoration.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:viraeshop_admin/configs/baxes.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/product_price.dart';
import 'package:viraeshop_admin/reusable_widgets/desktop_product_cards.dart';
import 'package:viraeshop_admin/reusable_widgets/desktop_product_cards2.dart';
import 'package:viraeshop_admin/reusable_widgets/form_field.dart';
import 'package:viraeshop_admin/screens/category_screen.dart';
import 'package:viraeshop_admin/screens/general_provider.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:viraeshop_admin/utils/utilities.dart';
import 'package:random_string/random_string.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';

import '../configs/functions.dart';
import '../configs/image_picker.dart';
import 'home_screen.dart';
import 'image_carousel.dart';

class NewProduct extends StatefulWidget {
  static String path = 'newProductPath';
  final bool isUpdateProduct;
  var info;
  String routeName;
  NewProduct({
    this.isUpdateProduct = false,
    this.info,
    this.routeName = '',
  });

  @override
  _NewProductState createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct>
    with SingleTickerProviderStateMixin {
  ImagePicker _picker = ImagePicker();
  File? _imageFile;
  List images = Hive.box('images').get('imagesBytes');
  List productImage = Hive.box('images').get('productImages');
  AdminCrud adminCrud = AdminCrud();
  GeneralCrud generalCrud = GeneralCrud();
  String _uniqueCode = randomAlphaNumeric(10);
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
  List _pr_user_List = ['general', 'agents', 'architect'];
  List _category_List = [];
  List<String> _sell_by = ['Unit', 'Sft', 'Rft', 'Kilo', 'Kg', 'CM', 'Pisce'];
  TextEditingController descController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _productIdController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _costController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _minimumController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _adsController = TextEditingController();
  TextEditingController _generalController = TextEditingController();
  TextEditingController _agentController = TextEditingController();
  TextEditingController _architectController = TextEditingController();
  TextEditingController _generalDiscountCont = TextEditingController();
  TextEditingController _architectDiscountCont = TextEditingController();
  TextEditingController _agentsDiscountCont = TextEditingController();
  List<Widget> _tabs = <Tab>[
    Tab(
      text: 'Product',
    ),
    Tab(
      text: 'Stock',
    ),
  ];
  List adverts = [];
  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: 2, vsync: this);
    if (widget.isUpdateProduct == true){
      descController.text = widget.info['description'];
        _nameController.text = widget.info['name'];
        _generalController.text = widget.info['generalPrice'].toString();
        _agentController.text = widget.info['agentsPrice'].toString();
        _architectController.text = widget.info['architectPrice'].toString();
        _generalDiscountCont.text = widget.info['generalDiscount'].toString();
        _agentsDiscountCont.text = widget.info['agentsDiscount'].toString();
        _productIdController.text = widget.info['productId'];
        _architectDiscountCont.text =
            widget.info['architectDiscount'].toString();
        _costController.text = widget.info['cost_price'];
        _quantityController.text = widget.info['quantity'].toString();
        widget.info['minimum'] != null
            ? _minimumController.text = widget.info['minimum'].toString()
            : '0';
        isGeneralDiscount = widget.info['isGeneralDiscount'];
        isAgentDiscount = widget.info['isAgentDiscount'];
        isArchitectDiscount = widget.info['isArchitectDiscount'];
        selectedSellby = widget.info['sell_by'];        
        isInfinity = widget.info['isInfinity'];   
        Hive.box('images').put('productImages', widget.info['image']);
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          Provider.of<GeneralProvider>(context, listen: false).updateAdList(widget.info['adverts']);
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
        ? DecorationImage(
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
    return ModalProgressHUD(
      inAsyncCall: loading,
      progressIndicator: CircularProgressIndicator(
        color: kMainColor,
      ),
      child: SafeArea(
        child: DefaultTabController(
          length: _tabs.length,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,
              iconTheme: IconThemeData(color: kSelectedTileColor),
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
                                title: Text('Delete Product'),
                                content: Text(
                                  'Are you sure you want to remove this Product?',
                                  softWrap: true,
                                  style: kSourceSansStyle,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      setState(() {
                                        loading = true;
                                      });
                                      Navigator.pop(dialogContext);
                                      await deleteProductImages(widget.info['image'])!
                                          .then((value) async {
                                            if(value == 'No image'){
                                              snackBar(text: 'No image found', context: context);
                                            }
                                        await FirebaseFirestore.instance
                                            .collection('products')
                                            .doc('items')
                                            .collection('products')
                                            .doc(widget.info['productId'])
                                            .delete()
                                            .then((value) {
                                          List products = Hive.box(productsBox)
                                              .get(productsKey);
                                          for (int i = 0;
                                              i < products.length;
                                              i++) {
                                            if (widget.info['productId'] ==
                                                products[i]['productId']) {
                                              products.removeAt(i);
                                            }
                                          }
                                          Hive.box(productsBox)
                                              .put(productsKey, products)
                                              .whenComplete(() {
                                            setState(() {
                                              loading = false;
                                            });
                                            Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            HomeScreen.path,
                                            (route) => false);
                                          });
                                        });
                                      });
                                    },
                                    child: Text(
                                      'Yes',
                                      softWrap: true,
                                      style: kSourceSansStyle,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
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
                        icon: Icon(
                          Icons.delete,
                        ),
                        color: kSubMainColor,
                        iconSize: 20.0,
                      )
                    : SizedBox(),
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
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder(
                        valueListenable: Hive.box('images').listenable(),
                        builder: (context, Box box, childs) {
                          List imagesByte =
                              box.get('imagesBytes', defaultValue: []);
                          if (widget.isUpdateProduct == true &&
                              imagesByte.isEmpty) {
                            return imageProduct(widget.info['image']);
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
                                  child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: [
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
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: kSubMainColor,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                        ),
                                      )),
                                  height: 100.0,
                                  width: 100.0,
                                  decoration: BoxDecoration(
                                    color: kProductCardColor,
                                    image: imagesByte.isEmpty
                                        ? DecorationImage(
                                            image: AssetImage(
                                                'assets/default.jpg'),
                                            fit: BoxFit.cover)
                                        : DecorationImage(
                                            image: MemoryImage(imagesByte[0]),
                                            fit: BoxFit.cover),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                  ],
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 0,
                  child: Column(
                    children: [
                      textFieldWidget(
                        controller: _nameController,
                        labelText: 'Product Name',
                      ),
                      textFieldWidget(
                        controller: _productIdController,
                        labelText: 'Product code',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(10.0),
                  margin: EdgeInsets.symmetric(vertical: 20.0),
                  color: kBackgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prices',
                        style: kProductNameStyle,
                      ),
                      SizedBox(
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
                      Text(
                        'Discounts',
                        style: kTotalSalesStyle,
                      ),
                      SizedBox(
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
                          ListTile(
                            title: Text(
                              'Details',
                              style: kProductNameStyle,
                            ),
                            // trailing: Icon(Icons.arrow_drop_up),
                          ),
                          SizedBox(
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
                                  decoration: InputDecoration(
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
                          SizedBox(
                            height: 20,
                          ),
                          Consumer<GeneralProvider>(
                              builder: (context, provider, childs) {
                            List advert = Set.from(provider.advertSelected).toList();
                            adverts = advert;
                            _adsController.clear();
                            adverts.forEach((element) {
                              _adsController.text += '$element, ';
                            });
                            print('Advert List: $adverts');
                            print('Consumer Advert List: $advert');
                            return TextFormField(
                              readOnly: true,
                              controller: _adsController,
                              style: kTableCellStyle,
                              onTap: isProducts == false
                                  ? null
                                  : () {
                                      getAdvertsDialog(buildContext: context);
                                    },
                              decoration: InputDecoration(
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
                          SizedBox(
                            height: 20,
                          ),
                          TextField(
                            style: kTableCellStyle,
                            controller: _costController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
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
                          SizedBox(
                            height: 20,
                          ),
                          TextField(
                            style: kTableCellStyle,
                            controller: descController,
                            maxLines: 2,
                            keyboardType: isProducts == true
                                ? TextInputType.text
                                : TextInputType.none,
                            decoration: InputDecoration(
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
                          SizedBox(
                            height: 20,
                          ),
                          DropdownButtonFormField(
                            value: selectedSellby,
                            decoration: InputDecoration(
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
                            hint: Text('Sell By'), // Not necessary for Option 1
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
                                child: new Text(itm),
                                value: itm,
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    )),
                SizedBox(
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
      padding: EdgeInsets.all(20.0),
      child: TextField(
        style: kTableCellStyle,
        controller: controller,
        onChanged: onChanged,
        keyboardType:
            isProducts == true ? TextInputType.text : TextInputType.none,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: kTableCellStyle,
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
          title: Text(
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
        Expanded(
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
                    Text(
                      'On hand',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                    TextField(
                      enabled: !isInfinity,
                      style: TextStyle(
                        color: isInfinity == false ? kBlackColor : Colors.grey[200],
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
                            color:
                                isInfinity == false ? kBlackColor : Colors.grey[200]!,
                          ),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                isInfinity == false ? kBlackColor : Colors.grey[200]!,
                          ),
                        ),
                        focusColor: kBlackColor,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                isInfinity == false ? kBlackColor : Colors.grey[200]!,
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
              padding: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    TextField(
                      enabled: !isInfinity,
                      style: TextStyle(
                        color: isInfinity == false ? kBlackColor : Colors.grey[200],
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
                            color:
                                isInfinity == false ? kBlackColor : Colors.grey[200]!,
                          ),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                isInfinity == false ? kBlackColor : Colors.grey[200]!,
                          ),
                        ),
                        focusColor: kBlackColor,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                isInfinity == false ? kBlackColor : Colors.grey[200]!,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    bottomCard(
                      context: context,
                      onTap: () async {
                        setState(() {
                          loading = true;
                          showFields = false;
                        });
                        bool isNotEmpty() {
                          if (_nameController.text != null &&
                              _categoryController.text != null &&
                              _generalController.text != null &&
                              _agentController.text != null &&
                              _architectController.text != null &&
                              _costController.text != null &&
                              _productIdController.text != null &&
                              _quantityController.text != null) {
                            return true;
                          } else {
                            return false;
                          }
                        }

                        if (isNotEmpty()) {
                          // var full_image = 'images/product_.jpg';
                          List imagesList = Hive.box('images')
                              .get('productImages', defaultValue: []);
                              print(imagesList);
                          Map<String, dynamic> fields = {
                            'category': _categoryController.text,
                            'sell_by': selectedSellby,
                            'minimum': isInfinity ? 0 : num.tryParse(_minimumController.text),
                            'name': _nameController.text,
                            'quantity': isInfinity ? 0 : num.parse(_quantityController.text),
                            'cost_price': _costController.text,
                            'generalPrice': isGeneral
                                ? num.parse(_generalController.text)
                                : 0,
                            'agentsPrice':
                                isAgent ? num.parse(_agentController.text) : 0,
                            'architectPrice': isArchitect
                                ? num.parse(_architectController.text)
                                : 0,
                            'description': descController.text,
                            'productId': _productIdController.text,
                            'image': imagesList,
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
                            'adverts': adverts,
                            'isInfinity': isInfinity,
                          };
                          print('Done with fields');
                          if (widget.isUpdateProduct == true) {
                            adminCrud
                                .updateProduct(
                                    fields, _productIdController.text)
                                .then(
                              (added) {
                                if (added) {
                                  snackBar(
                                      text: 'Product Updated Successfully',
                                      context: context);
                                  snackBar(
                                      text:
                                          'Updating products list please wait...',
                                      context: context);
                                  generalCrud.getProducts().then(
                                    (value) {
                                      final data = value.docs;
                                      List products = [];
                                      data.forEach((element) {
                                        products.add(element.data());
                                      });
                                      Hive.box(productsBox)
                                          .put(productsKey, products)
                                          .whenComplete(
                                        () {
                                          setState(() {
                                            loading = false;
                                            showFields = true;
                                          });
                                          Hive.box('images').clear();
                                          Hive.box('category').clear();
                                          snackBar(
                                              text:
                                                  'Products updated successfully',
                                              context: context);
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            HomeScreen.path,
                                            (route) => false,
                                          );
                                        },
                                      );
                                    },
                                  );
                                } else {
                                  setState(() {
                                    loading = false;
                                    showFields = true;
                                  });
                                  showDialogBox(
                                    buildContext: context,
                                    msg: 'An error occured please try again',
                                  );
                                }
                              },
                            );
                          } else {
                            adminCrud
                                .addProduct(fields, _productIdController.text)
                                .then((added) {
                              if (added) {
                                snackBar(
                                    text: 'Product Created Successfully',
                                    context: context);
                                snackBar(
                                    text:
                                        'Updating products list please wait...',
                                    context: context);
                                generalCrud.getProducts().then(
                                  (value) {
                                    final data = value.docs;
                                    List products = [];
                                    data.forEach((element) {
                                      products.add(element.data());
                                    });
                                    Hive.box(productsBox)
                                        .put(productsKey, products)
                                        .whenComplete(
                                      () {
                                        setState(() {
                                          loading = false;
                                          showFields = true;
                                        });
                                        Hive.box('images').clear();
                                        Hive.box('category').clear();
                                        snackBar(
                                            text:
                                                'Products updated successfully',
                                            context: context);
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            HomeScreen.path,
                                            (route) => false);
                                      },
                                    );
                                  },
                                );
                              } else {
                                setState(() {
                                  loading = false;
                                  showFields = true;
                                });
                                showDialogBox(
                                  buildContext: context,
                                  msg: 'An error occured please try again',
                                );
                              }
                            });
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
        padding: EdgeInsets.all(40.0),
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
                SizedBox(
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
                      Padding(
                        padding: EdgeInsets.only(left: 15.0, top: 15.0),
                        child: Text(
                          'Stocks',
                          style: kCategoryNameStyle,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Divider(
                          color: kScaffoldBackgroundColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
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
                            SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Category: ',
                                  style: kProductPriceStylePro,
                                ),
                                Center(
                                  child: Container(
                                    height: 46.0,
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    margin: EdgeInsets.all(10.0),
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
                                            decoration: InputDecoration(
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
            SizedBox(
              width: 30.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                imagePickerContainer(context),
                SizedBox(height: 10.0),
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
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, left: 15.0),
                        child: Text(
                          'Description',
                          style: kCategoryNameStyle,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Divider(
                          color: kScaffoldBackgroundColor,
                        ),
                      ),
                      // SizedBox(
                      //   height: 10.0,
                      // ),
                      Container(
                        margin: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
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
                            decoration: InputDecoration(
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
                SizedBox(height: 20.0),
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
                          child: Center(
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
                                'cost_price': _costController.text,
                                'quantity': _quantityController.text,
                                'sell_by': configs.sellBy,
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
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 15.0),
                    child: Text(
                      'Pick Product Image',
                      style: kCategoryNameStyle,
                    ),
                  ),
                  SizedBox(
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
              margin: EdgeInsets.all(10.0),
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
              child: Icon(Icons.add_a_photo, size: 30),
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
      Uint8List? imageBytes = result.files.first.bytes;
      List<PlatformFile> filePath = result.files.toList();
      setState(() {
        loading = true;
      });
      filePath.forEach((fileName) async {
        await adminCrud
            .uploadWebImage(imageBytes, fileName.path)
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
