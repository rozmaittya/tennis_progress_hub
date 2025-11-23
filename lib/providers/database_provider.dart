import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';

final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  final db = AppDatabase();
  await db.initDatabase();
  return db;
});