
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:viraeshop_api/utils/utils.dart';

class TransacFunctions {
  static String nameProvider (String userId, List transactionList, [bool isEmployee = false]){
    String name = '';
    if(transactionList.isNotEmpty){
      if(isEmployee){
        name = transactionList[0]['adminInfo']['name'];
      }else{
        String businessName = transactionList[0]['adminInfo']['businessName'] ?? '';
        String username = transactionList[0]['adminInfo']['name'] ?? '';
        if( businessName.isNotEmpty){
          name = businessName;
        }else{
          name = username;
        }
      }
    }
    return name;
  }
  /// This function will filter customers within a certain date range
  /// and return the total list of customers that perform transaction
  /// within that range
  static List customerFilter(List items, DateTime begin, DateTime end) {
    List filteredCustomers = [];
    for (var element in items) {
      Timestamp timestamp = dateFromJson(element['createdAt']);
      DateTime date = timestamp.toDate();
      begin = DateTime(begin.year, begin.month, begin.day);
      end = DateTime(end.year, end.month, end.day);
      DateTime dateFormatted = DateTime(date.year, date.month, date.day);
      if ((begin.isAfter(dateFormatted) ||
          begin.isAtSameMomentAs(dateFormatted)) &&
          (end.isBefore(dateFormatted) || end.isAtSameMomentAs(dateFormatted))) {
        filteredCustomers.add(element['customerId']);
      }
    }
    return filteredCustomers;
  }
/// Name search engine
  static List nameSearch({required String value,required String key,required List temps, String key2 = '', String key3 = ''}) {
    String field = '';
    String field2 = '';
    List names = [];
    for (var name in temps ){
      field = name[key][key2]?.toLowerCase() ?? '';
      field2 = name[key][key3]?.toLowerCase() ?? '';
      final valueLower = value.toLowerCase();
      if(field.contains(valueLower) || field2.contains(valueLower)){
        names.add(name[key][key2]);
      }
    }
    return names;
  }
}