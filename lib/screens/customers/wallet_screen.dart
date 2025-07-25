import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_bloc/customers/barrel.dart';

import '../../components/custom_widgets.dart';
import '../../components/styles/colors.dart';
import 'customer_provider.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key, required this.customerId});
  final String customerId;
  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(builder: (context, customer, any) {
      return ModalProgressHUD(
        inAsyncCall: customer.isLoading,
        progressIndicator: const CircularProgressIndicator(
          color: kNewMainColor,
        ),
        child: BlocListener<CustomersBloc, CustomerState>(
          listener: (context, state) {
            if (state is RequestFinishedCustomerState) {
              final response = state.response.result ?? {};
              final wallet = response['wallet'] ?? 0;
              final creditBalance = response['creditBalance'] ?? 0;
              final alertLimit = response['alertLimit'] ?? 0;
              final accountLimit = response['accountLimit'] ?? 0;
              final dueBalance = response['dueBalance'] ?? 0;
              final customerProvider =
                  Provider.of<CustomerProvider>(context, listen: false);
              customerProvider.switchLoading(false);
              customerProvider.updateAmounts(
                  wallet: wallet,
                  creditBalance: creditBalance,
                  alertLimit: alertLimit,
                  accountLimit: accountLimit,
                  dueBalance: dueBalance);
              snackBar(
                text: 'Amount added',
                context: context,
                duration: 400,
              );
            } else if (state is OnErrorCustomerState) {
              Provider.of<CustomerProvider>(context, listen: false)
                  .switchLoading(false);
              snackBar(
                text: state.message,
                context: context,
                duration: 400,
                color: kRedColor,
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(15.0),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Text(
                  'Wallet Information'.toUpperCase(),
                  style: kProductNameStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 330,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment(0.95, -0.31),
                        end: Alignment(-0.95, 0.31),
                        colors: [
                          Color(0xFFFCB2E7),
                          Color(0xFFFF83BB),
                          Color(0xFFFFB199),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/vira_shop.png',
                              width: 30,
                              height: 30,
                            ),
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(
                                Icons.done_rounded,
                                color: kBlackColor,
                              ),
                            ),
                          ],
                        ),
                        WalletRow(
                          amount: Amount.credit,
                          value: customer.creditBalance.toString(),
                          title: 'TOTAL BALANCE ON CREDIT: ',
                          customerId: customerId,
                        ),
                        WalletRow(
                          amount: Amount.alert,
                          value: customer.alertLimit.toString(),
                          title: 'ALERT LIMIT: ',
                          customerId: customerId,
                        ),
                        WalletRow(
                          amount: Amount.account,
                          value: customer.accountLimit.toString(),
                          title: 'ACCOUNT LIMIT: ',
                          customerId: customerId,
                        ),
                        WalletRow(
                          title: 'AVAILABLE BALANCE: ',
                          value: customer.wallet.toString(),
                          amount: Amount.wallet,
                          customerId: customerId,
                          isEditable: false,
                        ),
                        WalletRow(
                          title: 'USED BALANCE: ',
                          value: (customer.dueBalance).toString(),
                          amount: Amount.wallet,
                          customerId: customerId,
                          isEditable: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class WalletRow extends StatefulWidget {
  const WalletRow({
    super.key,
    required this.amount,
    required this.value,
    required this.title,
    required this.customerId,
    this.isEditable = true,
  });
  final String title;
  final String value;
  final Amount amount;
  final String customerId;
  final bool isEditable;
  @override
  State<WalletRow> createState() => _WalletRowState();
}

class _WalletRowState extends State<WalletRow> {
  final TextEditingController walletController = TextEditingController();
  bool isEditCustomer =
      Hive.box('adminInfo').get('isEditCustomer', defaultValue: false);
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(
            text: widget.title,
            style: const TextStyle(
              fontSize: 15,
              color: kBackgroundColor,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: '${widget.value}৳',
                style: const TextStyle(
                  fontSize: 20,
                  color: kBackgroundColor,
                ),
              ),
            ],
          ),
        ),
        if (widget.isEditable)
          IconButton(
            onPressed: () {
              Provider.of<CustomerProvider>(context, listen: false)
                  .changeAmountType(widget.amount);
              popDialog(
                title: 'Add Funds',
                context: context,
                widget: SingleChildScrollView(
                  child: Column(
                    // shrinkWrap: true,
                    children: [
                      TextField(
                        controller: walletController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Amount",
                          hintText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Consumer<CustomerProvider>(
                          builder: (context, customer, any) {
                        return InkWell(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 58,
                            decoration: BoxDecoration(
                                color:
                                    kSelectedTileColor, //Theme.of(context).accentColor,
                                borderRadius: BorderRadius.circular(15)),
                            child: const Center(
                              child: Text(
                                "Add",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                          ),
                          onTap: () {
                            num newBalance = num.parse(walletController.text);
                            Navigator.pop(context);
                            final customerProvider =
                                Provider.of<CustomerProvider>(context,
                                    listen: false);
                            customerProvider.switchLoading(true);
                            customerProvider
                                .updatePlaceHolderAmount(newBalance);
                            final customerBloc = BlocProvider.of<CustomersBloc>(
                              context,
                            );
                            customerBloc.add(
                              UpdateCustomerEvent(
                                customerId: widget.customerId,
                                customerModel: {
                                  if (widget.amount == Amount.credit)
                                    'creditBalance': newBalance,
                                  if (widget.amount == Amount.credit)
                                    'wallet': newBalance,
                                  if (widget.amount == Amount.alert)
                                    'alertLimit': newBalance,
                                  if (widget.amount == Amount.account)
                                    'accountLimit': newBalance,
                                },
                                token: jWTToken,
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit),
            color: kBackgroundColor,
          ),
      ],
    );
  }
}
