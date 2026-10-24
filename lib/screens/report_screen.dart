import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("রিপোর্ট ও বিশ্লেষণ"), backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // ট্যাব ডিজাইন
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: const Color(0xFF00796B), borderRadius: BorderRadius.circular(15)), child: const Center(child: Text("মাসিক", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
                  const Expanded(child: Center(child: Text("ত্রৈমাসিক", style: TextStyle(color: Colors.grey)))),
                  const Expanded(child: Center(child: Text("বার্ষিক", style: TextStyle(color: Colors.grey)))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // চার্ট কার্ড
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 12), Text(" লাভ"),
                      SizedBox(width: 20),
                      Icon(Icons.circle, color: Colors.red, size: 12), Text(" লোকসান"),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const style = TextStyle(color: Colors.grey, fontSize: 10);
                                switch (value.toInt()) {
                                  case 0: return const Text('জানু', style: style);
                                  case 1: return const Text('ফেব', style: style);
                                  case 2: return const Text('মার্চ', style: style);
                                  case 3: return const Text('এপ্রি', style: style);
                                  default: return const Text('', style: style);
                                }
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          _makeGroupData(0, 60, 20),
                          _makeGroupData(1, 65, 30),
                          _makeGroupData(2, 80, 20),
                          _makeGroupData(3, 55, 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B)),
                onPressed: () {},
                child: const Text("বিস্তারিত রিপোর্ট দেখুন", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: y1, color: Colors.green, width: 12, borderRadius: BorderRadius.circular(4)),
        BarChartRodData(toY: y2, color: Colors.red, width: 12, borderRadius: BorderRadius.circular(4)),
      ],
      barsSpace: 4,
    );
  }
}