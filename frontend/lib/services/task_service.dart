
import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/errors/api_exception.dart';
import '../core/network/api_client.dart';
import '../models/task.dart';

class TaskService {
  final ApiClient _apiClient;

  TaskService(this._apiClient);

  Future<List<Task>> getTasks() async {
    try {
      final response = await _apiClient.get(ApiConstants.tasksUrl);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data
            .map((json) => Task.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        message: 'Failed to load tasks',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: 'Unable to connect to the server: $e');
    }
  }

  Future<Task> createTask(Task task) async {
  try {
    final response = await _apiClient.post(
      ApiConstants.tasksUrl,
      body: task.toJson(),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Task.fromJson(data);
    }

    throw ApiException(
      message: 'Failed to create task',
      statusCode: response.statusCode,
    );
  } catch (e) {
    if (e is ApiException) rethrow;

    throw ApiException(
      message: 'Unable to connect to the server: $e',
    );
  }
}

}
