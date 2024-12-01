import 'dart:convert';

import 'package:events_emitter/listener.dart';
import 'package:finbot/models/AccountResponseModel.dart';
import 'package:finbot/models/CategoryResponseModel.dart';
import 'package:finbot/models/Transaction.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/Account.dart';
import '../models/category.model.dart';
import '../theme/colors.dart';
import '../widgets/buttons/button.dart';
import '../widgets/currency.dart';
import '../widgets/dialog/account_form.dialog.dart';
import '../widgets/dialog/category_form.dialog.dart';
import '../widgets/dialog/confirm.modal.dart';

typedef OnCloseCallback = Function(Transaction transaction);
final DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');
class PaymentForm extends StatefulWidget{
  final TransactionType? type;
  final Transaction? transaction;
  final OnCloseCallback? onClose;
  final int? userId;

  const PaymentForm({super.key, required this.type, this.transaction, this.onClose, this.userId});

  @override
  State<PaymentForm> createState() => _PaymentForm();
}

class _PaymentForm extends State<PaymentForm>{
  bool _initialised = false;
  bool _isLoading = false;


  EventListener? _accountEventListener;
  EventListener? _categoryEventListener;
  AccountResponseModel? accountResponseModel;
  CategoryResponse? categoryResponse;

  List<Account> _accounts = [];
  List<Category> _categories = [];

  //values
  int? _id;
  String? _title = "";
  String? _description="";
  Account? _account;
  Category? _category;
  bool? _isExceed;
  double? _amount=0;
  TransactionType? _type;
  DateTime? _datetime = DateTime.now();

  loadAccounts() async {
    setState(() {
      _isLoading = true;
    });

    final String apiUrl = "https://finbot-fastapi-rc4376baha-ue.a.run.app/account/" + widget.userId.toString();
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      accountResponseModel = AccountResponseModel.fromJson(data);
    } else {
      throw Exception('Failed to load accounts');
    }

    List<Account>? accounts = accountResponseModel?.accounts;

