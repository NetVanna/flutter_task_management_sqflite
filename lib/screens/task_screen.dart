import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_management/database/database_helper.dart';
import 'package:task_management/models/task_model.dart';
import 'package:slideable/Slideable.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Task",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Tasks>>(
          future: _getTask(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text("Task Not Available Yet!!"),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var task = snapshot.data![index];
                return Slideable(
                  resetSlide: true,
                  items: [
                    ActionItems(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPress: () {
                        DatabaseHelper.deleteTask(id: task.id!);
                        final snackBar = SnackBar(
                          content: const Text(
                            'Delete Task Success!',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.red,
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {},
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        setState(() {});
                      },
                      backgroudColor: Colors.transparent,
                    ),
                  ],
                  child: Card(
                    color: task.isDone == 1 ? Colors.red : null,
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          if (task.isDone == 1) {
                            task.isDone = 0;
                            var row = {"isDone": 0};
                            DatabaseHelper.updateTask(id: task.id!, row: row);
                          } else {
                            task.isDone = 1;
                            var row = {"isDone": 1};
                            DatabaseHelper.updateTask(id: task.id!, row: row);
                          }
                        });
                      },
                      leading: Text(
                        "${task.id}",
                        style: TextStyle(
                          fontSize: 20,
                          color: task.isDone == 1 ? Colors.white : null,
                        ),
                      ),
                      title: Text(
                        "${task.title}",
                        style: TextStyle(
                          fontSize: 18,
                          color: task.isDone == 1 ? Colors.white : null,
                        ),
                      ),
                      trailing: Checkbox(
                        value: task.isDone == 1 ? true : false,
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              var row = {"isDone": 1};
                              task.isDone = 1;
                              DatabaseHelper.updateTask(id: task.id!, row: row);
                            } else {
                              task.isDone = 0;
                              var row = {"isDone": 0};
                              task.isDone = 1;
                              DatabaseHelper.updateTask(id: task.id!, row: row);
                            }
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showMyDialog(context);
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<List<Tasks>> _getTask() async {
    final task = await DatabaseHelper.getTask();
    return task.map((e) => Tasks.fromJson(e)).toList();
  }

  Future<void> _showMyDialog(BuildContext context) async {
    final taskNameController = TextEditingController();
    final taskDateController = TextEditingController();
    bool isDone = false;
    final dbHelper = DatabaseHelper();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState2) {
            return AlertDialog(
              title: const Text('Add Task'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: ListBody(
                    children: [
                      TextFormField(
                        controller: taskNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please Enter Task Name !!";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Task",
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: taskDateController,
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          DateTime date = (await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2023),
                                lastDate: DateTime(2030),
                              )) ??
                              DateTime.now();

                          taskDateController.text =
                              DateFormat('yyyy-MM-dd').format(date);
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Date",
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Checkbox(
                            value: isDone,
                            onChanged: (value) {
                              setState2(() {
                                isDone = value!;
                              });
                            },
                          ),
                          const Text("Is Done"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Add Task'),
                  onPressed: () async {
                    final snackBar = SnackBar(
                      content: const Text(
                        'Insert Task Success!',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.blue,
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {},
                      ),
                    );
                    if (formKey.currentState!.validate()) {
                      final db = await dbHelper.database;
                      Map<String, dynamic> row = {
                        DatabaseHelper().columnTitle: taskNameController.text,
                        DatabaseHelper().columnIsDone: isDone ? 1 : 0,
                        DatabaseHelper().columnDate: taskDateController.text,
                      };
                      final id = await DatabaseHelper.insertTask(row);
                      if (id > 0) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        setState(() {});
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
