import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_bloc/orders/orders_bloc.dart';
import 'package:viraeshop_bloc/orders/orders_event.dart';

void getOrders(
    {required Map<String, dynamic> data, required BuildContext context}) {
  final jWTToken = Hive.box('adminInfo').get('token');
  final orderBloc = BlocProvider.of<OrdersBloc>(context);
  orderBloc.add(
    GetOrdersEvent(
      token: jWTToken,
      data: data,
    ),
  );
}

void orderUpdate(
    {required BuildContext context,
    required Map<String, dynamic> data,
    required String orderId,
    token}) {
  final orderBloc = BlocProvider.of<OrdersBloc>(context);
  orderBloc.add(
    UpdateOrderEvent(
      orderId: orderId,
      orderModel: data,
      token: token,
    ),
  );
}
