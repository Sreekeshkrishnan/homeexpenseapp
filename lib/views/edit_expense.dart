import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../services/database_service.dart';

class EditExpensePage extends StatefulWidget {
  final Expense expense;

  const EditExpensePage({super.key, required this.expense});

  @override
  State<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {

  late TextEditingController titleController;
  late TextEditingController amountController;

  String category = "Food";
  String type = "expense";
  DateTime selectedDate = DateTime.now();

  final categories = [
    "Food","Travel","Shopping","Movie",
    "Health","Education","Recharge","Other"
  ];

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.expense.title);
    amountController =
        TextEditingController(text: widget.expense.amount.toString());

    category = widget.expense.category;
    type = widget.expense.type;
    selectedDate = DateTime.parse(widget.expense.date);
  }

  void updateExpense() async {
    Expense updated = Expense(
      id: widget.expense.id,
      title: titleController.text,
      amount: double.parse(amountController.text),
      category: category,
      date: DateFormat('yyyy-MM-dd').format(selectedDate),
      type: type,
    );

    await DatabaseService().updateExpense(updated);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff020617),
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
                      "Edit Transaction ✏️",
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

            const SizedBox(height: 10),
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
                  DropdownButtonFormField(
                    dropdownColor: const Color(0xff0f172a),
                    value: type,
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: "income", child: Text("Income")),
                      DropdownMenuItem(value: "expense", child: Text("Expense")),
                    ],
                    onChanged: (v)=> setState(()=> type=v.toString()),
                    decoration: InputDecoration(
                      labelText: "Type",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xff020617),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),

                  const SizedBox(height: 18),
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
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff16a34a),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: updateExpense,
                      child: const Text("UPDATE TRANSACTION",
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
