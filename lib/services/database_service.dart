import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_model.dart';

class DatabaseService {
  static Database? _db;
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }
  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), "expense.db");

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            title TEXT,
            amount REAL,
            category TEXT,
            date TEXT,
            type TEXT
          )
        ''');
      },
    );
  }
  Future<bool> registerUser(
      String name,
      String email,
      String password,
      String image) async {

    final prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList("users") ?? [];

    email = email.trim().toLowerCase();
    password = password.trim();

    for (var u in users) {
      var user = jsonDecode(u);
      if (user["email"].toString().toLowerCase() == email) {
        return false;
      }
    }

    Map<String, dynamic> newUser = {
      "id": DateTime.now().millisecondsSinceEpoch,
      "name": name.trim(),
      "email": email,
      "password": password,
      "image": image,
    };

    users.add(jsonEncode(newUser));
    await prefs.setStringList("users", users);

    return true;
  }
  Future<Map<String, dynamic>?> loginUser(
      String email, String password) async {

    final prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList("users") ?? [];

    email = email.trim().toLowerCase();
    password = password.trim();

    for (var u in users) {
      var user = jsonDecode(u);

      if (user["email"].toString().toLowerCase() == email &&
          user["password"] == password) {

        await prefs.setString("loggedUser", jsonEncode(user));
        return user;
      }
    }

    return null;
  }
  Future<Map<String, dynamic>?> getLoggedUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString("loggedUser");

    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("loggedUser");
  }
  Future<void> updateProfileImage(int id, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList("users") ?? [];

    for (int i = 0; i < users.length; i++) {
      var user = jsonDecode(users[i]);

      if (user["id"] == id) {
        user["image"] = imagePath;
        users[i] = jsonEncode(user);
        await prefs.setString("loggedUser", jsonEncode(user));
        break;
      }
    }

    await prefs.setStringList("users", users);
  }
  Future<void> updateUserName(int id, String name) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList("users") ?? [];

    for (int i = 0; i < users.length; i++) {
      var user = jsonDecode(users[i]);

      if (user["id"] == id) {
        user["name"] = name;
        users[i] = jsonEncode(user);
        await prefs.setString("loggedUser", jsonEncode(user));
        break;
      }
    }

    await prefs.setStringList("users", users);
  }
  Future<void> updateUserPassword(int id, String password) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList("users") ?? [];

    for (int i = 0; i < users.length; i++) {
      var user = jsonDecode(users[i]);

      if (user["id"] == id) {
        user["password"] = password;
        users[i] = jsonEncode(user);
        await prefs.setString("loggedUser", jsonEncode(user));
        break;
      }
    }

    await prefs.setStringList("users", users);
  }
  Future<Map<String, dynamic>?> findEmailByName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList("users") ?? [];

    for (var u in users) {
      var user = jsonDecode(u);

      if (user["name"]
          .toString()
          .toLowerCase()
          .trim() ==
          name.toLowerCase().trim()) {
        return user;
      }
    }
    return null;
  }
  Future<int> resetPassword(String email, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList("users") ?? [];

    email = email.trim().toLowerCase();

    for (int i = 0; i < users.length; i++) {
      var user = jsonDecode(users[i]);

      if (user["email"].toString().toLowerCase() == email) {
        user["password"] = newPassword.trim();
        users[i] = jsonEncode(user);

        await prefs.setStringList("users", users);

        String? logged = prefs.getString("loggedUser");
        if (logged != null) {
          var loggedUser = jsonDecode(logged);
          if (loggedUser["email"]
              .toString()
              .toLowerCase() ==
              email) {
            await prefs.setString(
                "loggedUser", jsonEncode(user));
          }
        }

        return 1;
      }
    }

    return 0;
  }
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    final loggedUser = await getLoggedUser();

    return await db.insert("expenses", {
      ...expense.toMap(),
      "user_id": loggedUser!["id"],
    });
  }
  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final loggedUser = await getLoggedUser();

    var res = await db.query(
      "expenses",
      where: "user_id = ?",
      whereArgs: [loggedUser!["id"]],
      orderBy: "id DESC",
    );

    return res.map((e) => Expense.fromMap(e)).toList();
  }
  Future<int> deleteExpense(int id) async {
    final db = await database;
    final loggedUser = await getLoggedUser();

    return await db.delete(
      "expenses",
      where: "id = ? AND user_id = ?",
      whereArgs: [id, loggedUser!["id"]],
    );
  }
  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    final loggedUser = await getLoggedUser();

    return await db.update(
      "expenses",
      {
        "title": expense.title,
        "amount": expense.amount,
        "category": expense.category,
        "date": expense.date,
        "type": expense.type,
      },
      where: "id = ? AND user_id = ?",
      whereArgs: [expense.id, loggedUser!["id"]],
    );
  }
}
