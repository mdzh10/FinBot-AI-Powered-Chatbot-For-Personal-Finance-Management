import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../models/Account.dart';
import '../buttons/button.dart';


typedef Callback = void Function();

class AccountForm extends StatefulWidget {
  final Account? account;
  final Callback? onSave;
  final int? userId;

  const AccountForm({super.key, this.account, this.onSave, this.userId});

  @override
  State<StatefulWidget> createState() => _AccountForm();
}

class _AccountForm extends State<AccountForm> {
  Account? _account;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _account = Account(
        id: widget.account!.id,
        accountName: widget.account!.accountName,
        accountNumber: widget.account!.accountNumber,
        accountType: widget.account!.accountType,
        balance: widget.account!.balance,
        debit: widget.account?.debit ?? 0,
        credit: widget.account?.credit ?? 0,
      );
    } else {
      _account = Account(
        userId: widget.userId,
        accountName: "",
        accountNumber: 0,
        accountType: AccountType.bank,
        balance: 0,
      );
    }
  }

  void onSave(BuildContext context) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final url = _account?.id == null
          ? Uri.parse('http://192.168.224.192:8000/account/create')
          : Uri.parse('http://192.168.224.192:8000/account/update');

      final response = (_account?.id == null)
          ? await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(_account?.toJson()),
      )
          : await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(_account?.toJson()),
      );

      if (response.statusCode == 200) {
        widget.onSave?.call(); // Trigger callback to refresh accounts list
        Navigator.pop(context);
      } else {
        print("Failed to save account: ${response.body}");
        throw Exception("Failed to save account");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.account != null ? "Edit Account" : "New Account",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      scrollable: true,
      insetPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    initialValue: _account!.accountName,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'Account name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 15),
                    ),
                    onChanged: (String text) {
                      setState(() {
                        _account!.accountName = text;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Dropdown for Account Type
            DropdownButtonFormField<AccountType>(
              value: _account!.accountType,
              decoration: InputDecoration(
                labelText: 'Account Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              ),
              items: AccountType.values.map((AccountType type) {
                return DropdownMenuItem<AccountType>(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (AccountType? newType) {
                setState(() {
                  _account!.accountType = newType;
                });
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: _account!.accountName,
              decoration: InputDecoration(
                labelText: 'Holder name',
                hintText: 'Enter account holder name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              ),
              onChanged: (text) {
                setState(() {
                  _account!.accountName = text;
                });
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: _account!.accountNumber.toString(),
              decoration: InputDecoration(
                labelText: 'A/C Number',
                hintText: 'Enter account number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              ),
              onChanged: (text) {
                int? newAccNo = int.tryParse(text);
                setState(() {
                  _account!.accountNumber = newAccNo ?? 0;
                });
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: _account!.balance.toString(),
              decoration: InputDecoration(
                labelText: 'Balance',
                hintText: 'Enter balance',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              ),
              onChanged: (text) {
                double? newBalance = double.tryParse(text);
                setState(() {
                  _account!.balance = newBalance ?? 0;
                });
              },
            ),
            const SizedBox(height: 20),
            Visibility(
              visible: _account?.id != null,
              child: TextFormField(
                initialValue: _account!.credit.toString(),
                decoration: InputDecoration(
                  labelText: 'Credit',
                  hintText: 'Enter credit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                ),
                onChanged: (text) {
                  double? newCredit = double.tryParse(text);
                  setState(() {
                    _account!.credit = newCredit ?? 0;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            Visibility(
              visible: _account?.id != null,
              child: TextFormField(
                initialValue: _account!.debit.toString(),
                decoration: InputDecoration(
                  labelText: 'Debit',
                  hintText: 'Enter debit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                ),
                onChanged: (text) {
                  double? newDebit = double.tryParse(text);
                  setState(() {
                    _account!.debit = newDebit ?? 0;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            AppButton(
              height: 45,
              isFullWidth: true,
              onPressed: _isSaving ? null : () => onSave(context),
              color: Theme.of(context).colorScheme.primary,
              label: "Save",
            ),
            if (_isSaving)
              const Positioned(
                child: CircularProgressIndicator(color: Colors.white),
              ),
          ],
        ),
      ],
    );
  }

}
