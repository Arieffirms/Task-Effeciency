import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:task_effeciency/common/show_model.dart';
import 'package:task_effeciency/widgets/card_todo_list_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> tasks = [];
  String userName = '';
  String userGender = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTasks();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedUserName = prefs.getString('userName');
    final String? storedUserGender = prefs.getString('userGender');
    if (storedUserName == null || storedUserGender == null) {
      _showUserDialog();
    } else {
      setState(() {
        userName = storedUserName;
        userGender = storedUserGender;
      });
    }
  }

  Future<void> _showUserDialog() async {
    final TextEditingController nameController = TextEditingController();
    String? selectedGender;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Enter Your Name and Gender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            const Gap(10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(hintText: 'Gender'),
              items: const [
                DropdownMenuItem(value: 'Pria', child: Text('Pria')),
                DropdownMenuItem(value: 'Wanita', child: Text('Wanita')),
              ],
              onChanged: (value) {
                selectedGender = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && selectedGender != null) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('userName', nameController.text);
                await prefs.setString('userGender', selectedGender!);
                setState(() {
                  userName = nameController.text;
                  userGender = selectedGender!;
                });
                Navigator.of(context).pop();
              } else {
                // Show error message if name or gender is not selected
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Masukkan nama Anda dan pilih jenis kelamin Anda')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(json.decode(tasksString));
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', json.encode(tasks));
  }

  void addTask(String title, String description, String category, String date,
      String time) {
    final task = {
      'title': title,
      'description': description,
      'category': category,
      'date': date,
      'time': time,
      'isDone': false,
    };
    setState(() {
      tasks.add(task);
      _sortTasks();
    });
    _saveTasks();
  }

  void removeTask(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus tugas ini?'),
        actions: [
          TextButton(
            style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.grey.shade200)),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.grey.shade200)),
            onPressed: () {
              setState(() {
                tasks.removeAt(index);
              });
              _saveTasks();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void toggleTaskDone(int index, bool? isDone) {
    setState(() {
      tasks[index]['isDone'] = isDone;
    });
    _saveTasks();
  }

  // Implementasi Algoritma Multi Level Feedback Queue
  void _sortTasks() {
    tasks.sort((a, b) {
      // Sort by date
      DateTime dateA = DateFormat('MM/dd/yyyy').parse(a['date']);
      DateTime dateB = DateFormat('MM/dd/yyyy').parse(b['date']);
      int dateComparison = dateA.compareTo(dateB);

      if (dateComparison != 0) {
        return dateComparison;
      }

      // If dates are the same, sort by time
      TimeOfDay timeA = TimeOfDay(
        hour: int.parse(a['time'].split(':')[0]),
        minute: int.parse(a['time'].split(':')[1]),
      );
      TimeOfDay timeB = TimeOfDay(
        hour: int.parse(b['time'].split(':')[0]),
        minute: int.parse(b['time'].split(':')[1]),
      );
      int timeComparison = timeA.hour.compareTo(timeB.hour);
      if (timeComparison == 0) {
        timeComparison = timeA.minute.compareTo(timeB.minute);
      }

      if (timeComparison != 0) {
        return timeComparison;
      }

      // If dates and times are the same, sort by category difficulty
      Map<String, int> categoryPriority = {
        'MUDAH': 1,
        'SEDANG': 2,
        'SULIT': 3,
      };

      return categoryPriority[a['category']]!
          .compareTo(categoryPriority[b['category']]!);
    });
  }
  // Implementasi Algoritma Multi Level Feedback Queue

  @override
  Widget build(BuildContext context) {
    _sortTasks(); // Sort tasks before displaying

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 23,
            child: ClipOval(
              child: userGender == null
                  ? Container(color: Colors.blue)
                  : userGender == 'Pria'
                      ? Image.asset('assets/men.png')
                      : Image.asset('assets/women.png'),
            ),
          ),
          title: Text(
            "Hello I'm",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
          subtitle: Text(
            userName,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "High Priority",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMMM yyyy').format(DateTime.now()),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => const AddNewTaskModel(),
                    ).then((_) {
                      _loadTasks();
                    }); // Reload tasks after modal is closed
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD5E8FA),
                    foregroundColor: Colors.blue.shade800,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("+ New Task"),
                ),
              ],
            ),
            const Gap(20),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Column(
                      children: [
                        const Gap(100),
                        Lottie.asset(
                          "assets/marketresearch.json",
                          height: 200,
                        ),
                        const Text(
                          "Tidak Ada Tugas yang Tersedia",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return CardTodoListWidget(
                          category: task['category'],
                          getIndex: index,
                          title: task['title'],
                          description:
                              task['description'], // Use category for color
                          date: task['date'],
                          time: task['time'],
                          isDone: task['isDone'],
                          onDelete: () => removeTask(index),
                          onToggleDone: (value) => toggleTaskDone(index, value),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
