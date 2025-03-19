// import 'package:bloc/bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:viraeshop_admin/settings/general_crud.dart';
// import 'product_event.dart';
// import 'product_state.dart';
//
// class ProductBloc extends Bloc<ProductEvent, ProductState> {
//   GeneralCrud generalCrud;
//   ProductBloc(this.generalCrud) : super(ProductLoadingState());
//
//   Stream<ProductState> mapEventToState(ProductEvent event) async* {
//     if (event is FetchProductEvent) {
//       yield ProductLoadingState();
//       try {
//         QuerySnapshot snapshots =
//             await generalCrud.getCategoryProducts(event.categoryName);
//         final data = snapshots.docs;
//         List products = [];
//         List productIds = [];
//         data.forEach((element) {
//           products.add(element.data());
//           productIds.add(element.id);
//         });
//         yield ProductLoadedState(productList: products, idList: productIds);
//       } catch (_) {
//         print(_);
//         yield ProductErrorState();
//       }
//     } else if (event is FetchAllProductEvent) {
//       yield ProductLoadingState();
//       try{
//         QuerySnapshot snapshot = await generalCrud.getProducts();
//          final data = snapshot.docs;
//         List products = [];
//         List productIds = [];
//         data.forEach((element) {
//           products.add(element.data());
//           productIds.add(element.id);
//         });
//         yield ProductLoadedState(productList: products, idList: productIds);
//       }catch (_) {
//         print(_);
//         yield ProductErrorState();
//       }
//     }
//   }
// }
