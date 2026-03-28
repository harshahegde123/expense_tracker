import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  void fetchExpenses() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final data = await FirebaseFirestore.instance
        .collection("expenses")
        .doc(uid)
        .collection("items")
        .get();

    setState(() {
      expenses = data.docs.map((e) => e.data()).toList();
    });
  }

  void addExpense(String category, double amount) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("expenses")
        .doc(uid)
        .collection("items")
        .add({
      "title": category,
      "amount": amount,
      "date": DateTime.now().toString().split(" ")[0],
    });

    fetchExpenses();
  }

  double getTotal() {
    double total = 0;
    for (var e in expenses) {
      total += (e["amount"] ?? 0);
    }
    return total;
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  void showAddDialog() {
    final amount = TextEditingController();

    String selectedCategory = "Food";

    final categories = [
      "Food",
      "Travel",
      "Shopping",
      "Bills",
      "Entertainment",
      "Other"
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Expense"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: categories.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCategory = val!;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: amount,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(hintText: "Enter Amount"),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: () {
                    if (amount.text.isNotEmpty) {
                      addExpense(
                        selectedCategory,
                        double.parse(amount.text),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        backgroundColor: Colors.tealAccent,
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dashboard",
                  style: TextStyle(fontSize: 26),
                ),
                IconButton(
                  onPressed: logout,
                  icon: const Icon(Icons.logout),
                )
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Expenses"),
                  Text(
                    "₹${getTotal()}",
                    style: const TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final item = expenses[index];

                  return Card(
                    color: Colors.white10,
                    child: ListTile(
                      title: Text(item["title"] ?? ""),
                      subtitle: Text(item["date"] ?? ""),
                      trailing: Text(
                        "₹${item["amount"]}",
                        style: const TextStyle(color: Colors.tealAccent),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}