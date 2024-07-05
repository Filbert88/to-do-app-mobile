import 'package:flutter/material.dart';
import 'task.dart';
import 'task_card.dart';
import 'api_service.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1D2029),
        fontFamily: 'Poppins',
      ),
      home: const MyHomePage(title: 'To Do List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 120,
        colors: true,
        printEmojis: true),
  );
  List<Task> tasks = [];
  bool isLoading = false; // State for loading
  String errorMessage = '';
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  DateTime? selectedDate;
  String filter = 'all';
  String search = '';

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    searchController.addListener(() {
      if (search != searchController.text) {
        setState(() {
          search = searchController.text;
          _fetchTasks(); // Refetch tasks with new search term
        });
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    searchController.dispose(); // Dispose the search controller
    super.dispose();
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color(0xFF282B34),
      textColor: const Color(0xFF64FFDA),
      fontSize: 16.0,
    );
  }

  Future<void> _fetchTasks() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedTasks = await ApiService.fetchTasks(
        limit: 100,
        offset: 0,
        search: search,
        filter: filter,
      );

      fetchedTasks.sort((a, b) {
        // Prioritize tasks that are past due and not done
        if (a.duedate != null &&
            a.duedate!.isBefore(DateTime.now()) &&
            !a.isDone) {
          if (b.duedate != null &&
              b.duedate!.isBefore(DateTime.now()) &&
              !b.isDone) {
            return a.duedate!.compareTo(b.duedate!); // Sort by due date
          } else {
            return -1;
          }
        } else if (b.duedate != null &&
            b.duedate!.isBefore(DateTime.now()) &&
            !b.isDone) {
          return 1;
        }

        // Prioritize tasks that are not done
        if (!a.isDone && b.isDone) {
          return -1;
        } else if (a.isDone && !b.isDone) {
          return 1;
        }

        // Finally, sort by due date if both are done or both are not past due
        if (a.duedate != null && b.duedate != null) {
          return a.duedate!.compareTo(b.duedate!);
        } else if (a.duedate != null) {
          return -1;
        } else if (b.duedate != null) {
          return 1;
        } else {
          return 0;
        }
      });

      setState(() {
        tasks = fetchedTasks;
        errorMessage = ''; // Clear previous error message
      });
    } catch (error, stackTrace) {
      _logger.e('Failed to load tasks', error: error, stackTrace: stackTrace);
      setState(() {
        errorMessage = 'Failed to load tasks: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addTask() async {
    if (_formKey.currentState!.validate()) {
      _updateLoadingState(true);
      final newTask = Task(
        id: DateTime.now().toString(),
        title: titleController.text,
        description: descriptionController.text,
        duedate: selectedDate,
        createdAt: DateTime.now(),
      );

      // Close the dialog before making the API call
      Navigator.of(context).pop();

      try {
        await ApiService.addTask(newTask);
        await _fetchTasks(); // Refresh the task list after adding.
        _showToast('Task added successfully');
        _resetFields(); // Reset the input fields
      } catch (error, stackTrace) {
        _logger.e('Failed to add task', error: error, stackTrace: stackTrace);
        _showSnackBar('Failed to add task: $error'); // Show error in SnackBar.
      } finally {
        _updateLoadingState(false);
      }
    }
  }

  void _resetFields() {
    setState(() {
      titleController.clear();
      descriptionController.clear();
      dateController.clear();
      selectedDate = null;
    });
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Helper methods to manage state updates
  void _updateLoadingState(bool isLoading) {
    setState(() => this.isLoading = isLoading);
  }

  void _updateErrorMessage(String message) {
    setState(() => errorMessage = message);
  }

  Future<void> _markTaskAsDone(Task task) async {
    setState(() {
      isLoading = true;
    });
    try {
      await ApiService.markTaskCompleted(task.id);
      await _fetchTasks(); // Refresh the task list
      _showToast('Task marked as done');
    } catch (error, stackTrace) {
      _logger.e('Failed to mark task as done',
          error: error, stackTrace: stackTrace);
      setState(() {
        errorMessage = 'Failed to mark task as done: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _markTaskAsUndone(Task task) async {
    setState(() {
      isLoading = true;
    });
    try {
      await ApiService.markTaskUncompleted(task.id);
      await _fetchTasks(); // Refresh the task list
      _showToast('Task marked as undone');
    } catch (error, stackTrace) {
      _logger.e('Failed to mark task as undone',
          error: error, stackTrace: stackTrace);
      setState(() {
        errorMessage = 'Failed to mark task as undone: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteTask(Task task) async {
    setState(() {
      isLoading = true;
    });
    try {
      await ApiService.deleteTask(task.id);
      await _fetchTasks(); // Refresh the task list
      _showToast('Task deleted successfully');
    } catch (error, stackTrace) {
      _logger.e('Failed to delete task', error: error, stackTrace: stackTrace);
      setState(() {
        errorMessage = 'Failed to delete task: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  List<Task> getFilteredTasks() {
    return tasks.where((task) {
      if (filter == 'completed' && !task.isDone) return false;
      if (filter == 'incomplete' && task.isDone) return false;
      if (search.isNotEmpty &&
          !task.title.toLowerCase().contains(search.toLowerCase()))
        return false;
      return true;
    }).toList();
  }

  final _formKey = GlobalKey<FormState>();

  void _showAddTaskDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF141414),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.all(16),
      title: const Text('Add New Task',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Task Title',
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the task title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Task Description',
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: dateController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Due Date',
                labelStyle: const TextStyle(color: Colors.white),
                suffixIcon:
                    const Icon(Icons.calendar_today, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a due date';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    _addTask();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(221, 87, 195, 166),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D2029),
        title: Text(widget.title,
            style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search tasks...',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) {
                          setState(() {
                            search = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: filter,
                      dropdownColor: const Color(0xFF3A3C48),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(
                            value: 'completed', child: Text('Completed')),
                        DropdownMenuItem(
                            value: 'incomplete', child: Text('Incomplete')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          filter = value!;
                          _fetchTasks();
                        });
                      },
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 16, bottom: 16),
                  child: ElevatedButton(
                    onPressed: () => _showAddTaskDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF198CF9),
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Add Task',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                if (errorMessage.isNotEmpty)
                  Text(errorMessage, style: const TextStyle(color: Colors.red))
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: getFilteredTasks().length,
                      itemBuilder: (context, index) {
                        return TaskCard(
                          task: getFilteredTasks()[index],
                          onComplete: () =>
                              _markTaskAsDone(getFilteredTasks()[index]),
                          onUncomplete: () =>
                              _markTaskAsUndone(getFilteredTasks()[index]),
                          onDelete: () =>
                              _deleteTask(getFilteredTasks()[index]),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        tooltip: 'Add Task',
        backgroundColor: const Color(0xFF198CF9),
        child: const Icon(Icons.add),
      ),
    );
  }
}
