import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth auth =
      FirebaseAuth.instance;

  int completedTasks = 0;
  int totalTasks = 0;
  int pendingTasks = 0;
  double productivityScore = 0;

  int rewardPoints = 0;
  int level = 1;
  int xp = 0;
  int streak = 0;

  List<dynamic> badges = [];

  List<Map<String, dynamic>> productivityHistory = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAnalytics();
  }

  // ============================================================
  // LOAD ANALYTICS
  // ============================================================

  Future<void> loadAnalytics() async {
    final user = auth.currentUser;

    if (user == null) {
      setState(() {
        loading = false;
      });

      return;
    }

    try {
      // --------------------------------------------------------
      // TASK DATA
      // --------------------------------------------------------

      final taskSnapshot = await firestore
          .collection("users")
          .doc(user.uid)
          .collection("tasks")
          .get();
      final userDoc = await firestore
          .collection("users")
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;

        rewardPoints = data["rewardPoints"] ?? 0;
        level = data["level"] ?? 1;
        xp = data["xp"] ?? 0;
        streak = data["streak"] ?? 0;
        badges = List.from(data["badges"] ?? []);
      }

      totalTasks = taskSnapshot.docs.length;

      completedTasks = taskSnapshot.docs
          .where(
            (e) => e["completed"] == true,
      )
          .length;

      pendingTasks =
          totalTasks - completedTasks;

      // --------------------------------------------------------
      // PRODUCTIVITY HISTORY
      // --------------------------------------------------------

      final productivitySnapshot = await firestore
          .collection("users")
          .doc(user.uid)
          .collection("productivity_history")
          .orderBy(
        "createdAt",
        descending: false,
      )
          .limit(30)
          .get();

      productivityHistory =
          productivitySnapshot.docs.map((doc) {
            final data = doc.data();

            return {
              "score":
              (data["score"] as num?)?.toDouble() ?? 0,

              "studyHours":
              (data["studyHours"] as num?)?.toDouble() ?? 0,

              "sleepHours":
              (data["sleepHours"] as num?)?.toDouble() ?? 0,

              "screenTime":
              (data["screenTime"] as num?)?.toDouble() ?? 0,

              "level":
              data["level"] ?? "Unknown",

              "createdAt":
              data["createdAt"],
            };
          }).toList();

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      debugPrint(
        "Analytics error: $e",
      );

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // ============================================================
  // TASK PROGRESS
  // ============================================================

  double get taskProgress {
    if (totalTasks == 0) {
      return 0;
    }

    return completedTasks / totalTasks;
  }

  // ============================================================
  // AVERAGE AI SCORE
  // ============================================================

  double get averageProductivity {
    if (productivityHistory.isEmpty) {
      return 0;
    }

    final total = productivityHistory.fold<double>(
      0,
          (s, item) =>
      s + (item["score"] as double),
    );

    return total / productivityHistory.length;
  }

  // ============================================================
  // LATEST AI SCORE
  // ============================================================

  double get latestProductivity {
    if (productivityHistory.isEmpty) {
      return 0;
    }

    return productivityHistory.last["score"]
    as double;
  }

  // ============================================================
  // PRODUCTIVITY LEVEL
  // ============================================================

  String get productivityLevel {
    final score = latestProductivity;

    if (score >= 80) {
      return "Excellent";
    }

    if (score >= 60) {
      return "Good";
    }

    if (score >= 40) {
      return "Average";
    }

    return "Low";
  }

  // ============================================================
  // SCORE COLOR
  // ============================================================

  Color scoreColor(double score) {
    if (score >= 80) {
      return Colors.green;
    }

    if (score >= 60) {
      return Colors.blue;
    }

    if (score >= 40) {
      return Colors.orange;
    }

    return Colors.red;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
      theme.scaffoldBackgroundColor,

      body: RefreshIndicator(
        onRefresh: loadAnalytics,

        child: SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),

          padding:
          const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),

              // ==================================================
              // HEADER
              // ==================================================

              Text(
                "Analytics",

                style: theme
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Track your productivity performance",

                style:
                theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 30),

              if (loading)

                const Center(
                  child:
                  CircularProgressIndicator(),
                )

              else ...[

                // =================================================
                // AI PRODUCTIVITY SCORE
                // =================================================

                Container(
                  width: double.infinity,

                  padding:
                  const EdgeInsets.all(24),

                  decoration:
                  BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(26),

                    gradient:
                    const LinearGradient(
                      colors: [
                        Color(0xFF6C63FF),
                        Color(0xFF8B7CFF),
                      ],
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors
                            .deepPurple
                            .withOpacity(.25),

                        blurRadius: 18,

                        offset:
                        const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [

                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 42,
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      const Text(
                        "AI Productivity Score",

                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        latestProductivity
                            .toStringAsFixed(2),

                        style:
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        productivityHistory
                            .isEmpty
                            ? "No prediction yet"
                            : productivityLevel,

                        style:
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // =================================================
                // STAT CARDS
                // =================================================

                Row(
                  children: [

                    Expanded(
                      child: _StatCard(
                        title:
                        "Average AI Score",

                        value:
                        averageProductivity
                            .toStringAsFixed(1),

                        icon:
                        Icons.analytics,

                        color:
                        Colors.deepPurple,
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    Expanded(
                      child: _StatCard(
                        title:
                        "Predictions",

                        value:
                        productivityHistory
                            .length
                            .toString(),

                        icon:
                        Icons.auto_graph,

                        color:
                        Colors.blue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [

                    Expanded(
                      child: _StatCard(
                        title:
                        "Completed Tasks",

                        value:
                        completedTasks
                            .toString(),

                        icon:
                        Icons.check_circle,

                        color:
                        Colors.green,
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    Expanded(
                      child: _StatCard(
                        title:
                        "Pending Tasks",

                        value:
                        pendingTasks
                            .toString(),

                        icon:
                        Icons.pending_actions,

                        color:
                        Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // =================================================
                // AI PRODUCTIVITY TREND
                // =================================================

                Text(
                  "Productivity Trend",

                  style:
                  theme.textTheme.titleLarge
                      ?.copyWith(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Your AI productivity score over time",

                  style:
                  theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,

                  padding:
                  const EdgeInsets.fromLTRB(
                    12,
                    24,
                    20,
                    16,
                  ),

                  decoration:
                  BoxDecoration(
                    color:
                    theme.cardColor,

                    borderRadius:
                    BorderRadius.circular(24),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(.05),

                        blurRadius: 12,

                        offset:
                        const Offset(0, 6),
                      ),
                    ],
                  ),

                  child:
                  productivityHistory.length <
                      2
                      ? SizedBox(
                    height: 250,

                    child: Center(
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                        children: [

                          Icon(
                            Icons
                                .show_chart,
                            size: 55,

                            color: Colors
                                .grey
                                .shade400,
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          Text(
                            "Make at least 2 predictions",
                            style: theme
                                .textTheme
                                .bodyLarge,
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            "to see your productivity trend.",
                            style: theme
                                .textTheme
                                .bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                      : SizedBox(
                    height: 250,

                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 100,

                        gridData:
                        FlGridData(
                          show: true,
                          drawVerticalLine:
                          false,
                        ),

                        borderData:
                        FlBorderData(
                          show: false,
                        ),

                        titlesData:
                        FlTitlesData(
                          topTitles:
                          const AxisTitles(
                            sideTitles:
                            SideTitles(
                              showTitles:
                              false,
                            ),
                          ),

                          rightTitles:
                          const AxisTitles(
                            sideTitles:
                            SideTitles(
                              showTitles:
                              false,
                            ),
                          ),

                          leftTitles:
                          AxisTitles(
                            sideTitles:
                            SideTitles(
                              showTitles:
                              true,

                              reservedSize:
                              35,

                              interval:
                              20,
                            ),
                          ),

                          bottomTitles:
                          AxisTitles(
                            sideTitles:
                            SideTitles(
                              showTitles:
                              true,

                              interval: 1,

                              getTitlesWidget:
                                  (value,
                                  meta) {
                                return Text(
                                  "${value.toInt() + 1}",
                                  style:
                                  const TextStyle(
                                    fontSize:
                                    11,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        lineBarsData: [

                          LineChartBarData(
                            spots:
                            productivityHistory
                                .asMap()
                                .entries
                                .map(
                                  (entry) {
                                return FlSpot(
                                  entry.key
                                      .toDouble(),

                                  entry.value[
                                  "score"]
                                  as double,
                                );
                              },
                            ).toList(),

                            isCurved:
                            true,

                            barWidth: 4,

                            isStrokeCapRound:
                            true,

                            dotData:
                            const FlDotData(
                              show: true,
                            ),

                            belowBarData:
                            BarAreaData(
                              show: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // =================================================
                // TASK COMPLETION
                // =================================================

                Text(
                  "Task Completion",

                  style:
                  theme.textTheme.titleLarge
                      ?.copyWith(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                Container(
                  width: double.infinity,

                  padding:
                  const EdgeInsets.all(22),

                  decoration:
                  BoxDecoration(
                    color:
                    theme.cardColor,

                    borderRadius:
                    BorderRadius.circular(24),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(.05),

                        blurRadius: 12,

                        offset:
                        const Offset(0, 6),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [

                      SizedBox(
                        width: 170,
                        height: 170,

                        child: Stack(
                          alignment:
                          Alignment.center,

                          children: [

                            SizedBox(
                              width: 170,
                              height: 170,

                              child:
                              CircularProgressIndicator(
                                value:
                                taskProgress,

                                strokeWidth: 14,
                              ),
                            ),

                            Column(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                              children: [

                                Text(
                                  "${(taskProgress * 100).round()}%",

                                  style: theme
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 5,
                                ),

                                Text(
                                  "Completed",

                                  style: theme
                                      .textTheme
                                      .bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceEvenly,

                        children: [

                          _MiniStat(
                            label:
                            "Total",

                            value:
                            totalTasks
                                .toString(),

                            color:
                            Colors.blue,
                          ),

                          _MiniStat(
                            label:
                            "Completed",

                            value:
                            completedTasks
                                .toString(),

                            color:
                            Colors.green,
                          ),

                          _MiniStat(
                            label:
                            "Pending",

                            value:
                            pendingTasks
                                .toString(),

                            color:
                            Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // =================================================
                // AI INSIGHT
                // =================================================

                Container(
                  width: double.infinity,

                  padding:
                  const EdgeInsets.all(22),

                  decoration:
                  BoxDecoration(
                    color:
                    theme.cardColor,

                    borderRadius:
                    BorderRadius.circular(24),

                    border: Border.all(
                      color: Colors.deepPurple
                          .withOpacity(.2),
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Row(
                        children: [

                          const Icon(
                            Icons.lightbulb,
                            color:
                            Colors.amber,
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Text(
                            "AI Insight",

                            style: theme
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      Text(
                        productivityHistory
                            .isEmpty
                            ? "Make your first AI productivity prediction to receive personalized insights."
                            : latestProductivity >= 80
                            ? "Excellent work! Your productivity is currently very strong. Maintain your current study and sleep habits."
                            : latestProductivity >= 60
                            ? "You're doing well. Improving your sleep and maintaining consistent study hours could increase your productivity."
                            : "Your productivity has room for improvement. Focus on sleep, study consistency and reducing unnecessary screen time.",

                        style:
                        theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


// ================================================================
// STAT CARD
// ================================================================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme =
    Theme.of(context);

    return Container(
      padding:
      const EdgeInsets.all(18),

      decoration:
      BoxDecoration(
        color:
        theme.cardColor,

        borderRadius:
        BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.05),

            blurRadius: 12,

            offset:
            const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        children: [

          CircleAvatar(
            radius: 24,

            backgroundColor:
            color.withOpacity(.15),

            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            value,

            style: theme
                .textTheme
                .headlineSmall
                ?.copyWith(
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            title,

            textAlign:
            TextAlign.center,

            style:
            theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}


// ================================================================
// MINI STAT
// ================================================================

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Text(
          value,

          style: TextStyle(
            fontSize: 22,
            fontWeight:
            FontWeight.bold,
            color: color,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(label),
      ],
    );
  }
}