import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import '../services/database_service.dart';
import '../services/pdf_services.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {

  late TabController tabController;

  double income = 0;
  double expense = 0;
  double balance = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    loadData("day");

    tabController.addListener(() {
      if (tabController.indexIsChanging) return;

      if (tabController.index == 0) loadData("day");
      if (tabController.index == 1) loadData("week");
      if (tabController.index == 2) loadData("month");
      if (tabController.index == 3) loadData("year");
    });
  }

  Future<void> loadData(String type) async {
    final data = await DatabaseService().getExpenses();

    double inc = 0;
    double exp = 0;

    DateTime now = DateTime.now();

    for (var e in data) {
      DateTime d = DateTime.parse(e.date);

      bool include = false;

      if (type == "day") {
        include = d.day == now.day &&
            d.month == now.month &&
            d.year == now.year;
      }

      if (type == "week") {
        DateTime weekStart =
        now.subtract(Duration(days: now.weekday - 1));
        include =
            d.isAfter(weekStart.subtract(const Duration(days: 1)));
      }

      if (type == "month") {
        include = d.month == now.month && d.year == now.year;
      }

      if (type == "year") {
        include = d.year == now.year;
      }

      if (include) {
        if (e.type == "income") {
          inc += e.amount;
        } else {
          exp += e.amount;
        }
      }
    }

    setState(() {
      income = inc;
      expense = exp;
      balance = inc - exp;
    });
  }

  /// ✅ PDF EXPORT (ADDED ONLY)
  void exportPdf() async {
    String period = "Day";

    if (tabController.index == 1) period = "Week";
    if (tabController.index == 2) period = "Month";
    if (tabController.index == 3) period = "Year";

    final pdf = await PdfService.generateReport(
      period: period,
      income: income,
      expense: expense,
      balance: balance, title: '',
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  Widget infoCard(String title, double amount, Color color){
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(.9), color],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.4),
            blurRadius: 18,
            offset: const Offset(0,8),
          )
        ],
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text("₹ ${amount.toStringAsFixed(0)}",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildChart(){
    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [
              BarChartRodData(
                  toY: income,
                  color: const Color(0xff22c55e),
                  width: 35,
                  borderRadius: BorderRadius.circular(8))
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(
                  toY: expense,
                  color: const Color(0xffef4444),
                  width: 35,
                  borderRadius: BorderRadius.circular(8))
            ]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff020617),

      appBar: AppBar(
        elevation: 0,
        title: const Text("Analytics 📊",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xff020617),

        bottom: TabBar(
          controller: tabController,
          indicatorColor: const Color(0xff22c55e),
          labelColor: Colors.greenAccent,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: "Day"),
            Tab(text: "Week"),
            Tab(text: "Month"),
            Tab(text: "Year"),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              Row(
                children: [
                  Expanded(child: infoCard("Income", income, const Color(0xff16a34a))),
                  const SizedBox(width: 10),
                  Expanded(child: infoCard("Expense", expense, const Color(0xffdc2626))),
                ],
              ),

              const SizedBox(height: 15),

              infoCard("Balance", balance, const Color(0xff7c3aed)),

              const SizedBox(height: 30),

              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Income vs Expense",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold))),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xff0f172a),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: buildChart(),
              ),

              const SizedBox(height: 25),

              /// ✅ PDF BUTTON (ADDED ONLY)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: exportPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Export PDF Report"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}