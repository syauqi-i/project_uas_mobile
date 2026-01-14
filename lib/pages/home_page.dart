import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_uas/models/database.dart';
import 'package:project_uas/models/transaction_with_catagory.dart';
import 'package:project_uas/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({super.key, required this.selectedDate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDatabase database = AppDatabase();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //income dan outcome(expense) start
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 16.0, right: 16.0),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          child: Icon(
                            Icons.download_rounded,
                            color: const Color.fromARGB(255, 11, 169, 45),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Income",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Rp 5.00.000",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          child: Icon(
                            Icons.upload,
                            color: const Color.fromARGB(255, 224, 5, 9),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Expense",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Rp 1.000.000",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 42, 41, 41),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            //income dan outcome(expense) end

            //text Transakasi start
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "Transactions",
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              //text Transakasi end
            ),
            StreamBuilder<List<TransactionWithCategory>>(
              stream: database.getTransactionByDateRepo(widget.selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Card(
                              elevation: 10,
                              child: ListTile(
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () async {
                                        await database.deleteTransactionRepo(
                                          snapshot.data![index].transaction.id,
                                        );
                                        setState(() {});
                                      },
                                    ),
                                    SizedBox(width: 10),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionPage(
                                                  transactionWithCategory:
                                                      snapshot.data![index],
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                title: Text(
                                  "Rp." +
                                      snapshot.data![index].transaction.amount
                                          .toString(),
                                ),
                                subtitle: Text(
                                  snapshot.data![index].category.name +
                                      "(" +
                                      snapshot.data![index].transaction.name +
                                      ")",
                                ),
                                leading: Container(
                                  child:
                                      (snapshot.data![index].category.type == 2)
                                      ? Icon(
                                          Icons.upload,
                                          color: const Color.fromARGB(
                                            255,
                                            224,
                                            5,
                                            9,
                                          ),
                                        )
                                      : Icon(
                                          Icons.download,
                                          color: const Color.fromARGB(
                                            255,
                                            10,
                                            180,
                                            10,
                                          ),
                                        ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(child: Text("Data Kosong"));
                    }
                  } else {
                    return Center(child: Text("No Transactions"));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
