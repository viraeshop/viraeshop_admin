

import 'package:tuple/tuple.dart';
import 'package:viraeshop_admin/configs/configs.dart';

num getCurrentPrice (Map item, String dropdownValue){
  num currentPrice = 0;
  if (dropdownValue == 'general') {
    currentPrice = item['generalPrice'];
  } else if (dropdownValue == 'agents') {
    currentPrice = item['agentsPrice'];
  }else{
    currentPrice =
    item['architectPrice'];
  }
  return currentPrice;
}

Tuple3<num, num, bool> computeDiscountData (Map item, String dropdownValue, num currentPrice){
  Tuple3<num, num, bool> discountData = const Tuple3<num, num, bool>(0, 0, false);
  if (dropdownValue == 'general') {
    bool isDiscount =
    item['isGeneralDiscount'];
    if (isDiscount) {
      num discountPercent = percent(
          item['generalDiscount'],
          item['generalPrice']);
      num discountPrice = item
      ['generalPrice'] -
          item['generalDiscount'];
      discountData = Tuple3<num, num, bool>(
          discountPrice, discountPercent, isDiscount);
    }
  } else if (dropdownValue == 'agents') {
    bool isDiscount =
    item['isAgentDiscount'];
    if (isDiscount) {
      num discountPercent = percent(
          item['agentsDiscount'],
          currentPrice);
      num discountPrice = currentPrice -
          item['agentsDiscount'];
      discountData = Tuple3<num, num, bool>(
          discountPrice, discountPercent, isDiscount);
    }
  } else {
    bool isDiscount =
    item['isArchitectDiscount'];
    if (isDiscount) {
      num discountPercent = percent(
          item['architectDiscount'],
          currentPrice);
      num discountPrice = currentPrice -
          item['architectDiscount'];
      discountData = Tuple3<num, num, bool>(
          discountPrice, discountPercent, isDiscount);
    }
  }
  return discountData;
}