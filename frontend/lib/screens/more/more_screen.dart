import 'package:currency_picker/currency_picker.dart';
import 'package:finbot/screens/more/CaptureReceiptImage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../bloc/cubit/app_cubit.dart';
import '../../helpers/color.helper.dart';
import '../../helpers/db.helper.dart';
import '../../widgets/buttons/button.dart';
import '../../widgets/dialog/confirm.modal.dart';
import '../../widgets/dialog/loading_dialog.dart';
class MoreScreen extends StatefulWidget {
  final int? userId;

  const MoreScreen(this.userId, {super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("More", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
        ),
        body: ListView(
          children: [
            ListTile(
              dense: true,
              onTap: (){
                showDialog(context: context, builder: (context){
                  TextEditingController controller = TextEditingController(text: context.read<AppCubit>().state.userName);
                  return AlertDialog(
                    title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //need to use modify user name api
                        Text("What should we call you?", style: theme.textTheme.bodyLarge!.apply(color: ColorHelper.darken(theme.textTheme.bodyLarge!.color!), fontWeightDelta: 1),),
                        const SizedBox(height: 15,),
                        TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                              label: const Text("Name"),
                              hintText: "Enter your name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15)
                          ),
                        )
                      ],
                    ),
                    actions: [
                      Row(
                        children: [
                          Expanded(
                              child: AppButton(
                                onPressed: (){
                                  if(controller.text.isEmpty){
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter name")));
                                  } else {
                                    context.read<AppCubit>().updateUserDetails(controller.text, widget.userId ?? 0);
                                    Navigator.of(context).pop();
                                  }
                                },
                                height: 45,
                                label: "Save",
                              )
                          )
                        ],
                      )
                    ],
                  );
                });
              },
              leading: const CircleAvatar(
                  child: Icon(Symbols.person)
              ),
              title:  Text('Change name', style: Theme.of(context).textTheme.bodyMedium?.merge(const TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
              subtitle: BlocBuilder<AppCubit, AppState>(builder: (context, state) {
                return Text(state.userName!,style: Theme.of(context).textTheme.bodySmall?.apply(color: Colors.grey, overflow: TextOverflow.ellipsis));
              }),
            ),
            ListTile(
              dense: true,
              onTap: (){
                showCurrencyPicker(context: context, onSelect: (Currency currency){
                  context.read<AppCubit>().updateCurrency(currency.code);
                });
              },
              leading: BlocBuilder<AppCubit, AppState>(builder: (context, state) {
                Currency? currency = CurrencyService().findByCode(state.currency!);
                return CircleAvatar(
                    child: Text(currency!.symbol)
                );
              }),
              title:  Text('Currency', style: Theme.of(context).textTheme.bodyMedium?.merge(const TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
              subtitle: BlocBuilder<AppCubit, AppState>(builder: (context, state) {
                Currency? currency = CurrencyService().findByCode(state.currency!);
                return Text(currency!.name, style: Theme.of(context).textTheme.bodySmall?.apply(color: Colors.grey, overflow: TextOverflow.ellipsis));
              }),
            ),
            ListTile(
              dense: true,
              onTap:() async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImageCapturePage()),
                );
              },
              leading: const CircleAvatar(
                  child: Icon(Symbols.download,)
              ),
              title:  Text('Capture receipt', style: Theme.of(context).textTheme.bodyMedium?.merge(const TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
              subtitle:  Text("Take receipt image",style: Theme.of(context).textTheme.bodySmall?.apply(color: Colors.grey, overflow: TextOverflow.ellipsis)),
            ),
            ListTile(
              dense: true,
              onTap:() async {
                ConfirmModal.showConfirmDialog(
                    context, title: "Are you sure?",
                    content: const Text("want to export all the data to a file"),
                    onConfirm: ()async{
                      Navigator.of(context).pop();
                      LoadingModal.showLoadingDialog(context, content: const Text("Exporting data please wait"));
                      await export(widget.userId ?? 0).then((value){
                        ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("File has been saved in $value")));
                      }).catchError((err){
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went wrong while exporting data")));
                      }).whenComplete((){
                        Navigator.of(context).pop();
                      });
                    },
                    onCancel: (){
                      Navigator.of(context).pop();
                    }
                );
              },
              leading: const CircleAvatar(
                  child: Icon(Symbols.download,)
              ),
              title:  Text('Export', style: Theme.of(context).textTheme.bodyMedium?.merge(const TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
              subtitle:  Text("Export to file",style: Theme.of(context).textTheme.bodySmall?.apply(color: Colors.grey, overflow: TextOverflow.ellipsis)),
             ),
            ListTile(
              dense: true,
              onTap:() async {
                ConfirmModal.showConfirmDialog(
                    context, title: "Are you sure?",
                    content: const Text("You want to log out"),
                    onConfirm: ()async{
                      // Navigator.of(context).pop();
                      // LoadingModal.showLoadingDialog(context, content: const Text("Exporting data please wait"));
                      // await export(widget.userId ?? 0).then((value){
                      //   ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("File has been saved in $value")));
                      // }).catchError((err){
                      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went wrong while exporting data")));
                      // }).whenComplete((){
                      //   Navigator.of(context).pop();
                      // });
                    },
                    onCancel: (){
                      Navigator.of(context).pop();
                    }
                );
              },
              leading: const CircleAvatar(
                  child: Icon(Symbols.logout,)
              ),
              title:  Text('Log out', style: Theme.of(context).textTheme.bodyMedium?.merge(const TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
            ),
          ],
        )
    );
  }
}
