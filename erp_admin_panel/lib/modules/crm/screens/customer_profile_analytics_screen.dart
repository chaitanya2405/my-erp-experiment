import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/customer_profile.dart';
import '../../../services/customer_profile_service.dart';
import 'customer_profile_form_screen.dart';

class CustomerProfileAnalyticsScreen extends StatefulWidget {
  const CustomerProfileAnalyticsScreen({Key? key}) : super(key: key);

  @override
  _CustomerProfileAnalyticsScreenState createState() => _CustomerProfileAnalyticsScreenState();
}

class _CustomerProfileAnalyticsScreenState extends State<CustomerProfileAnalyticsScreen> {
  String selectedSegment = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer CRM Dashboard')),
      body: StreamBuilder<List<CustomerProfile>>(
        stream: CustomerProfileService().streamCustomers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final customers = snapshot.data!;

          // --- Analytics calculations ---
          final totalCustomers = customers.length;
          final totalLoyalty = customers.fold<int>(0, (sum, c) => sum + c.loyaltyPoints);
          final avgOrderValue = customers.isEmpty
              ? 0.0
              : customers.fold<double>(0, (sum, c) => sum + c.averageOrderValue) / customers.length;
          final segments = <String, int>{};
          for (final c in customers) {
            segments[c.customerSegment] = (segments[c.customerSegment] ?? 0) + 1;
          }
          final segmentColors = {
            'Platinum': Colors.blue,
            'Gold': Colors.amber,
            'Silver': Colors.grey,
            'New': Colors.green,
            'Inactive': Colors.red,
          };

          // Loyalty distribution for chart
          final loyaltyBuckets = {
            '0-99': 0,
            '100-499': 0,
            '500-999': 0,
            '1000+': 0,
          };
          for (final c in customers) {
            if (c.loyaltyPoints >= 1000) {
              loyaltyBuckets['1000+'] = loyaltyBuckets['1000+']! + 1;
            } else if (c.loyaltyPoints >= 500) {
              loyaltyBuckets['500-999'] = loyaltyBuckets['500-999']! + 1;
            } else if (c.loyaltyPoints >= 100) {
              loyaltyBuckets['100-499'] = loyaltyBuckets['100-499']! + 1;
            } else {
              loyaltyBuckets['0-99'] = loyaltyBuckets['0-99']! + 1;
            }
          }

          // Growth trend (last 6 months)
          final now = DateTime.now();
          final monthLabels = List.generate(6, (i) {
            final date = DateTime(now.year, now.month - 5 + i, 1);
            return "${date.month}/${date.year % 100}";
          });
          final monthCounts = List.generate(6, (i) => 0);
          for (final c in customers) {
            final created = c.createdAt.toDate();
            for (int i = 0; i < 6; i++) {
              final date = DateTime(now.year, now.month - 5 + i, 1);
              if (created.year == date.year && created.month == date.month) {
                monthCounts[i]++;
                break;
              }
            }
          }

          // --- Advanced Analytics calculations ---
          final nowDate = DateTime.now();
          final inactiveCustomers = customers.where((c) =>
            c.lastOrderDate == null ||
            nowDate.difference(c.lastOrderDate!.toDate()).inDays > 90
          ).toList();
          final activeCustomers = customers.length - inactiveCustomers.length;

          final topLoyalty = [...customers]..sort((a, b) => b.loyaltyPoints.compareTo(a.loyaltyPoints));
          final top3 = topLoyalty.take(3).toList();

          final contactModes = <String, int>{};
          for (final c in customers) {
            contactModes[c.preferredContactMode] = (contactModes[c.preferredContactMode] ?? 0) + 1;
          }

          final feedbackCount = customers.where((c) => c.feedbackNotes.isNotEmpty).length;
          final recentFeedback = customers
              .where((c) => c.feedbackNotes.isNotEmpty)
              .take(5)
              .map((c) => '${c.fullName}: ${c.feedbackNotes}')
              .toList();

          // --- Churn Prediction (simple heuristic: no order in last 180 days) ---
          final churnedCustomers = customers.where((c) =>
            c.lastOrderDate == null ||
            nowDate.difference(c.lastOrderDate!.toDate()).inDays > 180
          ).toList();
          final churnRate = customers.isEmpty ? 0.0 : churnedCustomers.length / customers.length;

          // --- Cohort Analysis (signups by month for last 6 months) ---
          final cohortLabels = List.generate(6, (i) {
            final date = DateTime(now.year, now.month - 5 + i, 1);
            return "${date.month}/${date.year % 100}";
          });
          final cohortCounts = List.generate(6, (i) => 0);
          for (final c in customers) {
            final created = c.createdAt.toDate();
            for (int i = 0; i < 6; i++) {
              final date = DateTime(now.year, now.month - 5 + i, 1);
              if (created.year == date.year && created.month == date.month) {
                cohortCounts[i]++;
                break;
              }
            }
          }

          // --- Campaign Response ---
          final marketingOptIn = customers.where((c) => c.marketingOptIn).length;
          final feedbackGiven = customers.where((c) => c.feedbackNotes.isNotEmpty).length;

          // --- Customer Lifetime Value (CLV) ---
          final avgCLV = customers.isEmpty
              ? 0.0
              : customers.fold<double>(0, (sum, c) => sum + (c.averageOrderValue * c.totalOrders)) / customers.length;

          // --- Referral Impact ---
          final referred = customers.where((c) => c.referredBy.isNotEmpty).length;

          // --- Engagement Score (simple: orders + loyalty + feedback) ---
          final engagementScores = customers.map((c) =>
            (c.totalOrders * 2) + c.loyaltyPoints + (c.feedbackNotes.isNotEmpty ? 10 : 0)
          ).toList();
          final avgEngagement = engagementScores.isEmpty
              ? 0.0
              : engagementScores.reduce((a, b) => a + b) / engagementScores.length;

          // --- RFM Segmentation ---
          final rfmSegments = {
            'Champions': 0,
            'Loyal': 0,
            'Potential': 0,
            'At Risk': 0,
            'Lost': 0,
          };
          for (final c in customers) {
            final recency = c.lastOrderDate == null ? 9999 : nowDate.difference(c.lastOrderDate!.toDate()).inDays;
            final frequency = c.totalOrders;
            final monetary = c.averageOrderValue;

            if (recency <= 30 && frequency >= 10 && monetary >= 1000) {
              rfmSegments['Champions'] = rfmSegments['Champions']! + 1;
            } else if (recency <= 60 && frequency >= 5) {
              rfmSegments['Loyal'] = rfmSegments['Loyal']! + 1;
            } else if (recency <= 90 && frequency >= 2) {
              rfmSegments['Potential'] = rfmSegments['Potential']! + 1;
            } else if (recency > 90 && frequency >= 1) {
              rfmSegments['At Risk'] = rfmSegments['At Risk']! + 1;
            } else {
              rfmSegments['Lost'] = rfmSegments['Lost']! + 1;
            }
          }

          // --- Heatmap Data ---
          final dayOfWeekCounts = List<int>.filled(7, 0);
          for (final c in customers) {
            if (c.lastOrderDate != null) {
              final weekday = c.lastOrderDate!.toDate().weekday; // 1=Mon, 7=Sun
              dayOfWeekCounts[weekday - 1]++;
            }
          }
          final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

          // --- High Churn Risk Customers ---
          final highRisk = customers.where((c) =>
            c.lastOrderDate == null ||
            nowDate.difference(c.lastOrderDate!.toDate()).inDays > 90
          ).toList();

          // Filter customers by selected segment
          final filteredCustomers = selectedSegment == 'All'
              ? customers
              : customers.where((c) => c.customerSegment == selectedSegment).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- Analytics Cards ---
              Row(
                children: [
                  _statCard('Total Customers', totalCustomers.toString(), Icons.people, Colors.teal),
                  const SizedBox(width: 16),
                  _statCard('Total Loyalty Points', totalLoyalty.toString(), Icons.stars, Colors.amber),
                  const SizedBox(width: 16),
                  _statCard('Avg. Order Value', '₹${avgOrderValue.toStringAsFixed(2)}', Icons.attach_money, Colors.blue),
                ],
              ),
              const SizedBox(height: 24),
              // --- Advanced Analytics ---
              Row(
                children: [
                  _statCard('Inactive Customers', inactiveCustomers.length.toString(), Icons.person_off, Colors.red),
                  const SizedBox(width: 16),
                  _statCard('Feedbacks', feedbackCount.toString(), Icons.feedback, Colors.deepPurple),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text('Active vs Inactive', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 120,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  barGroups: [
                                    BarChartGroupData(x: 0, barRods: [
                                      BarChartRodData(toY: activeCustomers.toDouble(), color: Colors.green, width: 18),
                                    ]),
                                    BarChartGroupData(x: 1, barRods: [
                                      BarChartRodData(toY: inactiveCustomers.length.toDouble(), color: Colors.red, width: 18),
                                    ]),
                                  ],
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (double value, TitleMeta meta) {
                                          final labels = ['Active', 'Inactive'];
                                          return SideTitleWidget(
                                            axisSide: meta.axisSide,
                                            child: Text(labels[value.toInt()], style: const TextStyle(fontSize: 10)),
                                          );
                                        },
                                      ),
                                    ),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(show: false),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Top Loyalty Earners
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Top Loyalty Earners', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...top3.map((c) => Text('${c.fullName} (${c.mobileNumber}): ${c.loyaltyPoints} pts')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // --- Charts ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Segment Pie Chart
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text('Customer Segments', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 180,
                              child: PieChart(
                                PieChartData(
                                  sections: segments.entries.map((e) {
                                    final color = segmentColors[e.key] ?? Colors.grey;
                                    return PieChartSectionData(
                                      color: color,
                                      value: e.value.toDouble(),
                                      title: '${e.key}\n${e.value}',
                                      radius: 50,
                                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                    );
                                  }).toList(),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Loyalty Bar Chart
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text('Loyalty Points Distribution', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 180,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  barGroups: List.generate(loyaltyBuckets.length, (i) {
                                    final label = loyaltyBuckets.keys.elementAt(i);
                                    final value = loyaltyBuckets[label]!;
                                    return BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: value.toDouble(),
                                          color: Colors.teal,
                                          width: 18,
                                        ),
                                      ],
                                    );
                                  }),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (double value, TitleMeta meta) {
                                          final labels = loyaltyBuckets.keys.toList();
                                          return SideTitleWidget(
                                            axisSide: meta.axisSide,
                                            child: Text(labels[value.toInt()], style: const TextStyle(fontSize: 10)),
                                          );
                                        },
                                      ),
                                    ),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(show: false),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Growth Line Chart
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text('Customer Growth (6 months)', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 180,
                              child: LineChart(
                                LineChartData(
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: List.generate(6, (i) => FlSpot(i.toDouble(), monthCounts[i].toDouble())),
                                      isCurved: true,
                                      color: Colors.purple,
                                      barWidth: 3,
                                      dotData: FlDotData(show: true),
                                    ),
                                  ],
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (double value, TitleMeta meta) {
                                          final labels = monthLabels;
                                          return SideTitleWidget(
                                            axisSide: meta.axisSide,
                                            child: Text(labels[value.toInt()], style: const TextStyle(fontSize: 10)),
                                          );
                                        },
                                      ),
                                    ),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(show: false),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // --- Data Table ---
              DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Mobile')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Segment')),
                  DataColumn(label: Text('Loyalty')),
                  DataColumn(label: Text('Orders')),
                  DataColumn(label: Text('Last Order')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: filteredCustomers.map((c) => DataRow(
                  cells: [
                    DataCell(Text(c.fullName)),
                    DataCell(Text(c.mobileNumber)),
                    DataCell(Text(c.email)),
                    DataCell(Text(c.customerSegment)),
                    DataCell(Text(c.loyaltyPoints.toString())),
                    DataCell(Text(c.totalOrders.toString())),
                    DataCell(Text(c.lastOrderDate != null ? c.lastOrderDate!.toDate().toString().split(' ').first : '-')),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerProfileFormScreen(profile: c),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )).toList(),
              ),
              // --- Churn Prediction Card ---
              _statCard('Churn Rate', '${(churnRate * 100).toStringAsFixed(1)}%', Icons.trending_down, Colors.deepOrange),

              const SizedBox(height: 16),

              // Cohort Analysis Chart
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Cohort Analysis (Signups by Month)', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barGroups: List.generate(cohortCounts.length, (i) {
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: cohortCounts[i].toDouble(),
                                    color: Colors.indigo,
                                    width: 18,
                                  ),
                                ],
                              );
                            }),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(cohortLabels[value.toInt()], style: const TextStyle(fontSize: 10)),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Campaign Response Cards
              Row(
                children: [
                  _statCard('Marketing Opt-In', marketingOptIn.toString(), Icons.campaign, Colors.blueAccent),
                  const SizedBox(width: 16),
                  _statCard('Feedback Given', feedbackGiven.toString(), Icons.rate_review, Colors.green),
                  const SizedBox(width: 16),
                  _statCard('Referred Customers', referred.toString(), Icons.group_add, Colors.purple),
                ],
              ),

              const SizedBox(height: 16),

              // Customer Lifetime Value Card
              _statCard('Avg. CLV', '₹${avgCLV.toStringAsFixed(2)}', Icons.account_balance_wallet, Colors.brown),

              const SizedBox(height: 16),

              // Engagement Score Card
              _statCard('Avg. Engagement', avgEngagement.toStringAsFixed(1), Icons.emoji_events, Colors.teal),

              const SizedBox(height: 16),

              // RFM Segmentation Chart
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('RFM Segmentation', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sections: rfmSegments.entries.map((e) {
                              final color = {
                                'Champions': Colors.green,
                                'Loyal': Colors.blue,
                                'Potential': Colors.amber,
                                'At Risk': Colors.orange,
                                'Lost': Colors.red,
                              }[e.key] ?? Colors.grey;
                              return PieChartSectionData(
                                color: color,
                                value: e.value.toDouble(),
                                title: '${e.key}\n${e.value}',
                                radius: 50,
                                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              );
                            }).toList(),
                            sectionsSpace: 2,
                            centerSpaceRadius: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- Order Activity Heatmap ---
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Order Activity Heatmap (Last Order Day)', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(7, (i) {
                            final count = dayOfWeekCounts[i];
                            final color = Color.lerp(Colors.white, Colors.teal, count / (dayOfWeekCounts.reduce((a, b) => a > b ? a : b) + 1));
                            return Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Center(
                                child: Text('${dayLabels[i]}\n$count', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // High Churn Risk Customers
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('High Churn Risk Customers', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...highRisk.take(5).map((c) => Text('${c.fullName} (${c.mobileNumber}) - Last order: ${c.lastOrderDate != null ? c.lastOrderDate!.toDate().toString().split(' ').first : 'Never'}')),
                      if (highRisk.length > 5) Text('+${highRisk.length - 5} more...', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      color: color.withOpacity(0.08),
      child: SizedBox(
        width: 200,
        height: 90,
        child: Center(
          child: ListTile(
            leading: Icon(icon, color: color, size: 36),
            title: Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            subtitle: Text(label, style: const TextStyle(fontSize: 14)),
          ),
        ),
      ),
    );
  }
}