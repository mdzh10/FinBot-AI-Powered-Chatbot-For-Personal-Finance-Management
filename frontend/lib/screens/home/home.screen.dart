import 'dart:convert';
import 'package:events_emitter/listener.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:finbot/models/AccountResponseModel.dart';
import 'package:finbot/models/Transaction.dart';
import 'package:finbot/models/TransactionResponse.dart';
import 'package:finbot/screens/home/widgets/account_slider.dart';
import 'package:finbot/screens/home/widgets/payment_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../bloc/cubit/app_cubit.dart';
import '../../models/Account.dart';
import '../../models/DashboardResponseModel.dart';
import '../../theme/colors.dart';
import '../../widgets/currency.dart';
import '../payment_form.screen.dart';


String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Morning';
  }
  if (hour < 17) {
    return 'Afternoon';
  }
  return 'Evening';
}


class HomeScreen extends StatefulWidget {
  final int? userId;
  HomeScreen(this.userId, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  EventListener? _accountEventListener;
  EventListener? _paymentEventListener;
  List<Account> _accounts = [];
  List<Transaction> _transactions = [];
  AccountResponseModel? accountResponseModel;
  DashboardResponseModel? dashboardResponseModel;
  TransactionResponse? transactionResponse;

  double _income = 0;
  double _expense = 0;
  //double _savings = 0;
  DateTimeRange _range = DateTimeRange(
      start: DateTime.now().subtract(Duration(days: DateTime.now().day -1)),
      end: DateTime.now()
  );
  Account? _account;
  // Category? _category;

  void openAddPaymentPage(TransactionType type) async {
    Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>PaymentForm(type: type, userId: widget.userId,)));
  }

  void handleChooseDateRange() async{
    final selected = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    );
    if(selected != null) {
      setState(() {
        _range = selected;
        _fetchTransactions(widget.userId);
      });
    }
  }

  void _fetchTransactions(int? userId) async {

    final queryParameters = {
      'start_date': _range.start.toIso8601String(), // Use the selected date range
      'end_date': _range.end.toIso8601String(),
    };

    final uriTrans = Uri.parse("https://finbot-fastapi-rc4376baha-ue.a.run.app/transaction/$userId")
        .replace(queryParameters: queryParameters);

    print('API URL: $uriTrans');


    final url = Uri.parse(
        'https://finbot-fastapi-rc4376baha-ue.a.run.app/dashboard/$userId?start_date=${_range.start}&end_date=${_range.end}');

    try {
      final responseTrans = await http.get(uriTrans);
      print('Response Status: ${responseTrans.statusCode}');
      print('Response Body: ${responseTrans.body}');

      if (responseTrans.statusCode == 200) {
        // Decode JSON and create the TransactionResponse object
        final Map<String, dynamic> json = jsonDecode(responseTrans.body);
        transactionResponse = TransactionResponse.fromJson(json);
      } else {
        print('Failed to load data: ${transactionResponse}');
      }
      final responseDashboard = await http.get(url);

      if (responseDashboard.statusCode == 200) {
        final data = jsonDecode(responseDashboard.body);
        dashboardResponseModel = DashboardResponseModel.fromJson(data);
      } else {
        print('Failed to load data: ${responseDashboard.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

      final String apiUrl = "https://finbot-fastapi-rc4376baha-ue.a.run.app/account/"+userId.toString();
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );
      print(json.decode(response.body));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        accountResponseModel = AccountResponseModel.fromJson(data);
      } else {
        throw Exception('Failed to load accounts');
      }



    //fetch accounts
    List<Account>? accounts = accountResponseModel?.accounts;
    List<Transaction>? transactions = transactionResponse?.transactions;

    setState(() {
      _transactions = transactions != null? transactions : [];
      // _income = income;
      // _expense = expense;
      _accounts = accounts != null? accounts : [];
    });
  }


  @override
  void initState() {
    super.initState();
    _fetchTransactions(widget.userId);
  }

  @override
  void dispose() {
    _accountEventListener?.cancel();
    // _categoryEventListener?.cancel();
    _paymentEventListener?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hi! Good ${greeting()}"),
                    BlocConsumer<AppCubit, AppState>(
                        listener: (context, state){

                        },
                        builder: (context, state)=>Text(state.userName ?? "Guest", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),)
                    )
                  ],
                ),
              ),
              AccountsSlider(accounts: _accounts,),
              const SizedBox(height: 15,),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                    children: [
                      const Text("Payments", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                      const Expanded(child: SizedBox()),
                      MaterialButton(
                        onPressed: (){
                          handleChooseDateRange();
                        },
                        height: double.minPositive,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: Row(
                          children: [
                            Text("${DateFormat("dd MMM").format(_range.start)} - ${DateFormat("dd MMM").format(_range.end)}", style: Theme.of(context).textTheme.bodySmall,),
                            const Icon(Icons.arrow_drop_down_outlined)
                          ],
                        ),
                      ),
                    ]
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: ThemeColors.success.withOpacity(0.2),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text.rich(
                                      TextSpan(
                                          children: [
                                            //TextSpan(text: "▼", style: TextStyle(color: ThemeColors.success)),
                                            TextSpan(text:"Income", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                          ]
                                      )
                                  ),
                                  const SizedBox(height: 5,),
                                  CurrencyText(dashboardResponseModel?.credits, style:  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ThemeColors.success),)
                                ],
                              ),
                            )
                        )
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                        child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: ThemeColors.error.withOpacity(0.2),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text.rich(
                                      TextSpan(
                                          children: [
                                            //TextSpan(text: "▲", style: TextStyle(color: ThemeColors.error)),
                                            TextSpan(text:"Expense", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                          ]
                                      )
                                  ),
                                  const SizedBox(height: 5,),
                                  CurrencyText(dashboardResponseModel?.debits, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ThemeColors.error),)
                                ],
                              ),
                            )
                        )
                    ),
                  ],
                ),
              ),
              _transactions.isNotEmpty? ListView.separated(
                padding:  EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, index){
                  return PaymentListItem(transaction: _transactions[index], onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>PaymentForm(type: _transactions[index].type, transaction: _transactions[index], userId: widget.userId,)));
                  });

                },
                separatorBuilder: (BuildContext context, int index){
                  return Container(
                    width: double.infinity,
                    color: Colors.grey.withAlpha(25),
                    height: 1,
                    margin: const EdgeInsets.only(left: 75, right: 20),
                  );
                },
                itemCount: _transactions.length,
              ):Container(
                padding: const EdgeInsets.symmetric(vertical: 25),
                alignment: Alignment.center,
                child: const Text("No payments!"),
              ),
            ],
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=> openAddPaymentPage(TransactionType.credit),
        child: const Icon(Icons.add),
      ),
    );
  }
}