    setState(() {
      _accounts = accounts ?? [];
      _isLoading = false;
    });

  }

  loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    final String apiUrl = "https://finbot-fastapi-rc4376baha-ue.a.run.app/category/" + widget.userId.toString();
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      categoryResponse = CategoryResponse.fromJson(data);
    } else {
      throw Exception('Failed to load categories');
    }

    setState(() {
      _categories = categoryResponse?.categories ?? [];
      _isLoading = false;
    });
  }

  void populateState() async{
    await loadAccounts();
    await loadCategories();
    if(widget.transaction != null) {
      setState(() {
        _id = widget.transaction!.id;
        _title = widget.transaction!.title;
        _description = widget.transaction!.description;
        _account = widget.transaction!.account;
        _category = widget.transaction!.category;
        _amount = widget.transaction!.amount;
        _type = widget.transaction!.type;
        _datetime = widget.transaction!.datetime;
        _initialised = true;
      });
    }
    else
    {
      setState(() {
        _type =  widget.type;
        _initialised = true;
      });
    }

  }

  Future<void> chooseDate(BuildContext context) async {
    DateTime? initialDate = _datetime;
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime.now()
    );
    if(picked!=null  && initialDate != picked) {
      setState(() {
        _datetime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            initialDate!.hour,
            initialDate!.minute
        );
      });
    }
  }

  Future<void> chooseTime(BuildContext context) async {
    DateTime? initialDate = _datetime;
    TimeOfDay initialTime = TimeOfDay(hour: initialDate!.hour, minute: initialDate.minute);
    final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: initialTime,
        initialEntryMode: TimePickerEntryMode.input
    );
    if (time != null && initialTime !=time) {
      setState(() {
        _datetime = DateTime(
            initialDate.year,
            initialDate.month,
            initialDate.day,
            time.hour,
            time.minute
        );
      });
    }
  }

  void handleSaveTransaction(context) async {
    Transaction transaction = Transaction(id: _id,
        account: _account,
        category: _category,
        amount: _amount,
        type: _type,
        datetime: _datetime,
        title: _title,
        description: _description,
        userId: widget.userId ?? 0
    );

    if (transaction.id == null) {
      final url = Uri.parse('https://finbot-fastapi-rc4376baha-ue.a.run.app/transaction/add');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final body = jsonEncode([{
        "user_id": widget.userId,
        "account_id": _account?.id,
        "category_id": _category?.id,
        "title": _title,
        "description": _description,
        "amount": _amount,
        "type": _type?.toJson(),
        "datetime": _datetime?.toIso8601String(),
        "isExceed": false,
      }]);

      print("Request Body: $body");


      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          if (responseData['isSuccess']) {
            print("Transaction added successfully!");
            print("Response Message: ${responseData['msg']}");
            final List<dynamic> transactionsJson = responseData['transactions'];
            final List<Transaction> transactions = transactionsJson
                .map((transactionJson) => Transaction.fromJson(transactionJson))
                .toList();

            // Filter the transactions where isExceed is false
            final List<Transaction> nonExceedTransactions = transactions
                .where((transaction) => transaction.isExceed == false)
                .toList();
            // Log the filtered transactions
            print("Non-Exceed Transactions:");
            for (var transaction in nonExceedTransactions) {
              print(transaction.toJson());
            }

          } else {
            print("Failed to add transaction: ${responseData['msg']}");
          }
        } else {
          print("Error: ${response.statusCode}");
          print("Response Body: ${response.body}");
        }
      } catch (e) {
        print("Exception occurred: $e");
      }
    } else {
      final url = Uri.parse('https://finbot-fastapi-rc4376baha-ue.a.run.app/transaction/modify'); // Replace with your API URL
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final body = jsonEncode({
        "id": transaction.id,
        "user_id": widget.userId,
        "account_id": _account?.id,
        "category_id": _category?.id,
        "title": _title,
        "description": _description,
        "amount": _amount,
        "type": _type?.toJson(),
        "datetime": _datetime?.toIso8601String()
      });

      try {
        final response = await http.put(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          if (responseData['isSuccess']) {
            print("Transaction modified successfully!");
            print("Response Message: ${responseData['msg']}");
            print("Transactions: ${responseData['transactions']}");
          } else {
            print("Failed to modify transaction: ${responseData['msg']}");
          }
        } else {
          print("Error: ${response.statusCode}");
          print("Response Body: ${response.body}");
        }
      } catch (e) {
        print("Exception occurred: $e");
      }

  }


    if (widget.onClose != null) {
      widget.onClose!(transaction);
    }
    Navigator.of(context).pop();
  }

  Future<void> deleteTransaction(int transactionId) async {
    final url = Uri.parse('https://finbot-fastapi-rc4376baha-ue.a.run.app/transaction/delete/$transactionId'); // Replace with the actual endpoint URL

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json', // Ensure the correct content type is set
        },
      );

      if (response.statusCode == 200) {
        print('Transaction deleted successfully: ${response.body}');
      } else if (response.statusCode == 422) {
        print('Validation Error: ${response.body}');
      } else {
        print('Failed to delete transaction: ${response.statusCode}, ${response.body}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }


  @override
  void initState()  {
    super.initState();
    populateState();
  }

  @override
  void dispose() {
    _accountEventListener?.cancel();
    _categoryEventListener?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(!_initialised) return Center(
      child: CircularProgressIndicator(),
    ) ;

    return
      Scaffold(
          appBar: AppBar(
            title: Text("${widget.transaction ==null? "New": "Edit"} Transaction", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            actions: [
              _id!=null ? IconButton(
                  onPressed: (){
                    ConfirmModal.showConfirmDialog(context, title: "Are you sure?", content: const Text("After deleting payment can't be recovered."),
                        onConfirm: (){
                          deleteTransaction(_id!).then((value) {
                            // globalEvent.emit("payment_update");
                            Navigator.pop(context);
                            Navigator.pop(context);
                          });
                        },
                        onCancel: (){
                          Navigator.pop(context);
                        }
                    );

                  }, icon: const Icon(Icons.delete, size: 20,), color: ThemeColors.error
              ) : const SizedBox()
            ],
          ),
          body: Column(
            children: [
              Expanded(
                  child:SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 25,),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: const EdgeInsets.only(left: 15, right: 15, bottom:20),
                                child: Wrap(
                                  spacing: 10,
                                  children: [
                                    AppButton(
                                      onPressed: (){
                                        setState(() {
                                          _type = TransactionType.credit;
                                        });
                                      },
                                      label: "Income",
                                      color: Theme.of(context).colorScheme.primary,
                                      type: _type == TransactionType.credit? AppButtonType.filled: AppButtonType.outlined,
                                      borderRadius: BorderRadius.circular(45),
                                    ),

                                    AppButton(
                                      onPressed: (){
                                        setState(() {
                                          _type = TransactionType.debit;
                                        });
                                      },
                                      label: "Expense",
                                      color: Theme.of(context).colorScheme.primary,
                                      type: _type == TransactionType.debit? AppButtonType.filled: AppButtonType.outlined,
                                      borderRadius: BorderRadius.circular(45),
                                    )
                                  ],
                                )
                            ),

                            Container(
                              margin: const EdgeInsets.only(left: 15, right: 15, bottom:25),
                              child: TextFormField(
                                decoration:  InputDecoration(
                                    filled: true,
                                    hintText: "Title",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15)
                                ),
                                initialValue: _title,
                                onChanged: (text){
                                  setState(() {
                                    _title = text;
                                  });
                                },
                              ),
                            ),

                            Container(
                              margin: const EdgeInsets.only(left: 15, right: 15, bottom:25),
                              child: TextFormField(
                                maxLines: null,
                                decoration: InputDecoration(
                                    filled: true,
                                    hintText: "Description",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15)
                                ),
                                initialValue: _description,
                                onChanged: (text){
                                  setState(() {
                                    _description = text;
                                  });
                                },
                              ),
                            ),
                            Container(
                                margin: const EdgeInsets.only(left: 15, right: 15, bottom:25),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
                                  ],
                                  decoration: InputDecoration(
                                      filled: true,
                                      hintText: "0.0",
                                      prefixIcon: Padding(padding: const EdgeInsets.only(left: 15), child: CurrencyText(null)),
                                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15)
                                  ),
                                  initialValue: _amount == 0 ? "" : _amount.toString(),
                                  onChanged: (String text){
                                    setState(() {
                                      _amount = double.parse(text==""? "0":text);
                                    });
                                  },
                                )
                            ),

                            Container(
                                margin: const EdgeInsets.only(left: 15, right: 15, bottom:25),
                                child:   Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        child: InkWell(
                                            onTap: (){
                                              chooseDate(context);
                                            },
                                            child:Wrap(
                                              spacing: 10,
                                              children: [
                                                Icon(Icons.calendar_today, size: 18, color: Theme.of(context).colorScheme.primary,),
                                                Text(DateFormat("dd/MM/yyyy").format(_datetime ?? DateTime.now()))
                                              ],
                                            )
                                        )
                                    ),

                                    Expanded(
                                        child: InkWell(
                                            onTap: (){
                                              chooseTime(context);
                                            },
                                            child:Wrap(
                                              spacing: 10,
                                              children: [
                                                Icon(Icons.watch_later_outlined, size: 18, color: Theme.of(context).colorScheme.primary,),
                                                Text(DateFormat("hh:mm a").format(_datetime ?? DateTime.now()))
                                              ],
                                            )
                                        )
                                    ),
                                  ],
                                )
                            ),

                            Container(
                              padding: const EdgeInsets.only(left: 15, bottom: 15),
                              child: const Text("Select Account", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
                            ),
                            Container(
                              height: 70,
                              margin: const EdgeInsets.only(bottom: 25),
                              width: double.infinity,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(left: 10, right: 10,),
                                children:List.generate(_accounts.length +1, (index){
                                  if(index == 0){
                                    return Container(
                                      margin: const EdgeInsets.only(right: 5, left: 5),
                                      width: 190,
                                      child: MaterialButton(
                                          minWidth: double.infinity,
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(18),
                                              side: const BorderSide(
                                                  width: 1.5,
                                                  color: Colors.transparent
                                              )
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                          elevation: 0,
                                          focusElevation: 0,
                                          hoverElevation: 0,
                                          highlightElevation: 0,
                                          disabledElevation: 0,
                                          onPressed: (){
                                            showDialog(context: context, builder: (builder)=> AccountForm(userId: widget.userId,
                                              onSave: () {
                                                loadAccounts(); // Refresh accounts list after saving
                                              },));
                                          },
                                          child:  SizedBox(
                                            width: double.infinity,
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                                  child: const Icon(Icons.add, color: Colors.white),
                                                ),
                                                const SizedBox(width: 10,),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text("New", style: Theme.of(context).textTheme.bodyMedium?.apply(fontWeightDelta: 2)),
                                                    Text("Create account", style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis,),
                                                  ],
                                                )
                                              ],
                                            ),
                                          )
                                      ),
                                    );
                                  }
                                  Account account = _accounts[index-1];
                                  return Container(
                                      margin: const EdgeInsets.only(right: 5, left: 5),
                                      child: ConstrainedBox(
                                          constraints:   const BoxConstraints(minWidth: 0,),
                                          child:  IntrinsicWidth(
                                            child:MaterialButton(
                                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(18),
                                                    side: BorderSide(
                                                        width: 1.5,
                                                        color: _account?.id == account.id ? Theme.of(context).colorScheme.primary : Colors.transparent
                                                    )
                                                ),
                                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                                elevation: 0,
                                                focusElevation: 0,
                                                hoverElevation: 0,
                                                highlightElevation: 0,
                                                disabledElevation: 0,
                                                onPressed: (){
                                                  setState(() {
                                                    _account = account;
                                                  });
                                                },
                                                child:  SizedBox(
                                                  width: double.infinity,
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundColor: Colors.blue.withOpacity(0.2),
                                                        child: Icon(Icons.account_box_outlined, color: Colors.blue.withOpacity(0.2)),
                                                      ),
                                                      const SizedBox(width: 10,),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Visibility(visible: account.accountName != null,child: Text(account.accountName ?? "", style: Theme.of(context).textTheme.bodyMedium?.apply(fontWeightDelta: 2)),),
                                                          Text(account.bankName ?? "", style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis,),
                                                        ],
                                                      )

                                                    ],
                                                  ),
                                                )
                                            ),
                                          )
                                      )
                                  );
                                }),
                              ),
                            ),

                            Visibility(
                              visible: _type != TransactionType.credit,
                              child: Container(
                                padding: const EdgeInsets.only(left: 15, bottom: 15),
                                child: const Text("Select Category", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
                              ),
                            ),
                            Visibility(
                              visible: _type != TransactionType.credit,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 25, left: 15, right: 15),
                                width: double.infinity,
                                child: Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: List.generate(_categories.length + 1, (index){
                                      if(_categories.length == index){
                                        return ConstrainedBox(
                                            constraints:   const BoxConstraints(minWidth: 0,),
                                            child:  IntrinsicWidth(
                                              child:MaterialButton(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(15),
                                                      side: const BorderSide(
                                                          width: 1.5,
                                                          color: Colors.transparent
                                                      )
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                                                  elevation: 0,
                                                  focusElevation: 0,
                                                  hoverElevation: 0,
                                                  highlightElevation: 0,
                                                  disabledElevation: 0,
                                                  onPressed: (){
                                                    showDialog(context: context, builder: (builder)=> CategoryForm(userId: widget.userId,
                                                      onSave: () {
                                                        loadCategories(); // Refresh accounts list after saving
                                                      },));
                                                  },
                                                  child:  SizedBox(
                                                    width: double.infinity,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.add, color: Theme.of(context).colorScheme.primary,),
                                                        const SizedBox(width: 10,),
                                                        Text("New Category", style: Theme.of(context).textTheme.bodyMedium),
                                                      ],
                                                    ),
                                                  )
                                              ),
                                            )
                                        );
                                      }
                                      Category category = _categories[index];
                                      return ConstrainedBox(
                                          constraints:   const BoxConstraints(minWidth: 0,),
                                          child:  IntrinsicWidth(
                                              child:MaterialButton(
                                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(15),
                                                      side: BorderSide(
                                                          width: 1.5,
                                                          color: _category?.id == category.id ? Theme.of(context).colorScheme.primary : Colors.transparent
                                                      )
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                                                  elevation: 0,
                                                  focusElevation: 0,
                                                  hoverElevation: 0,
                                                  highlightElevation: 0,
                                                  disabledElevation: 0,
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  onPressed: (){
                                                    setState(() {
                                                      _category = category;
                                                    });
                                                  },
                                                  onLongPress: (){
                                                    showDialog(context: context, builder: (builder)=>CategoryForm(category: category,));
                                                  },
                                                  child:  SizedBox(
                                                    width: double.infinity,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.category_outlined, color: Colors.pink),
                                                        const SizedBox(width: 10,),
                                                        Text(category.name, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis,),
                                                      ],
                                                    ),
                                                  )
                                              )
                                          )
                                      );

                                    })

                                ),
                              ),
                            )
                          ],
                        ) ,
                      )
                  )
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: AppButton(
                  label: "Save Transaction",
                  height: 50,
                  labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  isFullWidth: true,
                  onPressed: _amount! > 0 && _account!=null  ? (){
                    if((_type == TransactionType.debit && _category!=null) || _type == TransactionType.credit) {
                      handleSaveTransaction(context);
                    }
                  } : null,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            ],
          )
      );
  }
}