import 'package:flutter/foundation.dart';

class CustomerProvider extends ChangeNotifier {
  Amount defaultAmount = Amount.wallet;
  num wallet = 0;
  num creditBalance = 0;
  num alertLimit = 0;
  num accountLimit = 0;
  num placeholderAmount = 0;
  num dueBalance = 0;
  bool isLoading = false;

  void updateAmounts(
      {required num wallet,
      required num creditBalance,
      required num alertLimit,
      required num accountLimit,
      required num dueBalance,
      bool add = false}) {
    this.wallet = wallet;
    this.creditBalance = creditBalance;
    this.alertLimit = alertLimit;
    this.accountLimit = accountLimit;
    this.dueBalance = dueBalance;
    notifyListeners();
  }

  void updateAmount(num value, Amount amount) {
    if (amount == Amount.wallet) {
      wallet = value;
    } else if (amount == Amount.credit) {
      creditBalance = value;
    } else if (amount == Amount.alert) {
      alertLimit = value;
    } else {
      accountLimit = value;
    }
    notifyListeners();
  }

  void changeAmountType(Amount amount) {
    defaultAmount = amount;
    notifyListeners();
  }

  void switchLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void updatePlaceHolderAmount(num value) {
    placeholderAmount = value;
    notifyListeners();
  }
}

enum Amount {
  wallet,
  credit,
  alert,
  account,
}
