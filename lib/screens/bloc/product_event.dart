import 'package:equatable/equatable.dart';

class ProductEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FetchProductEvent extends ProductEvent {
  final String categoryName;
  FetchProductEvent({required this.categoryName});
  @override
  List<Object?> get props => [categoryName];
}

class FetchAllProductEvent extends ProductEvent {
  @override
  List<Object?> get props => [];
}
