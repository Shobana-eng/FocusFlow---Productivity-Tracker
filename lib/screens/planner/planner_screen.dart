import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';

import '../../themes/app_theme.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final TextEditingController titleController =
  TextEditingController();

  final TextEditingController subjectController =
  TextEditingController();

  final TextEditingController searchController =
  TextEditingController();

  String selectedPriority = "Medium";

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String search = "";

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(2035),
    );

    if (picked != null && mounted) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // ============================================================
  // TIME PICKER
  // ============================================================

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
      selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // ============================================================
  // ADD TASK
  // ============================================================

  Future<void> addTask() async {
    final user = auth.currentUser;

    if (user == null) {
      showMessage(
        "Please login first.",
      );
      return;
    }

    final title =
    titleController.text.trim();

    final subject =
    subjectController.text.trim();

    if (title.isEmpty) {
      showMessage(
        "Please enter a task title.",
      );
      return;
    }

    try {
      int? notificationId;

      if (selectedDate != null && selectedTime != null) {
        final scheduledTime = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          selectedTime!.hour,
          selectedTime!.minute,
        );

        if (scheduledTime.isAfter(DateTime.now())) {
          notificationId = DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF;

          await NotificationService.instance.scheduleNotification(
            id: notificationId,
            title: "Task Reminder: $title",
            body: subject.isNotEmpty
                ? "Subject: $subject"
                : "Don't forget to complete your task!",
            scheduledTime: scheduledTime,
          );
        }
      }

      await firestore
          .collection("users")
          .doc(user.uid)
          .collection("tasks")
          .add({
        "title": title,
        "subject": subject,
        "priority": selectedPriority,
        "completed": false,
        "notificationId": notificationId,

        // Used by Home and Planner
        "createdAt":
        FieldValue.serverTimestamp(),

        // Kept for compatibility
        "date":
        FieldValue.serverTimestamp(),

        "dueDate": selectedDate == null
            ? ""
            : "${selectedDate!.day}/"
            "${selectedDate!.month}/"
            "${selectedDate!.year}",

        "time": selectedTime == null
            ? ""
            : selectedTime!.format(context),
      });

      clearForm();

      if (!mounted) return;

      Navigator.pop(context);

      showMessage(
        "Task added successfully!",
      );
    } catch (e) {
      showMessage(
        "Unable to add task: $e",
      );
    }
  }

  // ============================================================
  // UPDATE TASK
  // ============================================================

  Future<void> updateTask(
      String id,
      bool completed,
      ) async {
    final user = auth.currentUser;

    if (user == null) return;

    try {
      if (completed) {
        final doc = await firestore
            .collection("users")
            .doc(user.uid)
            .collection("tasks")
            .doc(id)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          final nid = data["notificationId"];

          if (nid != null && nid is int) {
            await NotificationService.instance.cancelNotification(nid);
          }
        }
      }

      await DatabaseService.instance.updateTask(
        uid: user.uid,
        taskId: id,
        completed: completed,
      );
    } catch (e) {
      showMessage(
        "Unable to update task.",
      );
    }
  }

  // ============================================================
  // DELETE TASK
  // ============================================================

  Future<void> deleteTask(
      String id,
      ) async {
    final user = auth.currentUser;

    if (user == null) return;

    try {
      final doc = await firestore
          .collection("users")
          .doc(user.uid)
          .collection("tasks")
          .doc(id)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final nid = data["notificationId"];

        if (nid != null && nid is int) {
          await NotificationService.instance.cancelNotification(nid);
        }
      }

      await firestore
          .collection("users")
          .doc(user.uid)
          .collection("tasks")
          .doc(id)
          .delete();

      showMessage(
        "Task deleted.",
      );
    } catch (e) {
      showMessage(
        "Unable to delete task.",
      );
    }
  }

  // ============================================================
  // DELETE CONFIRMATION
  // ============================================================

  Future<void> confirmDelete(
      String id,
      String title,
      ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
          Theme.of(context).cardColor,

          title:
          const Text("Delete Task?"),

          content: Text(
            'Are you sure you want to delete "$title"?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
              const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child:
              const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await deleteTask(id);
    }
  }

  // ============================================================
  // CLEAR FORM
  // ============================================================

  void clearForm() {
    titleController.clear();
    subjectController.clear();

    setState(() {
      selectedPriority = "Medium";
      selectedDate = null;
      selectedTime = null;
    });
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // ADD TASK DIALOG
  // ============================================================

  void showAddDialog() {
    clearForm();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor:
          Theme.of(context).cardColor,

          title:
          const Text("Add New Task"),

          content:
          SingleChildScrollView(
            child: Column(
              mainAxisSize:
              MainAxisSize.min,

              children: [

                // ------------------------------------------------
                // TASK TITLE
                // ------------------------------------------------

                TextField(
                  controller:
                  titleController,

                  textInputAction:
                  TextInputAction.next,

                  decoration:
                  const InputDecoration(
                    labelText:
                    "Task Title",

                    hintText:
                    "Example: Complete ML assignment",

                    prefixIcon:
                    Icon(Icons.task),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                // ------------------------------------------------
                // SUBJECT
                // ------------------------------------------------

                TextField(
                  controller:
                  subjectController,

                  textInputAction:
                  TextInputAction.done,

                  decoration:
                  const InputDecoration(
                    labelText:
                    "Subject",

                    hintText:
                    "Example: Machine Learning",

                    prefixIcon:
                    Icon(Icons.book),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                // ------------------------------------------------
                // PRIORITY
                // ------------------------------------------------

                DropdownButtonFormField<
                    String>(
                  value:
                  selectedPriority,

                  decoration:
                  const InputDecoration(
                    labelText:
                    "Priority",

                    prefixIcon:
                    Icon(Icons.flag),
                  ),

                  dropdownColor:
                  Theme.of(context).cardColor,

                  items: const [

                    DropdownMenuItem(
                      value: "High",
                      child:
                      Text("🔴 High"),
                    ),

                    DropdownMenuItem(
                      value: "Medium",
                      child:
                      Text("🟡 Medium"),
                    ),

                    DropdownMenuItem(
                      value: "Low",
                      child:
                      Text("🟢 Low"),
                    ),
                  ],

                  onChanged:
                      (value) {
                    if (value == null)
                      return;

                    setState(() {
                      selectedPriority =
                          value;
                    });
                  },
                ),

                const SizedBox(
                  height: 20,
                ),

                // ------------------------------------------------
                // DUE DATE
                // ------------------------------------------------

                SizedBox(
                  width:
                  double.infinity,

                  child:
                  OutlinedButton.icon(
                    onPressed:
                    pickDate,

                    icon: const Icon(
                      Icons.calendar_month,
                    ),

                    label: Text(
                      selectedDate == null
                          ? "Select Due Date"
                          : "${selectedDate!.day}/"
                          "${selectedDate!.month}/"
                          "${selectedDate!.year}",
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                // ------------------------------------------------
                // TIME
                // ------------------------------------------------

                SizedBox(
                  width:
                  double.infinity,

                  child:
                  OutlinedButton.icon(
                    onPressed:
                    pickTime,

                    icon: const Icon(
                      Icons.access_time,
                    ),

                    label: Text(
                      selectedTime == null
                          ? "Select Time"
                          : selectedTime!
                          .format(
                        context,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child:
              const Text("Cancel"),
            ),

            ElevatedButton.icon(
              onPressed:
              addTask,

              icon: const Icon(
                Icons.add_task,
              ),

              label:
              const Text("Add Task"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PRIORITY COLOR
  // ============================================================

  Color getPriorityColor(
      String priority,
      ) {
    switch (priority) {
      case "High":
        return Colors.red;

      case "Low":
        return Colors.green;

      default:
        return Colors.orange;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final user =
        auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor:
        Theme.of(context).scaffoldBackgroundColor,

        body: const Center(
          child: Text(
            "Please login to use the Planner.",
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor,

      // ========================================================
      // ADD BUTTON
      // ========================================================

      floatingActionButton:
      FloatingActionButton.extended(
        backgroundColor:
        AppTheme.primary,

        onPressed:
        showAddDialog,

        icon: const Icon(
          Icons.add,
        ),

        label:
        const Text("Add Task"),
      ),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
        Colors.transparent,

        elevation: 0,

        title: const Text(
          "Study Planner",

          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // FIRESTORE TASK STREAM
      // ========================================================

      body: StreamBuilder<
          QuerySnapshot>(
        stream: firestore
            .collection("users")
            .doc(user.uid)
            .collection("tasks")
            .orderBy(
          "createdAt",
          descending: true,
        )
            .snapshots(),

        builder:
            (context, snapshot) {

          // ----------------------------------------------------
          // LOADING
          // ----------------------------------------------------

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          // ----------------------------------------------------
          // ERROR
          // ----------------------------------------------------

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  24,
                ),

                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,

                  children: [

                    const Icon(
                      Icons.error_outline,

                      size: 60,

                      color:
                      Colors.red,
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    const Text(
                      "Unable to load tasks.",
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      snapshot.error
                          .toString(),

                      textAlign:
                      TextAlign.center,

                      style:
                      const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ----------------------------------------------------
          // TASK DOCUMENTS
          // ----------------------------------------------------

          List<QueryDocumentSnapshot>
          docs =
              snapshot.data?.docs
                  .toList() ??
                  [];

          // ----------------------------------------------------
          // SEARCH
          // ----------------------------------------------------

          if (search.isNotEmpty) {
            docs = docs.where(
                  (task) {
                final data =
                task.data()
                as Map<String,
                    dynamic>;

                final title =
                (data["title"] ??
                    "")
                    .toString()
                    .toLowerCase();

                final subject =
                (data["subject"] ??
                    "")
                    .toString()
                    .toLowerCase();

                return title
                    .contains(search) ||
                    subject
                        .contains(search);
              },
            ).toList();
          }

          // ----------------------------------------------------
          // PROGRESS
          // ----------------------------------------------------

          final completed =
              docs.where(
                    (task) {
                  final data =
                  task.data()
                  as Map<String,
                      dynamic>;

                  return data[
                  "completed"] ==
                      true;
                },
              ).length;

          final progress =
          docs.isEmpty
              ? 0.0
              : completed /
              docs.length;

          return SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.all(
                20,
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [

                  // ==============================================
                  // SEARCH
                  // ==============================================

                  TextField(
                    controller:
                    searchController,

                    onChanged: (value) {
                      setState(() {
                        search =
                            value
                                .toLowerCase()
                                .trim();
                      });
                    },

                    decoration:
                    InputDecoration(
                      hintText:
                      "Search Tasks",

                      prefixIcon:
                      const Icon(
                        Icons.search,
                      ),

                      suffixIcon:
                      search.isNotEmpty
                          ? IconButton(
                        onPressed:
                            () {
                          searchController
                              .clear();

                          setState(() {
                            search =
                            "";
                          });
                        },

                        icon:
                        const Icon(
                          Icons
                              .clear,
                        ),
                      )
                          : null,

                      filled: true,

                      fillColor:
                      Theme.of(context).cardColor,

                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          18,
                        ),

                        borderSide:
                        BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ==============================================
                  // TODAY'S GOAL
                  // ==============================================

                  Container(
                    width:
                    double.infinity,

                    padding:
                    const EdgeInsets.all(
                      22,
                    ),

                    decoration:
                    BoxDecoration(
                      borderRadius:
                      BorderRadius
                          .circular(
                        24,
                      ),

                      gradient:
                      const LinearGradient(
                        colors: [
                          AppTheme.primary,
                          AppTheme.secondary,
                        ],
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        const Text(
                          "Today's Goal",

                          style:
                          TextStyle(
                            color:
                            Colors.white70,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          docs.isEmpty
                              ? "Create your first task"
                              : "Complete ${docs.length} Tasks",

                          style:
                          const TextStyle(
                            color:
                            Colors.white,

                            fontSize: 26,

                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        ClipRRect(
                          borderRadius:
                          BorderRadius
                              .circular(
                            20,
                          ),

                          child:
                          LinearProgressIndicator(
                            value:
                            progress,

                            minHeight:
                            12,

                            backgroundColor:
                            Colors.white24,

                            valueColor:
                            const AlwaysStoppedAnimation(
                              Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Align(
                          alignment:
                          Alignment
                              .centerRight,

                          child: Text(
                            "${(progress * 100).toStringAsFixed(0)}%",

                            style:
                            const TextStyle(
                              color:
                              Colors.white,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // ==============================================
                  // SCHEDULE TITLE
                  // ==============================================

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                    children: [

                      const Text(
                        "My Tasks",

                        style:
                        TextStyle(
                          fontSize: 22,

                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      Text(
                        "$completed/${docs.length} done",

                        style:
                        const TextStyle(
                          color:
                          Colors.white60,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // ==============================================
                  // TASK LIST
                  // ==============================================

                  Expanded(
                    child: docs.isEmpty
                        ? _emptyState()
                        : ListView.builder(
                      physics:
                      const BouncingScrollPhysics(),

                      itemCount:
                      docs.length,

                      itemBuilder:
                          (context,
                          index) {

                        final task =
                        docs[index];

                        final data =
                        task.data()
                        as Map<
                            String,
                            dynamic>;

                        final completedTask =
                            data[
                            "completed"] ==
                                true;

                        final title =
                        (data[
                        "title"] ??
                            "")
                            .toString();

                        final subject =
                        (data[
                        "subject"] ??
                            "")
                            .toString();

                        final priority =
                        (data[
                        "priority"] ??
                            "Medium")
                            .toString();

                        final dueDate =
                        (data[
                        "dueDate"] ??
                            "")
                            .toString();

                        final time =
                        (data[
                        "time"] ??
                            "")
                            .toString();

                        final priorityColor =
                        getPriorityColor(
                          priority,
                        );

                        return Container(
                          margin:
                          const EdgeInsets
                              .only(
                            bottom: 16,
                          ),

                          padding:
                          const EdgeInsets
                              .all(
                            16,
                          ),

                          decoration:
                          BoxDecoration(
                            color:
                            Theme.of(context).cardColor,

                            borderRadius:
                            BorderRadius
                                .circular(
                              22,
                            ),
                          ),

                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                            children: [

                              // --------------------------------
                              // CHECKBOX
                              // --------------------------------

                              Checkbox(
                                value: completedTask,
                                activeColor: AppTheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                onChanged: (value) async {
                                  await updateTask(
                                    task.id,
                                    value ?? false,
                                  );

                                  setState(() {});
                                },
                              ),

                              // --------------------------------
                              // TASK DETAILS
                              // --------------------------------

                              Expanded(
                                child:
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                                  children: [

                                    Text(
                                      title,

                                      style:
                                      const TextStyle(
                                        fontSize:
                                        18,

                                        fontWeight:
                                        FontWeight
                                            .bold,
                                      ),
                                    ),

                                    if (subject
                                        .isNotEmpty) ...[

                                      const SizedBox(
                                        height: 6,
                                      ),

                                      Text(
                                        subject,

                                        style:
                                        const TextStyle(
                                          color:
                                          Colors
                                              .white70,
                                        ),
                                      ),
                                    ],

                                    const SizedBox(
                                      height: 10,
                                    ),

                                    Row(
                                      children: [

                                        Container(
                                          padding:
                                          const EdgeInsets
                                              .symmetric(
                                            horizontal:
                                            10,

                                            vertical:
                                            5,
                                          ),

                                          decoration:
                                          BoxDecoration(
                                            color:
                                            priorityColor,

                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                              20,
                                            ),
                                          ),

                                          child:
                                          Text(
                                            priority,

                                            style:
                                            const TextStyle(
                                              color:
                                              Colors.white,

                                              fontSize:
                                              12,

                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                          width: 10,
                                        ),

                                        if (dueDate
                                            .isNotEmpty)
                                          const Icon(
                                            Icons
                                                .calendar_month,

                                            size:
                                            16,

                                            color:
                                            Colors.white54,
                                          ),

                                        if (dueDate
                                            .isNotEmpty)
                                          const SizedBox(
                                            width:
                                            4,
                                          ),

                                        if (dueDate
                                            .isNotEmpty)
                                          Flexible(
                                            child:
                                            Text(
                                              dueDate,

                                              style:
                                              const TextStyle(
                                                color:
                                                Colors.white54,

                                                fontSize:
                                                12,
                                              ),
                                            ),
                                          ),

                                        if (time
                                            .isNotEmpty)
                                          const SizedBox(
                                            width:
                                            10,
                                          ),

                                        if (time
                                            .isNotEmpty)
                                          const Icon(
                                            Icons
                                                .access_time,

                                            size:
                                            16,

                                            color:
                                            Colors.white54,
                                          ),

                                        if (time
                                            .isNotEmpty)
                                          const SizedBox(
                                            width:
                                            4,
                                          ),

                                        if (time
                                            .isNotEmpty)
                                          Text(
                                            time,

                                            style:
                                            const TextStyle(
                                              color:
                                              Colors.white54,

                                              fontSize:
                                              12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // --------------------------------
                              // DELETE
                              // --------------------------------

                              PopupMenuButton<
                                  String>(
                                color:
                                Theme.of(context).cardColor,

                                onSelected:
                                    (value) {

                                  if (value ==
                                      "delete") {
                                    confirmDelete(
                                      task.id,
                                      title,
                                    );
                                  }
                                },

                                itemBuilder:
                                    (context) =>
                                const [

                                  PopupMenuItem(
                                    value:
                                    "delete",

                                    child:
                                    Row(
                                      children: [

                                        Icon(
                                          Icons
                                              .delete_outline,

                                          color:
                                          Colors.red,
                                        ),

                                        SizedBox(
                                          width:
                                          8,
                                        ),

                                        Text(
                                          "Delete",
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Icon(
            Icons
                .assignment_outlined,

            size: 70,

            color:
            Colors.white24,
          ),

          const SizedBox(
            height: 16,
          ),

          const Text(
            "No tasks yet",

            style: TextStyle(
              fontSize: 20,

              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          const Text(
            "Tap + Add Task to create your first task.",

            textAlign:
            TextAlign.center,

            style: TextStyle(
              color:
              Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    titleController.dispose();
    subjectController.dispose();
    searchController.dispose();

    super.dispose();
  }
}
