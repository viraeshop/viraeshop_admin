import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop/admin/admin_bloc.dart';
import 'package:viraeshop/admin/admin_event.dart';
import 'package:viraeshop/admin/admin_state.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_api/models/admin/admins.dart';

class TestApi extends StatefulWidget {
  const TestApi({Key? key}) : super(key: key);

  @override
  State<TestApi> createState() => _TestApiState();
}

class _TestApiState extends State<TestApi> {
  // bool start = false;
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  void initState() {
    // TODO: implement initState
    final adminBloc = BlocProvider.of<AdminBloc>(context);
    adminBloc.add(GetAdminsEvent(token: jWTToken));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is FetchedAdminsState) {
          final adminBloc = BlocProvider.of<AdminBloc>(context);
          List<AdminModel>? value = state.adminList;
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: kBackgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text(
                    'Delete',
                    style: kProductNameStyle,
                  ),
                  onPressed: () {
                    adminBloc.add(
                        DeleteAdminEvent(adminId: '654321', token: jWTToken));
                  },
                ),
                ElevatedButton(
                  child: const Text(
                    'Get',
                    style: kProductNameStyle,
                  ),
                  onPressed: () {},
                ),
                const SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                  child: const Text(
                    'Create',
                    style: kProductNameStyle,
                  ),
                  onPressed: () async {
                    AdminModel admin = AdminModel(
                      email: 'hawwau@gmail.com',
                      name: 'Hauwa Sani',
                      isAdmin: true,
                      isDeleteCustomer: true,
                      isDeleteEmployee: true,
                      isEditCustomer: true,
                      isInventory: true,
                      isMakeAdmin: true,
                      isMakeCustomer: true,
                      isManageDue: true,
                      isProducts: true,
                      isTransactions: true,
                      adminId: '362789',
                      active: true,
                    );
                    adminBloc
                        .add(AddAdminEvent(adminModel: admin, token: jWTToken));
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: List.generate(
                    value != null ? value.length : 0,
                    (i) => Text(
                      value != null ? value[i].name : '',
                      style: kProductNameStyle,
                    ),
                  ),
                )
              ],
            ),
          );
        } else if (state is OnErrorAdminState) {
          String message = state.message;
          return Center(
              child: Text(
            message,
            style: kDueCellStyle,
          ));
        }
        return const SizedBox(
          height: 100,
          width: 100,
          child: CircularProgressIndicator(
            color: kNewMainColor,
          ),
        );
      },
    ));
  }
}
