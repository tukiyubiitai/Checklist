import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Tasks extends Table {
  TextColumn get name => text()();

  BoolColumn get isMemorized => boolean().withDefault(Constant(false))();

  @override
  Set<Column> get primaryKey => {name};
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tasks.db'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(tables: [Tasks])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future insertTask(Task task) => into(tasks)
      .insert(task); // insertTaskメソッドは、Taskオブジェクトをデータベースに挿入するための非同期関数です。

  Future<List<Task>> get allTasks => select(tasks)
      .get(); //　allTasksメソッドは、データベース内のすべてのTaskオブジェクトを取得するための非同期関数です。

  Future updateTask(Task task) => update(tasks)
      .replace(task); //updateTaskメソッドは、指定したTaskオブジェクトをデータベース内で更新するための非同期関数です。

  Future deleteTask(Task task) =>
      (delete(tasks)..where((table) => table.name.equals(task.name)))
          .go(); //deleteTaskメソッドは、指定したTaskオブジェクトをデータベースから削除するための非同期関数です。

  Future deleteAllTasks() => delete(tasks).go();

  Future<List<Task>> getCheckedTasks() =>
      (select(tasks)..where((table) => table.isMemorized.equals(true))).get();

  //Read 暗記済みが下になるようにソート
  Future<List<Task>> get allWordsSortedDescending => (select(tasks)
        ..orderBy([(table) => OrderingTerm(expression: table.isMemorized)]))
      .get();

  // Read 暗記済みが上になるようにソート
  Future<List<Task>> get allWordsSortedAscending => (select(tasks)
        ..orderBy([
          (table) => OrderingTerm(
              expression: table.isMemorized, mode: OrderingMode.desc)
        ]))
      .get();

  // 全てのリストのチェックを外すための変数
  Future<void> uncheckAllTasks() async {
    await (update(tasks)..where((table) => table.isMemorized.equals(true)))
        .write(const TasksCompanion(isMemorized: Value(false)));
  }
}
