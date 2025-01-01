import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:task_effeciency/constants/app_style.dart';
import 'package:task_effeciency/provider/date_time_provider.dart';
import 'package:task_effeciency/provider/radio_provider.dart';
import 'package:task_effeciency/widgets/date_time_widget.dart';
import 'package:task_effeciency/widgets/radio_widget.dart';
import 'package:task_effeciency/widgets/textfield_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddNewTaskModel extends StatefulWidget {
  const AddNewTaskModel({super.key});

  @override
  State<AddNewTaskModel> createState() => _AddNewTaskModelState();
}

class _AddNewTaskModelState extends State<AddNewTaskModel> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask(String title, String description, String category,
      String date, String time) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getString('tasks') ?? '[]';
    final tasks = List<Map<String, dynamic>>.from(json.decode(tasksString));

    final newTask = {
      'title': title,
      'description': description,
      'category': category,
      'date': date,
      'time': time,
      'isDone': false,
    };

    tasks.add(newTask);
    await prefs.setString('tasks', json.encode(tasks));
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Coba Lagi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final dateprov = ref.watch(dateProvider);
      final timeprov = ref.watch(timeProvider);
      return Container(
        padding: const EdgeInsets.all(30),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: double.infinity,
              child: Text(
                "New Task",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(thickness: 1.5, color: Colors.grey.shade200),
            const Text("Title Task", style: AppStyle.headingOne),
            const Gap(5),
            TextFieldWidget(
              hintText: "Tambahkan Tugas Baru",
              maxLines: 1,
              txtcontroller: titleController,
              txtInputAction: TextInputAction.next,
            ),
            const Gap(15),
            const Text("Deskripsi Task", style: AppStyle.headingOne),
            const Gap(5),
            TextFieldWidget(
              hintText: "Tambahkan Deskripsi",
              maxLines: 5,
              txtcontroller: descriptionController,
              txtInputAction: TextInputAction.done,
            ),
            const Gap(5),
            const Text("Category Kesulitan", style: AppStyle.headingOne),
            const Gap(5),
            Row(
              children: [
                Expanded(
                  child: RadioWidget(
                    titleRadio: "MUDAH",
                    categoryColor: Colors.green,
                    valueInput: 1,
                    onChangedValue: (value) => ref
                        .read(radioProvider.notifier)
                        .update((state) => value!),
                  ),
                ),
                Expanded(
                  child: RadioWidget(
                    titleRadio: "SEDANG",
                    categoryColor: const Color.fromARGB(255, 172, 156, 16),
                    valueInput: 2,
                    onChangedValue: (value) => ref
                        .read(radioProvider.notifier)
                        .update((state) => value!),
                  ),
                ),
                Expanded(
                  child: RadioWidget(
                    titleRadio: "SULIT",
                    categoryColor: Colors.red,
                    valueInput: 3,
                    onChangedValue: (value) => ref
                        .read(radioProvider.notifier)
                        .update((state) => value!),
                  ),
                ),
              ],
            ),
            const Gap(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DateTimeWidget(
                  titleText: "Date",
                  valueText: dateprov,
                  icon: Icons.calendar_month,
                  onTap: () async {
                    final getDate = await showCalendarDatePicker2Dialog(
                      context: context,
                      config: CalendarDatePicker2WithActionButtonsConfig(),
                      dialogSize: Size(325, 250),
                      value: [DateTime.now()],
                    );

                    if (getDate != null && getDate.isNotEmpty) {
                      final format = DateFormat.yMd();
                      ref.read(dateProvider.notifier).update((state) =>
                          format.format(getDate[0]!)); // Ambil tanggal pertama
                    }
                  },
                ),
                const Gap(22),
                DateTimeWidget(
                  titleText: "Time",
                  valueText: timeprov,
                  icon: Icons.alarm,
                  onTap: () async {
                    final getTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (getTime != null) {
                      ref
                          .read(timeProvider.notifier)
                          .update((state) => getTime.format(context));
                    }
                  },
                ),
              ],
            ),
            const Gap(20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey.shade400,
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final getRadioValue = ref.read(radioProvider);
                      String category = "";

                      switch (getRadioValue) {
                        case 1:
                          category = "MUDAH";
                          break;
                        case 2:
                          category = "SEDANG";
                          break;
                        case 3:
                          category = "SULIT";
                          break;
                        default:
                          category = "UNKNOWN";
                      }

                      if (titleController.text.isEmpty ||
                          descriptionController.text.isEmpty ||
                          category == "UNKNOWN" ||
                          ref.read(dateProvider) == "dd/mm/yyyy" ||
                          ref.read(timeProvider) == "hh : mm") {
                        _showErrorDialog("Mohon isi semua field yang ada");
                        return;
                      }

                      // Tampilkan loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible:
                            false, // Tidak bisa ditutup dengan tap di luar
                        builder: (context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              height: 100,
                              color: Colors.transparent,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  CircularProgressIndicator(
                                    color: Colors.blueAccent,
                                  ),
                                  SizedBox(height: 16),
                                  Text("Tunggu sebentar...",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white)),
                                ],
                              ),
                            ),
                          );
                        },
                      );

                      // Simulasi delay penyimpanan
                      await Future.delayed(Duration(seconds: 2));

                      // Simpan data
                      await _saveTask(
                        titleController.text,
                        descriptionController.text,
                        category,
                        ref.read(dateProvider),
                        ref.read(timeProvider),
                      );

                      // Tutup dialog loading setelah selesai
                      Navigator.of(context).pop();

                      // Clear form dan reset state
                      titleController.clear();
                      descriptionController.clear();
                      ref.read(radioProvider.notifier).update((state) => 0);
                      ref
                          .read(dateProvider.notifier)
                          .update((state) => "dd/mm/yyyy");
                      ref
                          .read(timeProvider.notifier)
                          .update((state) => "hh : mm");

                      Navigator.pop(context); // Kembali ke halaman sebelumnya
                    },
                    child: const Text(
                      "Simpan",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Gap(22),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue.shade800,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
