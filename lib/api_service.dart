import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'task.dart';

class ApiService {
  static const String apiUrl = 'https://to-do-app-ez.vercel.app';
  static final Logger _logger = Logger();

  static Future<List<Task>> fetchTasks({
    String search = '',
    String filter = 'all',
    int offset = 0,
    int limit = 10,
  }) async {
    final queryParameters = {
      'batch': '1',
      'input': jsonEncode({
        '0': {
          'json': {
            'search': search,
            'filter': filter,
            'offset': offset,
            'limit': limit,
          }
        }
      }),
    };

    final uri = Uri.https(apiUrl.replaceFirst('https://', ''), '/api/trpc/task.getTasks', queryParameters);
    _logger.i('Request URL: $uri');

    try {
      final response = await http.get(uri);
      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response headers: ${response.headers}');
      _logger.i('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> taskData = jsonResponse[0]['result']['data']['json'] as List<dynamic>;
        return taskData.map((data) => Task.fromJson(data as Map<String, dynamic>)).toList();
      } else {
        _logger.e('Failed to load tasks: ${response.body}');
        throw Exception('Failed to load tasks: ${response.body}');
      }
    } catch (e) {
      _logger.e('Request failed with exception: $e');
      if (e is http.ClientException) {
        _logger.e('ClientException details: ${e.message}');
      }
      throw Exception('Request failed with exception: $e');
    }
  }

  static Future<void> addTask(Task task) async {
    final uri = Uri.https(apiUrl.replaceFirst('https://', ''), '/api/trpc/task.addTask', {'batch': '1'});
    final body = jsonEncode({
      '0': {
        'json': {
          'title': task.title,
          'description': task.description,
          'duedate': task.duedate?.toIso8601String(),
        }
      }
    });
    _logger.i('Request URL: $uri');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response headers: ${response.headers}');
      _logger.i('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to add task: ${response.body}');
      }
    } catch (e) {
      _logger.e('Request failed with exception: $e');
      throw Exception('Request failed with exception: $e');
    }
  }

  static Future<void> deleteTask(String id) async {
    final uri = Uri.https(apiUrl.replaceFirst('https://', ''), '/api/trpc/task.deleteTask', {'batch': '1'});
    final body = jsonEncode({
      '0': {
        'json': {
          'id': id,
        }
      }
    });
    _logger.i('Request URL: $uri');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response headers: ${response.headers}');
      _logger.i('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete task: ${response.body}');
      }
    } catch (e) {
      _logger.e('Request failed with exception: $e');
      throw Exception('Request failed with exception: $e');
    }
  }

  static Future<void> markTaskCompleted(String id) async {
    final uri = Uri.https(apiUrl.replaceFirst('https://', ''), '/api/trpc/task.markTaskCompleted', {'batch': '1'});
    final body = jsonEncode({
      '0': {
        'json': {
          'id': id,
        }
      }
    });
    _logger.i('Request URL: $uri');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response headers: ${response.headers}');
      _logger.i('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to mark task as completed: ${response.body}');
      }
    } catch (e) {
      _logger.e('Request failed with exception: $e');
      throw Exception('Request failed with exception: $e');
    }
  }

  static Future<void> markTaskUncompleted(String id) async {
    final uri = Uri.https(apiUrl.replaceFirst('https://', ''), '/api/trpc/task.markTaskUncompleted', {'batch': '1'});
    final body = jsonEncode({
      '0': {
        'json': {
          'id': id,
        }
      }
    });
    _logger.i('Request URL: $uri');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response headers: ${response.headers}');
      _logger.i('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to mark task as uncompleted: ${response.body}');
      }
    } catch (e) {
      _logger.e('Request failed with exception: $e');
      throw Exception('Request failed with exception: $e');
    }
  }
}
