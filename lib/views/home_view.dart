import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/expense_model.dart';
import 'add_expense.dart';
import 'edit_expense.dart';

class HomePage extends StatefulWidget {
  final Map user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {

  Map? user;

  List<Expense> allExpenses = [];
  List<Expense> filteredExpenses = [];

  double totalIncome = 0;
  double totalExpense = 0;
  double balance = 0;

  TextEditingController searchController = TextEditingController();

  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    user = widget.user;
    loadUser();
    loadData();

    controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    animation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  Future<void> loadUser() async {
    final updatedUser = await DatabaseService().getLoggedUser();
    setState(() {
      user = updatedUser;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    final data = await DatabaseService().getExpenses();

    double income = 0;
    double expense = 0;

    for (var e in data) {
      if (e.type.toLowerCase() == "income") {
        income += e.amount;
      } else {
        expense += e.amount;
      }
    }

    setState(() {
      allExpenses = data;
      filteredExpenses = data;
      totalIncome = income;
      totalExpense = expense;
      balance = income - expense;
    });
  }

  void deleteExpense(int id) async {
    await DatabaseService().deleteExpense(id);
    loadData();
  }

  void searchExpense(String query) {
    if (query.isEmpty) {
      setState(() => filteredExpenses = allExpenses);
      return;
    }

    final results = allExpenses.where((e) {
      return e.title.toLowerCase().contains(query.toLowerCase()) ||
          e.category.toLowerCase().contains(query.toLowerCase()) ||
          e.type.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() => filteredExpenses = results);
  }

  Widget premiumBalanceCard() {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        height: 190,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(.15),
                    Colors.white.withOpacity(.05),
                  ],
                ),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text("Total Balance",
                      style: TextStyle(color: Colors.white70)),

                  const SizedBox(height: 10),

                  Text("₹ ${balance.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _box("Income", totalIncome, Colors.greenAccent),
                      _box("Expense", totalExpense, Colors.redAccent),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _box(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 5),
        Text("₹${amount.toStringAsFixed(0)}",
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18))
      ],
    );
  }

  /// UPDATED EXPENSE TILE (tap to edit)
  Widget expenseTile(Expense e) {
    bool isIncome = e.type.toLowerCase() == "income";

    return GestureDetector(
      onTap: () async {
        var result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditExpensePage(expense: e),
          ),
        );

        if (result == true) {
          loadData();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xff111827),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isIncome
                    ? Colors.green.withOpacity(.15)
                    : Colors.red.withOpacity(.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.wallet,
                  color: isIncome
                      ? Colors.greenAccent
                      : Colors.redAccent),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                  Text("${e.category} • ${e.date}",
                      style: const TextStyle(color: Colors.white54)),
                ],
              ),
            ),

            Text(
              "${isIncome ? "+" : "-"} ₹${e.amount}",
              style: TextStyle(
                  color: isIncome
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B0F1A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 65,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Text(
              "Welcome ${user?['name'] ?? ''} 👋",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            CircleAvatar(
              radius: 20,
              backgroundImage:
              user?['image'] != null && user?['image'] != ""
                  ? FileImage(File(user!['image']))
                  : null,
              child: user?['image'] == null || user?['image'] == ""
                  ? const Icon(Icons.person)
                  : null,
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: searchController,
                  onChanged: searchExpense,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search title, category, income/expense...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon:
                    const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xff111827),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              premiumBalanceCard(),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredExpenses.length,
                itemBuilder: (c, i) => expenseTile(filteredExpenses[i]),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff6D5DF6),
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AddExpensePage()),
          );
          if (result == true) loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}