import 'package:flutter/material.dart';

class Task {
  String? id;
  String title;
  String? category;
  Color priority;
  bool isCompleted;
  DateTime? dueDate;
  String? notes;
  List<String> subtasks;
  bool isStarred;

  Task({
    this.id,
    required this.title,
    this.category,
    required this.priority,
    this.isCompleted = false,
    this.dueDate,
    this.notes,
    List<String>? subtasks,
    this.isStarred = false,
  }) : subtasks = subtasks ?? [];

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'priority': priority.value.toRadixString(16).padLeft(8, '0'),
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'notes': notes,
      'subtasks': subtasks,
      'isStarred': isStarred,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      title: json['title'] ?? '',
      category: json['category'],
      priority: Color(int.parse(json['priority'] ?? 'FF000000', radix: 16)),
      isCompleted: json['isCompleted'] ?? false,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      notes: json['notes'],
      subtasks: List<String>.from(json['subtasks'] ?? []),
      isStarred: json['isStarred'] ?? false,
    );
  }
}