import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:project_uas/models/database.dart';
import 'package:project_uas/models/transaction_with_catagory.dart';

class TransactionPage extends StatefulWidget {
  final TransactionWithCategory? transactionWithCategory;
  const TransactionPage({super.key, required this.transactionWithCategory});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late int type;
  final AppDatabase database = AppDatabase();
  bool isExpense = true;
  final List<String> list = ['makan dan jajan', 'transportasi', 'nonton film'];
  late String dropdownValue = list.first;
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  Category? selectedCategory;

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoriesRepo(type);
  }

  Future updateCategory(
    int transactionId,
    int amount,
    int categoryId,
    DateTime transactionDate,
    String nameDetail,
  ) async {
    await database.updateTransactionRepo(
      transactionId,
      amount,
      categoryId,
      transactionDate,
      nameDetail,
    );
  }

  Future insert(
    int amount,
    DateTime date,
    String nameDetail,
    int categoryId,
  ) async {
    //insert transaction ke database
    DateTime now = DateTime.now();
    final row = await database
        .into(database.transactions)
        .insertReturning(
          TransactionsCompanion.insert(
            amount: amount,
            transactionDate: date,
            name: nameDetail,
            category_id: categoryId,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  @override
  void initState() {
    if (widget.transactionWithCategory != null) {
      updateTransactionView(widget.transactionWithCategory!);
    } else {
      type = 2;
    }
    // TODO: implement initState
    super.initState();
  }

  void updateTransactionView(TransactionWithCategory transactionWithCategory) {
    amountController.text = transactionWithCategory.transaction.amount
        .toString();
    detailController.text = transactionWithCategory.transaction.name;
    dateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(transactionWithCategory.transaction.transactionDate);
    type = transactionWithCategory.category.type;
    isExpense = (type == 2) ? true : false;
    selectedCategory = transactionWithCategory.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transaction"),
        backgroundColor: const Color.fromRGBO(236, 118, 150, 1),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Switch(
                      value: isExpense,
                      onChanged: (bool value) {
                        setState(() {
                          isExpense = value;
                          type = isExpense ? 2 : 1;
                          selectedCategory = null;
                        });
                      },
                      inactiveTrackColor: Colors.green[200],
                      inactiveThumbColor: Colors.green[400],
                      activeThumbColor: Colors.red,
                    ),
                    Text(
                      (isExpense ? "Expense" : "Income"),
                      style: GoogleFonts.montserrat(fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "Amount",
                  ),
                ),
              ),
              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Category",
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
              ),
              FutureBuilder<List<Category>>(
                future: getAllCategory(type),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      selectedCategory = (selectedCategory == null)
                          ? snapshot.data!.first
                          : selectedCategory;
                      print('apanih' + snapshot.toString());
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropdownButton<Category>(
                          value: (selectedCategory == null)
                              ? snapshot.data!.first
                              : selectedCategory,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_downward),
                          items: snapshot.data!.map((Category item) {
                            return DropdownMenuItem<Category>(
                              value: item,
                              child: Text(item.name),
                            );
                          }).toList(),
                          onChanged: (Category? value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                        ),
                      );
                    } else {
                      return const Center(child: Text("Data Kosong Woii"));
                    }
                  }

                  return const Center(child: Text("Gaonok Data Woii"));
                },
              ),

              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  readOnly: true,
                  controller: dateController,
                  decoration: InputDecoration(labelText: "Enter Date"),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      String formattedDate = DateFormat(
                        'yyyy-MM-dd',
                      ).format(pickedDate);

                      dateController.text = formattedDate;
                      print(formattedDate);
                    } else {
                      print("Date is not selected");
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: detailController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "Detail",
                  ),
                ),
              ),
              SizedBox(height: 25),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(236, 118, 150, 1),
                  ),
                  onPressed: () {
                    (widget.transactionWithCategory == null)
                        ? insert(
                            int.parse(amountController.text),
                            DateTime.parse(dateController.text),
                            detailController.text,
                            selectedCategory!.id,
                          )
                        : updateCategory(
                            widget.transactionWithCategory!.transaction.id,
                            int.parse(amountController.text),
                            selectedCategory!.id,
                            DateTime.parse(dateController.text),
                            detailController.text,
                          );
                    setState(() {});
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    "Save",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
