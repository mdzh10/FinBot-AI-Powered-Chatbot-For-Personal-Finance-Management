import 'dart:convert';

import 'package:events_emitter/events_emitter.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/Account.dart';
import '../../models/AccountResponseModel.dart';
import '../../theme/colors.dart';
import '../../widgets/currency.dart';
import '../../widgets/dialog/account_form.dialog.dart';
import '../../widgets/dialog/confirm.modal.dart';

maskAccount(String value, [int lastLength = 4]){
  if(value.length <4 ) return value;
  int length = value.length - lastLength;
  String generated = "";
  if(length > 0){
    generated+= value.substring(0, length).split("").map((e) => e==" "? " ": "X").join("");
  }
  generated += value.substring(length);
  return generated;
}
class AccountsScreen extends StatefulWidget {
  final int? userId;
  const AccountsScreen(this.userId, {super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  EventListener? _accountEventListener;
  List<Account> _accounts = [];
  AccountResponseModel? accountResponseModel;
  bool _isLoading = false;

  Future<void> deleteAccount(int accountId) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.delete(
      Uri.parse('http://192.168.160.192:8000/account/delete/' + accountId.toString()),
      headers: {"Content-Type": "application/json"},
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      loadData(widget.userId);
    } else {
      throw Exception("Failed to delete account");
    }
  }

  void loadData(int? userId) async {
    setState(() {
      _isLoading = true;
    });

    final String apiUrl = "http://192.168.160.192:8000/account/" + userId.toString();
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

  void _openAccountForm({Account? account}) {
    showDialog(
      context: context,
      builder: (context) => AccountForm(
        account: account,
        userId: widget.userId,
        onSave: () {
          loadData(widget.userId); // Refresh accounts list after saving
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadData(widget.userId);
  }

  @override
  void dispose() {
    _accountEventListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accounts", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            itemCount: _accounts.length,
            itemBuilder: (builder, index) {
              Account account = _accounts[index];
              GlobalKey accKey = GlobalKey();
              return Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.accountName ?? "---",
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                                ),
                                Text(
                                  account.bankName ?? "",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  account.accountNumber == null ? "---" : maskAccount(account.accountNumber.toString()),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: "Total Balance", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        CurrencyText(
                          account.balance ?? 0,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(text: "Income", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  CurrencyText(
                                    account.credit ?? 0,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ThemeColors.success),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(text: "Expense", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  CurrencyText(
                                    account.debit ?? 0,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ThemeColors.error),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      key: accKey,
                      onPressed: () {
                        final RenderBox renderBox = accKey.currentContext?.findRenderObject() as RenderBox;
                        final Size size = renderBox.size;
                        final Offset offset = renderBox.localToGlobal(Offset.zero);

                        showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(
                            offset.dx,
                            offset.dy + size.height,
                            offset.dx + size.width,
                            offset.dy + size.height,
                          ),
                          items: [
                            PopupMenuItem<String>(
                              value: '1',
                              child: const Text('Edit'),
                              onTap: () {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _openAccountForm(account: account);
                                });
                              },
                            ),
                            PopupMenuItem<String>(
                              value: '2',
                              child: const Text('Delete', style: TextStyle(color: ThemeColors.error)),
                              onTap: () {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  ConfirmModal.showConfirmDialog(
                                    context,
                                    title: "Are you sure?",
                                    content: const Text("All the payments will be deleted that belong to this account"),
                                    onConfirm: () async {
                                      Navigator.pop(context);
                                      await deleteAccount(account.id!);
                                      loadData(widget.userId); // Reload data after deletion
                                    },
                                    onCancel: () {
                                      Navigator.pop(context);
                                    },
                                  );
                                });
                              },
                            ),
                          ],
                        );
                      },
                      icon: const Icon(Icons.more_vert, size: 20),
                    ),
                  ),
                ],
              );
            },
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()), // Show loading indicator when `_isLoading` is true
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openAccountForm(); // Open account form for creating a new account
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
