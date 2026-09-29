import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget buildCard(
      IconData icon,
      String title,
      String subtitle,
      Color color,
      ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [

            const SizedBox(height: 10),

            const Center(
              child: Text(
                "Welcome Student 👋",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 25),

            buildCard(
              Icons.menu_book,
              "Study Hours",
              "Track your daily study hours",
              Colors.blue,
            ),

            buildCard(
              Icons.assignment_turned_in,
              "Tasks",
              "Manage your daily tasks",
              Colors.green,
            ),

            buildCard(
              Icons.bar_chart,
              "Productivity Score",
              "Check your productivity performance",
              Colors.orange,
            ),

            buildCard(
              Icons.lightbulb,
              "Recommendations",
              "Get AI productivity suggestions",
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}