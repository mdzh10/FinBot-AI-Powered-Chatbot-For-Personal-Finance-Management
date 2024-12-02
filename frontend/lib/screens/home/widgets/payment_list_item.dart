import 'package:finbot/models/Transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/colors.dart';
import '../../../widgets/currency.dart';

class PaymentListItem extends StatelessWidget{
  final Transaction transaction;
  final VoidCallback onTap;
  const PaymentListItem({super.key, required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    bool isCredit = transaction.type == TransactionType.credit ;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      onTap: onTap,
      leading: Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.blue,
          ),
          child:  Icon(Icons.payments_rounded, size: 22, color: isCredit ? Colors.green :Colors.red,)
      ),
      title: Text(transaction.category?.name ?? "", style: Theme.of(context).textTheme.bodyMedium?.merge(const TextStyle(fontWeight: FontWeight.w500)),),
      subtitle: Text.rich(
        TextSpan(
            children: [
              TextSpan(text: (DateFormat("dd MMM yyyy, HH:mm").format(transaction.datetime ?? DateTime.now()))),
            ],
            style: Theme.of(context).textTheme.bodySmall?.apply(color: Colors.grey, overflow: TextOverflow.ellipsis)
        ),
      ),
      trailing: CurrencyText(
          isCredit? transaction.amount : -transaction.amount!,
          style: Theme.of(context).textTheme.bodyMedium?.apply(color: isCredit? ThemeColors.success:ThemeColors.error)
      ),
    ) ;
  }

}