extension StringFormatter on String {
  String capitalizeFirstLetter() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

enum TaskPriority { low, medium, high }

class Task {
  String title;
  TaskPriority priority;
  bool isDone;

  Task(this.title, this.priority, {this.isDone = false});

  void completeTask() {
    isDone = true;
  }

  @override
  String toString() {
    return 'Task: $title | Priority: ${priority.name} | Done: $isDone';
  }
}

void main() async {
  print('--- Starting Lab 2 ---');

  List<Task> myTasks = [
    Task('Study Dart', TaskPriority.high),
    Task('Do Laundry', TaskPriority.low),
    Task('Finish Lab 2', TaskPriority.medium),
  ];

  print('\n--- My Tasks ---');
  for (var task in myTasks) {
    print(task);
  }

  String myName = 'omar';
  print('\n--- Testing Extension ---');
  print('Original: $myName, Formatted: ${myName.capitalizeFirstLetter()}');

  print('\n--- Testing Anonymous Function ---');
  myTasks.forEach((task) {
    if (task.priority == TaskPriority.high) {
      print('URGENT: ${task.title}');
    }
  });

  print('\n--- Testing Future (Please wait...) ---');
  await simulateNetworkCall();
  print('--- Lab 2 Finished ---');
}

Future<void> simulateNetworkCall() async {
  await Future.delayed(const Duration(seconds: 2));
  print('Network call completed after 2 seconds!');
}