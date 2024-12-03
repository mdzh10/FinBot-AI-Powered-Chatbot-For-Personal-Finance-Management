import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/Account.dart';
import '../../models/AccountResponseModel.dart';
import '../../models/category.model.dart';
import '../../models/CategoryResponseModel.dart';
import '../../models/TransactionForImage.dart';

class UploadImageScreen extends StatefulWidget {
  final List<TransactionForImage>? transactions;
  final int? userId;

  const UploadImageScreen({
    Key? key,
    required this.transactions,
    required this.userId,
  }) : super(key: key);

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  // Initialize as empty lists to avoid null issues
  List<Account> _accounts = [];
  List<Category> _categories = [];
  List<TransactionForImage> _transactions = [];
  int? selectedAccountId;
  int? selectedCategoryId;
  bool _isLoading = false;
  bool _isSaving = false; // To manage saving state
  AccountResponseModel? accountResponseModel;
  CategoryResponse? categoryResponse;

  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  void initState() {
    super.initState();
    _transactions = widget.transactions ?? [];
    // Load both accounts and categories simultaneously
    loadData();
  }

  // Function to load both accounts and categories
  Future<void> loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use Future.wait to run both requests in parallel
      await Future.wait([loadAccounts(), loadCategories()]);

      // Verify unique IDs after loading
      verifyUniqueIds(_accounts, _categories);

