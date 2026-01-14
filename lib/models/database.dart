import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_uas/models/category.dart';
import 'package:project_uas/models/transaction.dart';
import 'package:project_uas/models/transaction_with_catagory.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Categories, Transactions])
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());
  @override
  int get schemaVersion => 1;

  //crud
  // kueri Category untuk mendapatkan semua data category berdasarkan type
  Future<List<Category>> getAllCategoriesRepo(int type) async {
    return (select(categories)..where((tbl) => tbl.type.equals(type))).get();
  }

  Future<int> updateCategoryRepo(int id, String name) async {
    return await (update(categories)..where((tbl) => tbl.id.equals(id))).write(
      CategoriesCompanion(name: Value(name)),
    );
  }

  Future deleteCategoryRepo(int id) async {
    return await (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }

  Stream<List<TransactionWithCategory>> getTransactionByDateRepo(
    DateTime date,
  ) {
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id)),
    ])..where(transactions.transactionDate.equals(date)));
    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          row.readTable(transactions),
          row.readTable(categories),
        );
      }).toList();
    });
  }
  Future deleteTransactionRepo(int id) async {
    return await (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<int> updateTransactionRepo(int id, int amount, int categoryId, DateTime transactiondate, String nameDetail) async {
    return await (update(transactions)..where((tbl) => tbl.id.equals(id))).write(
      TransactionsCompanion(
        amount: Value(amount),
        category_id: Value(categoryId),
        transactionDate: Value(transactiondate),
        name: Value(nameDetail),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
