import 'dart:convert';
import 'dart:io';

import 'package:currency_picker/currency_picker.dart';
import 'package:finbot/screens/main.screen.dart';
import 'package:finbot/screens/more/CaptureReceiptImage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/cubit/app_cubit.dart';
import '../../helpers/color.helper.dart';
import '../../helpers/db.helper.dart';
import '../../models/Account.dart';
import '../../models/category.model.dart';
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

  // Modified getExternalDocumentPath function
  Future<String?> getExternalDocumentPath() async {
    // Request storage permissions
    bool permissionGranted = await _requestPermissions();
    if (!permissionGranted) {
      // Handle the case when permission is not granted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Storage permission is required to export data.")),
      );
      return null;
    }

    Directory? directory;
    if (Platform.isAndroid) {
      // Retrieve the Downloads directory
      List<Directory>? dirs =
      await getExternalStorageDirectories(type: StorageDirectory.downloads);
      if (dirs != null && dirs.isNotEmpty) {
        directory = dirs.first;
      } else {
        // Fallback to a default path if the Downloads directory is not found
        directory = Directory("/storage/emulated/0/Download");
      }
    } else {
      // For iOS, use the application documents directory
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory != null) {
      // Ensure the directory exists
      await directory.create(recursive: true);
      return directory.path;
    }

    return null;
  }

  // Helper function to request storage permissions
  Future<bool> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  // Modified export function
  Future<String?> export(int userId) async {
    try {
      List<Account> accounts = await loadAccount(userId);
      List<Category> categories = await loadCategory(userId);

      Map<String, dynamic> data = {
        "accounts": accounts.map((e) => e.toJson()).toList(),
        "categories": categories.map((e) => e.toJson()).toList(),
        // Add other data as needed
      };

      final path = await getExternalDocumentPath();
      if (path == null) {
        throw Exception("Storage permission not granted or path not found.");
      }

      String name = "finbot-backup-${DateTime.now().millisecondsSinceEpoch}.json";
      File file = File('$path/$name');
      await file.writeAsString(jsonEncode(data));
      return file.path;
    } catch (e) {
      throw Exception("Failed to export data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          leading: null,
          title: const Text(
            "More",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        body: ListView(
          children: [
            ListTile(
              dense: true,
              onTap: () {
                showDialog(context: context, builder: (context) {
                  TextEditingController controller = TextEditingController(
                      text: context.read<AppCubit>().state.userName);
                  return AlertDialog(
                    title: const Text(
                      "Profile",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Need to use modify user name API
                        Text(
                          "What should we call you?",
                          style: theme.textTheme.bodyLarge!.apply(
                              color:
                              ColorHelper.darken(theme.textTheme.bodyLarge!.color!),
                              fontWeightDelta: 1),
                        ),
                        const SizedBox(height: 15,),
                        TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                              label: const Text("Name"),
                              hintText: "Enter your name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 15)
                          ),
                        )
                      ],
                    ),
                    actions: [
                      Row(
                        children: [
                          Expanded(
                              child: AppButton(
                                onPressed: () {
                                  if (controller.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Please enter name")));
                                  } else {
                                    context.read<AppCubit>().updateUserDetails(
                                        controller.text, widget.userId ?? 0);
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
              title: Text(
                'Change name',
                style: Theme.of(context).textTheme.bodyMedium?.merge(
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
              ),
              subtitle: BlocBuilder<AppCubit, AppState>(builder: (context, state) {
                return Text(
                  state.userName ?? "",
                  style: Theme.of(context).textTheme.bodySmall?.apply(
                      color: Colors.grey, overflow: TextOverflow.ellipsis),
                );
              }),
            ),
            ListTile(
              dense: true,
              onTap: () {
                showCurrencyPicker(
                  context: context,
                  onSelect: (Currency currency) {
                    context.read<AppCubit>().updateCurrency(currency.code);
                  },
                );
              },
              leading: BlocBuilder<AppCubit, AppState>(builder: (context, state) {
                Currency? currency = CurrencyService().findByCode(state.currency!);
                return CircleAvatar(
                    child: Text(currency?.symbol ?? "")
                );
              }),
              title: Text(
                'Currency',
                style: Theme.of(context).textTheme.bodyMedium?.merge(
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
              ),
              subtitle: BlocBuilder<AppCubit, AppState>(builder: (context, state) {
                Currency? currency = CurrencyService().findByCode(state.currency!);
                return Text(
                  currency?.name ?? "",
                  style: Theme.of(context).textTheme.bodySmall?.apply(
                      color: Colors.grey, overflow: TextOverflow.ellipsis),
                );
              }),
            ),
            ListTile(
              dense: true,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ImageCapturePage(userId: widget.userId,)),
                );
              },
              leading: const CircleAvatar(
                  child: Icon(Symbols.download,)
              ),
              title: Text(
                'Capture receipt',
                style: Theme.of(context).textTheme.bodyMedium?.merge(
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
              ),
              subtitle: Text(
                "Take receipt image",
                style: Theme.of(context).textTheme.bodySmall?.apply(
                    color: Colors.grey, overflow: TextOverflow.ellipsis),
              ),
            ),
            ListTile(
              dense: true,
              onTap: () async {
                ConfirmModal.showConfirmDialog(
                    context,
                    title: "Are you sure?",
                    content: const Text("want to export all the data to a file"),
                    onConfirm: () async {
                      Navigator.of(context).pop();
                      LoadingModal.showLoadingDialog(context, content: const Text("Exporting data please wait"));
                      await export(widget.userId ?? 0).then((value) {
                        if (value != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("File has been saved in $value")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to save the file.")));
                        }
                      }).catchError((err) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Something went wrong while exporting data")));
                      }).whenComplete(() {
                        Navigator.of(context).pop();
                      });
                    },
                    onCancel: () {
                      Navigator.of(context).pop();
                    }
                );
              },
              leading: const CircleAvatar(
                  child: Icon(Symbols.download,)
              ),
              title: Text(
                'Export',
                style: Theme.of(context).textTheme.bodyMedium?.merge(
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
              ),
              subtitle: Text(
                "Export to file",
                style: Theme.of(context).textTheme.bodySmall?.apply(
                    color: Colors.grey, overflow: TextOverflow.ellipsis),
              ),
            ),
            ListTile(
              dense: true,
              onTap: () async {
                ConfirmModal.showConfirmDialog(
                  context,
                  title: "Are you sure?",
                  content: const Text("You want to log out"),
                  onConfirm: () async {
                    final String apiUrl = 'https://finbot-fastapi-rc4376baha-ue.a.run.app/auth/logout'; // Set your API URL
                    String? token = await context.read<AppCubit>().getAccessToken();
                    print(token);

                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Center(child: CircularProgressIndicator());
                      },
                    );

                    try {
                      // Perform the logout API call without the body
                      final response = await http.post(
                        Uri.parse(apiUrl),
                        headers: {
                          'Authorization': 'Bearer $token',
                        },
                      );

                      final data = jsonDecode(response.body);
                      Navigator.of(context).pop(); // Dismiss loading indicator

                      if (data['isSuccess'] == true) {
                        context.read<AppCubit>().resetAccessToken();

                        // Navigate to MainScreen and remove all previous routes
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const MainScreen()),
                              (Route<dynamic> route) => false,
                        );

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Logout Successful"),
                              content: Text("You have been logged out successfully."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // Show error message in a dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Logout Failed"),
                              content: Text(data['msg'] ?? 'An error occurred during logout.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    } catch (e) {
                      Navigator.of(context).pop(); // Dismiss loading indicator
                      // Show error dialog for exceptions
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Error"),
                            content: Text("An error occurred. Please try again."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },

                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                );
              },
              leading: const CircleAvatar(
                child: Icon(Icons.logout),
              ),
              title: Text(
                'Log out',
                style: Theme.of(context).textTheme.bodyMedium?.merge(
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                ),
              ),
            ),
          ],
        )
    );
  }
}
