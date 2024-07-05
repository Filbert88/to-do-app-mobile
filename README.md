# Flutter To-Do List App

This is a simple To-Do List app built using Flutter. The app allows users to add and delete tasks, sort tasks by date and completion status, and filter tasks by their completion status.

## Features

- **Add Task**: Users can add new tasks with a title and a due date.
- **Delete Task**: Users can delete existing tasks.
- **Sort Tasks**: Tasks are automatically sorted by their due date and completion status.
- **Filter Tasks**: Users can filter tasks to show only completed or uncompleted tasks.

## Prerequisites

Before you begin, ensure you have met the following requirements:

- **Dart SDK**: Install the latest version of Dart SDK. You can download it [here](https://dart.dev/get-dart).
- **Flutter SDK**: Install the latest version of Flutter SDK. You can download it [here](https://flutter.dev/docs/get-started/install).

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Filbert88/to-do-app-mobile.git
   cd Todo-Task-mobile
    ```
2. **Navigate to the project directory**:
    ```bash
    cd Todo-Task-mobile
    ```
3. **Install dependencies**:
    ```bash
   flutter pub get
    ```
3. **Run the App**:
    ```bash
   flutter run
    ```

### Building APK
1.**Build the release APK**:

```sh
flutter build apk --release
```

2. **Locate the APK**:

```sh
location: build/app/outputs/flutter-apk/app-release.apk
```

## Try the apk
To try the apk, you can download it on https://drive.google.com/drive/folders/1ZpQScuVXd6t_pWbIl7eOBWkLL7GXQugV?usp=sharing

## Todo Task API Integration
This application interacts with the Todo Task API hosted at https://to-do-app-ez.vercel.app/.

## Available Endpoints
### Get Tasks
- **URL:** `/api/trpc/task.getTasks`
- **Method:** `GET`
- **Description:** Fetch all tasks from the server.

### Add Task
- **URL:** `/api/trpc/task.addTask`
- **Method:** `POST`
- **Description:** Add a new task to the server.
 

### Delete Task
- **URL:** `/api/trpc/task.deleteTask`
- **Method:** `POST`
- **Description:** Remove a specific task from the server.
 

### Mark Task as Done
- **URL:** `/api/trpc/task.markTaskCompleted`
- **Method:** `POST`
- **Description:** Mark a specific task as completed.
 
### Mark Task as Undone
- **URL:** `/api/trpc/task.markTaskUncompleted`
- **Method:** `POST`
- **Description:** Mark a specific task as incomplete.
 

## Tech Stack
- Flutter: UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase
- Dart: Client-optimized programming language for apps on multiple platforms
