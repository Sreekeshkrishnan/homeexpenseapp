import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../models/expense_model.dart';
import '../services/database_service.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {

  final titleController = TextEditingController();
  final amountController = TextEditingController();

  String category = "Food";
  String type = "expense";
  DateTime selectedDate = DateTime.now();

  final categories = [
    "Food","Travel","Shopping","Movie",
    "Health","Education","Recharge","Other"
  ];

  void saveExpense() async {
    if (titleController.text.isEmpty || amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter all fields")));
      return;
    }

    Expense exp = Expense(
      title: titleController.text,
      amount: double.parse(amountController.text),
      category: category,
      date: DateFormat('yyyy-MM-dd').format(selectedDate),
      type: type,
    );

    await DatabaseService().insertExpense(exp);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saved Successfully")),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff020617),

      /// 🔥 PREMIUM APPBAR
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(85),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff16a34a), Color(0xff22c55e)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: (){
                    Navigator.pop(context,true);
                  },
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Add Transaction 💰",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// 🔥 ANIMATION HEADER
            Container(
              height: 170,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff16a34a), Color(0xff22c55e)],
                ),
                borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(35)),
              ),
              child: Center(
                child: SizedBox(
                  height: 120,
                  child: Lottie.asset(
                    "assets/animations/transaction.json",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 FORM CARD
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xff0f172a),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.6),
                    blurRadius: 20,
                  )
                ],
              ),
              child: Column(
                children: [

                  /// TITLE
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Title",
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.title, color: Colors.green),
                      filled: true,
                      fillColor: const Color(0xff020617),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// AMOUNT
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Amount",
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.currency_rupee,
                          color: Colors.green),
                      filled: true,
                      fillColor: const Color(0xff020617),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// TYPE SELECT
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("Expense"),
                          selected: type=="expense",
                          selectedColor: Colors.redAccent,
                          labelStyle: const TextStyle(color: Colors.white),
                          backgroundColor: Colors.black,
                          onSelected: (_){
                            setState(()=> type="expense");
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("Income"),
                          selected: type=="income",
                          selectedColor: Colors.green,
                          labelStyle: const TextStyle(color: Colors.white),
                          backgroundColor: Colors.black,
                          onSelected: (_){
                            setState(()=> type="income");
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// CATEGORY
                  DropdownButtonFormField(
                    dropdownColor: const Color(0xff0f172a),
                    value: category,
                    style: const TextStyle(color: Colors.white),
                    items: categories
                        .map((e)=>DropdownMenuItem(value:e,child:Text(e)))
                        .toList(),
                    onChanged: (v)=> setState(()=> category=v.toString()),
                    decoration: InputDecoration(
                      labelText: "Category",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xff020617),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// DATE PICKER
                  Row(
                    children: [
                      Text(DateFormat('dd MMM yyyy').format(selectedDate),
                          style: const TextStyle(color: Colors.white)),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff16a34a),
                        ),
                        icon: const Icon(Icons.date_range),
                        label: const Text("Pick Date"),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if(picked!=null){
                            setState(()=> selectedDate=picked);
                          }
                        },
                      )
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff16a34a),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: saveExpense,
                      child: const Text("SAVE TRANSACTION",
                          style: TextStyle(fontSize: 18)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}