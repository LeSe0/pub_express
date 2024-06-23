import 'package:dio/dio.dart';

class ResponseModel<T> {
  final T data;
  final bool? error;

  ResponseModel({
    required this.data,
    required this.error,
  });

  factory ResponseModel.fromJson(Response json, T data) {
    return ResponseModel(
      data: data,
      error: (json.statusCode ?? 400) > 400,
    );
  }
}
