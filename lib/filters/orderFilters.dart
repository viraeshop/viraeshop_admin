import 'package:viraeshop_admin/screens/orders/order_provider.dart';

String orderFilter (OrderStages stage){
  switch(stage){
    case OrderStages.processing:
      return 'processingStatus';
    case OrderStages.receiving:
      return 'receiveStatus';
    case OrderStages.delivery:
      return 'deliveryStatus';
    case OrderStages.admin:
      return 'adminId';
    default:
      return 'default';
  }
}