      // Initialize transactions with valid IDs
      initializeTransactions();
    } catch (e) {
      // Handle errors appropriately in your app
      print("Error loading data: $e");
      // Show a Snackbar to inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading data: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load accounts from API
  Future<void> loadAccounts() async {
    final String apiUrl =
        "https://finbot-fastapi-rc4376baha-ue.a.run.app/account/${widget.userId}";
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      accountResponseModel = AccountResponseModel.fromJson(data);

      setState(() {
        _accounts = accountResponseModel?.accounts ?? [];
        if (_accounts.isNotEmpty) {
          // Select the first valid account (id > 0)
          final validAccount = _accounts.firstWhere(
                (account) => account.id! > 0,
            orElse: () => _accounts.first,
          );
          selectedAccountId = validAccount.id;
        } else {
          selectedAccountId = null;
        }
      });
    } else {
      throw Exception('Failed to load accounts');
    }
  }

  // Load categories from API
  Future<void> loadCategories() async {
    final String apiUrl =
        "https://finbot-fastapi-rc4376baha-ue.a.run.app/category/${widget.userId}";
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      categoryResponse = CategoryResponse.fromJson(data);

      setState(() {
        _categories = categoryResponse?.categories ?? [];
        if (_categories.isNotEmpty) {
          // Select the first valid category (id > 0)
          final validCategory = _categories.firstWhere(
                (category) => category.id! > 0,
            orElse: () => _categories.first,
          );
          selectedCategoryId = validCategory.id;
        } else {
          selectedCategoryId = null;
        }
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Initialize transactions with valid account_id and category_id
  void initializeTransactions() {
    for (var transaction in _transactions) {
      // Validate and set account_id
      if (!_accounts.any((account) => account.id == transaction.accountId)) {
        transaction.accountId = selectedAccountId;
      }

      // Validate and set category_id
      if (!_categories.any((category) => category.id == transaction.categoryId)) {
        transaction.categoryId = selectedCategoryId;
      }
    }
  }

  // Utility function to verify unique IDs
  void verifyUniqueIds(List<Account> accounts, List<Category> categories) {
    final accountIds = accounts.map((a) => a.id).toList();
    final categoryIds = categories.map((c) => c.id).toList();

    final uniqueAccountIds = accountIds.toSet();
    final uniqueCategoryIds = categoryIds.toSet();

    assert(uniqueAccountIds.length == accountIds.length,
    "Duplicate Account IDs found!");
    assert(uniqueCategoryIds.length == categoryIds.length,
    "Duplicate Category IDs found!");
  }

  // Function to convert transactions to JSON
  List<Map<String, dynamic>> _convertTransactionsToJson() {
    return _transactions.map((transaction) {
      return {
        "user_id": widget.userId ?? 0,
        "account_id": transaction.accountId, // No defaulting to 0
        "category_id": transaction.categoryId, // No defaulting to 0
        "title": transaction.title ?? "",
        "description": transaction.description ?? "",
        "amount": transaction.amount ?? 0,
        "type": transaction.type ?? "debit",
        "datetime": transaction.datetime != null
            ? transaction.datetime!.toIso8601String()
            : DateTime.now().toIso8601String(),
      };
    }).toList();
  }

  // Function to validate transactions
  bool _validateTransactions() {
    for (var transaction in _transactions) {
      print("Validating Transaction: ${transaction.title}");
      print("Account ID: ${transaction.accountId}");
      print("Category ID: ${transaction.categoryId}");
      print("Amount: ${transaction.amount}");
      print("Type: ${transaction.type}");
      print("Datetime: ${transaction.datetime}");

      if (transaction.accountId == null || transaction.accountId! <= 0) {
        print("Invalid Account ID for transaction: ${transaction.title}");
        return false;
      }

      if (transaction.categoryId == null || transaction.categoryId! <= 0) {
        print("Invalid Category ID for transaction: ${transaction.title}");
        return false;
      }

      if (transaction.title == null || transaction.title!.isEmpty) {
        print("Title is missing for transaction with ID: ${transaction.accountId}");
        return false;
      }

      if (transaction.amount == null || transaction.amount! <= 0) {
        print("Invalid Amount for transaction: ${transaction.title}");
        return false;
      }

      if (transaction.type == null || transaction.type!.isEmpty) {
        print("Type is missing for transaction: ${transaction.title}");
        return false;
      }

      if (transaction.datetime == null) {
        print("Datetime is missing for transaction: ${transaction.title}");
        return false;
      }
    }
    return true;
  }

  // Function to handle Save action
  Future<void> _saveTransactions() async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fix the errors in red before saving.")),
      );
      return;
    }

    // Additionally, validate transactions
    if (!_validateTransactions()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please ensure all transactions are complete.")),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Convert transactions to JSON
    List<Map<String, dynamic>> requestBody = _convertTransactionsToJson();
    print(requestBody);

    // Log the request body for debugging
    print('Request Body: ${json.encode(requestBody)}');

    // Additionally, print each transaction's details
    for (var transaction in _transactions) {
      print("Transaction: ${transaction.title}, Account ID: ${transaction.accountId}, Category ID: ${transaction.categoryId}");
    }

    final String apiUrl =
        "https://finbot-fastapi-rc4376baha-ue.a.run.app/transaction/add";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          // "Authorization": "Bearer YOUR_TOKEN_HERE", // Uncomment if authentication is required
        },
        body: json.encode(requestBody),
      );

      // Log the response for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        bool isSuccess = data["isSuccess"] ?? false;
        String message = data["msg"] ?? "Unknown response";

        if (isSuccess) {
          // Show success dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Success"),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to previous screen
                  },
                  child: Text("OK"),
                ),
              ],
            ),
          );
        } else {
          // Show failure message from backend
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } else {
        // Log non-200 responses
        print('Failed to save transactions. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save transactions. Please try again.")),
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      print("Error saving transactions: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving transactions: $e")),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Function to handle Recapture action
  void _recapture() {
    Navigator.of(context).pop(); // Simply pop the screen
  }

  @override
  Widget build(BuildContext context) {
    // Debugging: Print current state
    print("Accounts: $_accounts");
    print("Categories: $_categories");
    print("Transactions: $_transactions");

    return Scaffold(

      appBar: AppBar(
        title: Text("Upload Image", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        actions: [
          // Recapture Button
          IconButton(
            icon: Icon(Icons.arrow_back),
            tooltip: 'Recapture',
            onPressed: _recapture,
          ),
          // Save Button
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _isSaving ? null : _saveTransactions,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : (_transactions.isEmpty)
          ? Center(child: Text("No transactions found"))
          : Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];

                // Check if transaction's accountId exists in _accounts
                final accountExists = _accounts
                    .any((account) => account.id == transaction.accountId);
                // If not, fall back to selectedAccountId or null
                final currentAccountId =
                accountExists ? transaction.accountId : selectedAccountId;

                // Similarly for categoryId
                final categoryExists = _categories
                    .any((category) => category.id == transaction.categoryId);
                final currentCategoryId =
                categoryExists ? transaction.categoryId : selectedCategoryId;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Field
                          TextFormField(
                            initialValue: transaction.title ?? '',
                            decoration:
                            InputDecoration(labelText: 'Title'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                            onChanged: (newValue) {
                              setState(() {
                                transaction.title = newValue;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          // Amount Field
                          TextFormField(
                            initialValue:
                            transaction.amount.toString(),
                            decoration:
                            InputDecoration(labelText: 'Amount'),
                            keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an amount';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            onChanged: (newValue) {
                              setState(() {
                                transaction.amount =
                                    double.tryParse(newValue) ?? transaction.amount;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          // Description Field
                          TextFormField(
                            initialValue: transaction.description ?? '',
                            decoration:
                            InputDecoration(labelText: 'Description'),
                            onChanged: (newValue) {
                              setState(() {
                                transaction.description = newValue;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          // Dropdowns Row
                          Row(
                            children: [
                              // Account Dropdown
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: currentAccountId,
                                  items: _accounts.map((account) {
                                    return DropdownMenuItem<int>(
                                      value: account.id,
                                      child: Text(account.accountName ?? ""),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      transaction.accountId = newValue!;
                                    });
                                  },
                                  decoration:
                                  InputDecoration(labelText: 'Account'),
                                  validator: (value) {
                                    if (value == null || value <= 0) {
                                      return 'Please select a valid account';
                                    }
                                    return null;
                                  },
                                  hint: Text('Select Account'),
                                ),
                              ),
                              SizedBox(width: 10),
                              // Category Dropdown
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: currentCategoryId,
                                  items: _categories.map((category) {
                                    return DropdownMenuItem<int>(
                                      value: category.id,
                                      child: Text(category.name),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      transaction.categoryId = newValue!;
                                    });
                                  },
                                  decoration:
                                  InputDecoration(labelText: 'Category'),
                                  validator: (value) {
                                    if (value == null || value <= 0) {
                                      return 'Please select a valid category';
                                    }
                                    return null;
                                  },
                                  hint: Text('Select Category'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          // Type Dropdown
                          DropdownButtonFormField<String>(
                            value: transaction.type ?? "debit",
                            items: ["debit", "credit"].map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type.capitalize()), // Capitalize for better UI
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                transaction.type = newValue!;
                              });
                            },
                            decoration:
                            InputDecoration(labelText: 'Type'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a type';
                              }
                              if (!["debit", "credit"].contains(value)) {
                                return 'Invalid type selected';
                              }
                              return null;
                            },
                            hint: Text('Select Type'),
                          ),
                          SizedBox(height: 10),
                          // DateTime Picker
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Date: ${transaction.datetime != null ? transaction.datetime!.toLocal().toString().split(' ')[0] : 'Not set'}",
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: transaction.datetime ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      transaction.datetime = pickedDate;
                                    });
                                  }
                                },
                                child: Text("Select Date"),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

// Extension method to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    if (this.length == 0) return this;
    return this[0].toUpperCase() + this.substring(1);
  }
}
